<?php
/*
 * Mise à jour de la liste d'espace des communes
 *
 * doit être lancée après maj-entrepot.php
 */
if (!file_exists('config.php'))
	require_once('/etc/baseobs/config.php');
else
	require_once('config.php');
require_once(DB_INC_PHP);
require_once(OBS_DIR.'espece.php');
require_once(OBS_DIR.'utilisateur.php');
require_once(OBS_DIR.'espace.php');
require_once(OBS_DIR.'liste_espace.php');

get_db($db);

if (!defined('PROMONTOIRE2_ID_LISTE_COMMUNES'))
	throw new Exception("il faut créer une liste d'espace et enregistrer son numéro dans config.php PROMONTOIRE2_ID_LISTE_COMMUNES");

if (!defined('PROMONTOIRE2_DEPTS_LISTE_COMMUNES'))
	throw new Exception("il faut définir la liste des départements");

$id_liste = PROMONTOIRE2_ID_LISTE_COMMUNES;
$liste = new clicnat_listes_espaces($db, $id_liste);

$attrs = array(
	"insee" => array("name" => "insee", "type" => "int"),
	"total" => array("name" => "total", "type" => "int")
);
foreach (bobs_classe::get_classes() as $classe) {
	if ($classe == '_')
		continue;
	$attrs["classe_$classe"] = array("name" => "classe_$classe", "type" => "int");
}


/* vérification et création de champs */
$l_attrs = $liste->attributs();

// retir ceux qui existe déjà
foreach ($l_attrs as $l_attr) {
	if (isset($attrs[$l_attr['name']]))
		unset($attrs[$l_attr['name']]);
}

// insert le reste
foreach ($attrs as $attr) {
	$liste->attributs_def_ajout_champ($attr['name'], $attr['type'], null);
}

unset($liste);
$liste = new clicnat_listes_espaces($db, $id_liste);

// ajout des communes
$communes = $liste->get_espaces();
if ($communes->count() == 0) {
	foreach (explode(",",PROMONTOIRE2_DEPTS_LISTE_COMMUNES) as $dept) {
		foreach(bobs_espace_commune::liste_pour_departement($db, $dept) as $commune) {
			$liste->ajouter($commune->id_espace);
		}
	}
}

// extraction des chiffres
unset($liste);
$liste = new clicnat_listes_espaces($db, $id_liste);
foreach ($liste->get_espaces() as $commune) {
	echo "$commune ({$commune->id_espace})";
	flush();
	$stats = array();
	foreach ($attrs as $attr) {
		$stats[$attr['name']] = null;
	}
	
	$stats['insee'] = $commune->code_insee_txt;
	$stats['total'] = 0;

	$stats_classes = array();
	$nb_try = 10;
	while ($nb_try > 0) {
		try {
			foreach ($commune->entrepot_liste_especes() as $espece) {
				if ($espece->exclure_restitution)
					continue;
				$colname = "classe_{$espece->classe}";
				if (!isset($stats_classes[$colname])) {
					$stats_classes[$colname] = array();
				}

				$stats_classes[$colname][] = $espece;
			}
			$nb_try = 0;
		} catch (clicnat_exception_espece_pas_trouve $e) {
			bobs_log("maj-commune pas trouvé espèce : {$esp['id_espece']}");
			entrepot::db()->communes_stats_data->remove(array("id_espece" => "{$esp['id_espece']}"));
			$nb_try--;
			if ($nb_try <= 0) {
				throw new Exception("Trop d'erreurs !");
			}
		}
	}

	foreach ($stats_classes as $k => $t) {
		$stats[$k] = count($t);
		$stats['total'] += $stats[$k];
	}

	foreach ($stats as $k => $v) {
		$liste->espace_enregistre_attribut($commune->id_espace, $k, $v);
	}
	echo ".\n";
}

foreach (glob(sprintf("/tmp/espace_carte_*_%d.xml", $liste->id_liste_espace)) as $f) {
	unlink($f);
}

if (file_exists("/tmp/communes.kml"))
	unlink("/tmp/communes.kml");
$kml = $liste->export_kml();
$kml->save("/tmp/communes.kml");
?>

<?php
/*
 * Mise à jour de la carto des oiseaux hivernant
 *
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
$annee_deb = 2009;
$annee_fin = strftime("%Y");

if (!defined('PROMONTOIRE2_ID_LISTE_AOH'))
	define('PROMONTOIRE2_ID_LISTE_AOH',226);

$liste = new clicnat_listes_espaces($db, PROMONTOIRE2_ID_LISTE_AOH);

for ($annee=$annee_deb;$annee<=$annee_fin;$annee++) {
	$kb = "winter_{$annee}_".($annee+1);
	$k = "{$kb}_total";
	$attrs[$k] = array("name" => $k, "type" => "int");
	$k = "{$kb}_species";
	$attrs[$k] = array("name" => $k, "type" => "text");

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
$liste = new clicnat_listes_espaces($db, PROMONTOIRE2_ID_LISTE_AOH);

// ajout des communes
$carres = $liste->get_espaces();
if ($carres->count() == 0) {
	$src = bobs_espace_l93_10x10::tous($db);
	foreach($src as $c) {
		$liste->ajouter($c['id_espace']);
	}
}

for ($annee=$annee_deb;$annee<=$annee_fin;$annee++) {
	$kb = "winter_{$annee}_".($annee+1);
	foreach ($liste->get_espaces() as $espace) {
		echo $espace;
		flush();
		$oiseaux = $espace->get_oiseaux_hivernant_saison($annee);
		$n = 0;
		$taxons = "";
		foreach ($oiseaux as $oiseau) {
			//$espece = get_espece($db, $oiseau['id_espece']);
			$taxons .= $oiseau['id_espece'].",";

			$n++;
		}
		$liste->espace_enregistre_attribut($espace->id_espace, "{$kb}_total", $n);
		$liste->espace_enregistre_attribut($espace->id_espace, "{$kb}_species", trim($taxons,","));
		echo "\n";
	}
}
?>

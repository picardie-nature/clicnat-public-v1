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
require_once(OBS_DIR.'reseau.php');

get_db($db);
$annee_deb = 2009;
$annee_fin = strftime("%Y");

if (!defined('PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX'))
	define('PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX',227);
if (!defined('PROMONTOIRE2_ID_SELECTION_CARTO_RESEAUX'))
	define('PROMONTOIRE2_ID_SELECTION_CARTO_RESEAUX', 15572);

$liste = new clicnat_listes_espaces($db, PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX);

$attrs = array();
foreach (bobs_reseau::liste_reseaux($db) as $reseau) {
	$attrs[$reseau->id."_occurences"] = array(
		"name" => "{$reseau->id}_occurences",
		"type" => "int"
	);
	$attrs[$reseau->id."_species"] = array(
		"name" => "{$reseau->id}_species",
		"type" => "int"
	);
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
$liste = new clicnat_listes_espaces($db, PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX);
$carres = $liste->get_espaces();
if ($carres->count() == 0) {
	$q = bobs_qm()->query($db, "ins_atlas_55","select distinct espace_l93_5x5.id_espace from espace_l93_5x5, espace_departement where st_intersects(espace_departement.the_geom, espace_l93_5x5.the_geom) and espace_departement.nom in ('AISNE','OISE','SOMME')",array());
	while ($r = bobs_element::fetch($q)) {
		$liste->ajouter($r['id_espace']);
	}
}


$liste = new clicnat_listes_espaces($db, PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX);
$carres = $liste->get_espaces();
$index_c = array();
foreach ($carres as $c) {
	$index_c[$c->nom] = $c->id_espace;
}

$pas = 5000;
$srid = 2154;
foreach (bobs_reseau::liste_reseaux($db) as $reseau) {
	$extraction = new bobs_extractions($db);
	$extraction->ajouter_condition(new bobs_ext_c_reseau($reseau));
	$extraction->ajouter_condition(new bobs_ext_c_indice_qualite(array('3','4')));
	$extraction->ajouter_condition(new bobs_ext_c_sans_tag_invalide());

	$selection = new bobs_selection($db, PROMONTOIRE2_ID_SELECTION_CARTO_RESEAUX);
	$selection->vider();

	$extraction->dans_selection(PROMONTOIRE2_ID_SELECTION_CARTO_RESEAUX);
	

	$selection = new bobs_selection($db, PROMONTOIRE2_ID_SELECTION_CARTO_RESEAUX);
	
	$n_carres = $selection->carres_nespeces_ncitations($pas,$srid);
	foreach ($n_carres as $c) {
		$nom = sprintf("E%04dN%04d", ($c['x0']*$pas)/1000, ($c['y0']*$pas)/1000);
		echo "$nom {$c['count_citation']} {$c['count_especes']}\n";
		if (isset($index_c[$nom])) {
			$liste->espace_enregistre_attribut($index_c[$nom], "{$reseau->id}_occurences", $c['count_citation']);
			$liste->espace_enregistre_attribut($index_c[$nom], "{$reseau->id}_species", $c['count_especes']);
		} else {
			bobs_log("cartes réseaux nat. : carré $nom pas dans la liste");
		}
	}
}

foreach (glob(sprintf("/tmp/espace_carte_*_%d.xml",PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX)) as $f) {
	unlink($f);
}
?>

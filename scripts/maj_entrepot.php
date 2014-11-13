<?php
if (file_exists('config.php')) require_once('config.php');
else require_once('/etc/baseobs/config.php');
require_once(DB_INC_PHP);
require_once(OBS_DIR.'espece.php');
get_db($db);
foreach(bobs_espece::especes($db) as $e) {
	echo "$e";
	flush();
	$e->enregistre_liste_communes_presence();
	echo " \n";
}
bobs_espece::entrepot_calcul_stats_communes();

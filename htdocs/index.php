<?php
/**
 * Promontoire
 *
 * Mise à disposition au public du compte rendu de la base
 */

$start_time = microtime(true);
$disallow_dump = false;
$context = 'promontoire';

require_once('/etc/baseobs/config.php');

define('SESS', 'PROMONTOIRE2');
define('LOCALE', 'fr_FR.UTF-8');

require_once(SMARTY_DIR.'Smarty.class.php');
require_once(OBS_DIR.'element.php');
require_once(OBS_DIR.'espece.php');
require_once(OBS_DIR.'smarty.php');
require_once(OBS_DIR.'travaux.php');

$context = "promontoire";

if (!file_exists(SMARTY_CACHEDIR_PROMONTOIRE2)) {
	mkdir(SMARTY_CACHEDIR_PROMONTOIRE2);
}

if (stristr($_SERVER['HTTP_USER_AGENT'], '80legs.com')) {
	bobs_log('exit webcrawler http://www.80legs.com/webcrawler.html');
	exit(0);

}

class Promontoire extends clicnat_smarty {
	protected $db;
    
	public function __construct($db) {
		setlocale(LC_ALL, LOCALE);	
		parent::__construct($db, SMARTY_TEMPLATE_PROMONTOIRE2, SMARTY_COMPILE_PROMONTOIRE2, SMARTY_CACHEDIR_PROMONTOIRE2, '/tmp/clicnat_cache_public');
		$this->assign('niveau_restitution', bobs_espece::restitution_public);
	}

	protected function before_travaux() {
		$this->assign('travaux', clicnat_travaux::liste($this->db));
	}

	protected function before_fiche() {
		bobs_element::cli($_GET['id']);
		if (empty($_GET['id']))
		    throw new InvalidArgumentException('numéro espèce');
		require_once(OBS_DIR.'espece.php');
		$espece = get_espece($this->db, $_GET['id']);
		$this->assign_by_ref('espece', $espece);
		$this->assign_by_ref('titre_page', $espece);
		$this->assign('borne_a', intval(strftime("%Y"))-5);
		$this->assign('borne_b', intval(strftime("%Y"))-10);
		$f = fopen(sprintf("http://10.10.0.7/biblio/?action=liste_articles_espece_json&id_espece=%d", $_GET['id']),"r");
		if ($f) {
			$data = '';
			while ($r = fgets($f)) 
				$data.=$r;
			fclose($f);
			$articles = json_decode($data);
			$this->assign_by_ref('docs', $articles);
		} else {
			$this->assign('docs',false);
		}

		$this->assign_by_ref("l_aisne", $espece->entrepot_liste_communes_presence("2"));
		$this->assign_by_ref("l_oise", $espece->entrepot_liste_communes_presence("80"));
		$this->assign_by_ref("l_somme", $espece->entrepot_liste_communes_presence("02"));
	}

	protected function before_definitions() {
		$especes = bobs_espece::liste_especes_sensibles($this->db);
		$this->assign_by_ref('ls', $especes);
	}

	protected function before_carte_wfs() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'travaux.php');
		$travail = clicnat_travaux::instance($this->db, $_GET['id']);
		$this->assign_by_ref("travail", $travail);
	}

	protected function before_carte_wms() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'travaux.php');
		$travail = clicnat_travaux::instance($this->db, $_GET['id']);
		$this->assign_by_ref("travail", $travail);
	}

	protected function before_liste_espace_carte_wfs() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'espace.php');
		require_once(OBS_DIR.'wfs.php');
		
		$listes_public = array(3);

		$data = file_get_contents('php://input'); // contenu de _POST
		$doc = new DomDocument();
		@$doc->loadXML($data);
		header('Content-type: text/xml');
		$gf = new clicnat_wfs_get_feature_liste_espace($this->db, $doc);
		$sel = $gf->get_liste_espaces();
		//$u = $this->get_user_session();
		//if (($u->id_utilisateur == $sel->id_utilisateur) || $sel->ref)
		if (array_search($sel->id_liste_espace, $listes_public) !== false)
			echo $gf->reponse()->saveXML();
		else
			//WFS Exception
			throw new Exception('WFS Exception...');
		exit();
	}

	protected function before_ms_communes() {	
		$args = $_SERVER['QUERY_STRING'];
		$width = $_GET['WIDTH'];
		$height = $_GET['HEIGHT'];
		$bbox = $_GET['BBOX'];
		$layers = "LAYERS=mer%2Ccommunes_n_esp%2Climite_adm";
		$url = "http://localhost/cgi-bin/mapserv?map=/carto/atlas.map&{$layers}&FORMAT=image%2Fjpeg&TRANSPARENT=false&DPI=96&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&EXCEPTIONS=application%2Fvnd.ogc.se_inimage&SRS=EPSG%3A2154&BBOX=$bbox&WIDTH=$width&HEIGHT=$height";
	    $ch = curl_init();
	    
	    curl_setopt($ch, CURLOPT_URL, $url);
	    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);	   
	    $output = curl_exec($ch);
	    
	    if (!empty($output)) {
			header('Content-type: '.curl_getinfo($ch, CURLINFO_CONTENT_TYPE));
			echo $output;
	    } else {
			echo $url;
	    }
	    curl_close($ch);
	    exit();
	}
	
	protected function before_geocode() {
		require_once(OBS_DIR.'espace.php');
		bobs_element::cli($_GET['lat']);
		bobs_element::cli($_GET['lon']);
		$wkt = sprintf('POINT(%s %s)',$_GET['lon'], $_GET['lat']);
		$c = bobs_espace_commune::get_commune_for_point($this->db, $wkt, 2154);	
		$this->assign_by_ref('commune',$c);
	}

	protected function before_geocode_lien() {
		require_once(OBS_DIR.'espace.php');
		bobs_element::cls($_GET['lat']);
		bobs_element::cls($_GET['lon']);
		$wkt = sprintf('POINT(%s %s)',$_GET['lon'], $_GET['lat']);
		$c = bobs_espace_commune::get_commune_for_point($this->db, $wkt);	
		if (!$c) echo "pas de commune trouvée ici : longitude {$_GET['lon']} latitude {$_GET['lat']}";
		else echo "Voir cette commune : <a href=\"?page=commune&id={$c['id_espace']}\">{$c['nom']}</a>";
		exit();
	}

	protected function before_commune() {
		bobs_element::cli($_GET['id']);
		if (empty($_GET['id']))
		    throw new InvalidArgumentException('numéro de commune');
		require_once(OBS_DIR.'espace.php');
		
		$espace = get_espace_commune($this->db, $_GET['id']);
		$this->caching = 2;
		$this->cache_lifetime = 86400;
		$this->compile_check = false;
		$classes_libs = array();
		if (isset($_GET['recalcul'])) {
			$this->clear_cache('commune.tpl', $espace->id_espace);
			$this->clear_compiled_tpl('commune.tpl');
		}
		if (!$this->is_cached('commune.tpl', $espace->id_espace)) {
			$classes = bobs_espece::get_classes();
			$compteurs = array();
			foreach ($classes as $c) {
				$compteurs[$c]['n'] = 0;
				$compteurs[$c]['nc'] = 0;
				$classes_libs[$c] = $compteurs[$c]['lib'] = bobs_espece::get_classe_lib_par_lettre($c);
				$compteurs[$c]['classe'] = $c;
			}
			
			$especes = $espace->get_liste_especes();
			
			foreach ($especes as $e) {
				$compteurs[$e['classe']]['n']++;
				$esp = get_espece($this->db, $e);
				if (!$esp->get_restitution_ok(bobs_espece::restitution_public))
					$compteurs[$e['classe']]['nc']++;
			}
			$this->assign('groupes', bobs_espece::get_classes());
			$this->assign_by_ref('liste_especes', $especes);
			$this->assign_by_ref('n_especes', count($especes));
			$this->assign_by_ref('compteurs', $compteurs);
			$this->assign_by_ref('commune', $espace);
			$this->assign_by_ref('titre_page', $espace);
			$this->assign_by_ref('classes_libs', $classes_libs);
		}
		parent::display('commune.tpl', $espace->id_espace);
		exit();
	}

	/**
	 * @brief liste des espèces en liste rouge
	 */
	protected function before_rl() {
		require_once(OBS_DIR.'espece.php');
		$especes = bobs_espece::liste_rouge($this->db);
		$this->assign_by_ref('rl', $especes);
		$this->assign('titre_page', 'Liste rouge régionale');
	}

	/**
	 * @brief liste des espèces sensibles
	 */
	protected function before_ls() {
		require_once(OBS_DIR.'espece.php');
		$especes = bobs_espece::liste_sensibles($this->db);
		$this->assign_by_ref('ls', $especes);
		$this->assign('titre_page', 'Liste des espèces sensibles');
	}

	protected function before_liste_csv() {
		require_once(OBS_DIR.'espece.php');
		switch ($_GET['liste']) {
			case 'ls':
				$especes = bobs_espece::liste_sensibles($this->db);
				break;
			case 'rl':
				$especes = bobs_espece::liste_rouge($this->db);
				break;
			case 'li':
				$especes = bobs_espece::liste_invasives($this->db);
				break;
		}
		$fname = tempnam("/tmp", "liste_espece");
		$f = fopen($fname, "w");
		$especes->csv($f);
		fclose($f);
		header("Content-type: text/csv; charset=UTF-8");
		echo file_get_contents($fname);
		unlink($fname);
		exit();
	}

	/**
	 * @brief liste des espèces invasives
	 */
	protected function before_li() {
		require_once(OBS_DIR.'espece.php');
		$especes = bobs_espece::liste_invasives($this->db);
		$this->assign_by_ref('li', $especes);
		$this->assign('titre_page', 'Liste des espèces sensibles');
	}
	
	protected function before_classe() {
		require_once(OBS_DIR.'espece.php');
		$classe = new bobs_classe($this->db, $_GET['classe']);
		$this->assign_by_ref('classe', $classe);
	}

	/**
	 * @brief redirection code insee vers commune pn
	 */
	protected function before_commune_par_code_insee() {
		require_once(OBS_DIR.'espace.php');
		bobs_element::cli($_GET['id']);
		if ($_GET['id'] > 0) {
			$commune = bobs_espace_commune::by_code_insee($this->db, $_GET['id']);
			if (!empty($commune->id_espace)) {
				header('Location: ?page=commune&id='.$commune->id_espace);
				echo "Redirection en cours...\n";
				exit();
			}
		}
		echo "Code introuvable";    	
		exit();
	}
    
	protected function before_autocomplete_espece() {
		bobs_element::cls($_GET['term']);
		require_once(OBS_DIR.'espece.php');
		$sans_image = isset($_GET['sans_image']);
		$t = bobs_espece::recherche_par_nom($this->db, $_GET['term']);
		$r = array();
		foreach ($t as $esp) {
			$r[] = array(
		    		'label'=> ($sans_image?"{$esp['nom_f']} {$esp['nom_s']}":$esp['nom_f'].'<br/><i>'.$esp['nom_s'].'</i>'), 
				'value' => $esp['id_espece'],
				'classe' => strtolower($esp['classe'])
			);
		}

		$t_obj = bobs_espece::index_recherche($this->db, $_GET['term']);
		foreach ($t_obj['especes'] as $obj) {
			$r[] = array(
				'label' => ($sans_image?"{$obj->nom_f} {$obj->nom_s}":"{$obj->nom_f} <br/><i>{$obj->nom_s}</i>"),
				'value' => $obj->id_espece,
				'classe' => strtolower($obj->classe)
			);
		}
		
		foreach($r as $k=>$v) {
			$r[$k]['label'] = $sans_image?$r[$k]['label']:"<img style=\"float:right;\" src=\"image/30x30_g_{$r[$k]['classe']}.png\"/>{$r[$k]['label']}";
		}

		echo json_encode($r);
		exit();
	}
	
	protected function before_partenaires() {
		$this->assign('n_observateurs', file_get_contents('/var/cache/bobs/promontoire.n_observateurs'));
		$this->assign('n_observateurs_2006', file_get_contents('/var/cache/bobs/promontoire.n_observateurs_2006'));
		$n_total = file_get_contents('/var/cache/bobs/promontoire.n_citations');
		$this->assign('n_citations', $n_total);
		$this->assign('maj', file_get_contents('/var/cache/bobs/promontoire.maj'));
		$this->assign('titre_page', 'Partenaires');
		$n_autre = file_get_contents('/var/cache/bobs/promontoire.nb_obs_pro_autre');
		$n_pro_pn = file_get_contents('/var/cache/bobs/promontoire.nb_obs_pro_pn');
		$this->assign('nb_obs_pro_autre', $n_pro);
		$this->assign('nb_obs_pro_pn', $n_pro_pn);

		$this->assign('pourcentage_benevole_pn', round(($n_total-$n_autre-$n_pro_pn)*100/$n_total));
		$this->assign('pourcentage_pro_pn', round($n_pro_pn*100/$n_total));
		$this->assign('pourcentage_autre', round($n_autre*100/$n_total));
	}

	protected function before_img_esp() {
		require_once(OBS_DIR.'/docs.php');
		header('Cache-Control: public, max-age=864000');
		header('Expires:');
		header('Pragma:');
		$im = new bobs_document_image($_GET['id']);
		$im->get_image_redim(250,0);
		exit();
	}

	protected function before_img_esp_grand() {
		require_once(OBS_DIR.'/docs.php');
		header('Cache-Control: public, max-age=864000');
		header('Expires:');
		header('Pragma:');
		$im = new bobs_document_image($_GET['id']);
		$im->get_image_redim(600,0);
		exit();
	}

	protected function before_audio() {
		require_once(OBS_DIR.'/'.'docs.php');
		$doc = new bobs_document_audio($_GET['id']);
		$doc->get_audio();
		exit();
	}

	protected function before_carte_communes() {
		$this->assign('maj', file_get_contents('/var/cache/bobs/promontoire.maj'));
		$this->assign('titre_page', 'Carte régionale');
	}
    
	/**
	* @brief affiche la page
	* @global integer $start_time
	*/
	public function display() {
		global $start_time;
		
		if (isset($_GET['PAGE']))
			$_GET['page'] = $_GET['PAGE'];

		session_start();
		if (array_key_exists('moijepeux', $_GET)) {
			$_SESSION['autorise'] = true;
		}
		$_SESSION['autorise'] = true;
		if (!array_key_exists('autorise', $_SESSION) && $_GET['page'] != 'ms_atlas') {
			$_GET['page'] = 'accueil_tmp';	
		}
		$this->assign('page', $this->template());
		$before_func = 'before_'.$this->template();
		if (method_exists($this, $before_func))
			$this->$before_func();
		$this->assign('tps_exec_avant_display', sprintf("%0.4f", microtime(true) - $start_time));
		parent::display($this->template().'.tpl');
	}

	/**
	* @brief retourne le nom du template a utiliser en fonction de $_GET['page']
	* @return string
	*/
	public function template() {
		bobs_element::cls($_GET['page']);
		if (empty($_GET['page'])) $_GET['page'] = 'accueil';
		return $_GET['page'];
	}
}

require_once(DB_INC_PHP);
get_db($db);
$promontoire = new Promontoire($db);
$promontoire->display();
?>

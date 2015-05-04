<?php
/**
 * Promontoire
 *
 * Mise à disposition au public du compte rendu de la base
 */

$start_time = microtime(true);
$disallow_dump = false;
$context = 'promontoire';

if (file_exists('config.php'))
	require_once('config.php');
else
	require_once('/etc/baseobs/config.php');

define('SESS', 'PROMONTOIRE2');
define('LOCALE', 'fr_FR.UTF-8');

if (!defined('ID_TRAVAIL_CARTE_COMMUNES'))
	define('ID_TRAVAIL_CARTE_COMMUNES', 7);

if (!defined('ID_TRAVAIL_CARTE_RESEAUX'))
	define('ID_TRAVAIL_CARTE_RESEAUX', 8);

if (!defined('PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX')) 
	define('PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX',227);
if (!defined('PROMONTOIRE2_ID_SELECTION_CARTO_RESEAUX')) 
	define('PROMONTOIRE2_ID_SELECTION_CARTO_RESEAUX', 15572);

if (!defined('URL_API'))
	define('URL_API', 'https://ssl.picardie-nature.org/api-clicnat/');

require_once(SMARTY_DIR.'Smarty.class.php');
require_once(OBS_DIR.'element.php');
require_once(OBS_DIR.'espece.php');
require_once(OBS_DIR.'smarty.php');
require_once(OBS_DIR.'travaux.php');

$context = "promontoire";

if (!file_exists(SMARTY_CACHEDIR_PROMONTOIRE2)) {
	mkdir(SMARTY_CACHEDIR_PROMONTOIRE2);
}

class Promontoire extends clicnat_smarty {
	protected $db;
    
	public function __construct($db) {
		setlocale(LC_ALL, LOCALE);	
		parent::__construct($db, SMARTY_TEMPLATE_PROMONTOIRE2, SMARTY_COMPILE_PROMONTOIRE2, SMARTY_CACHEDIR_PROMONTOIRE2, '/tmp/clicnat_cache_public2');
		$this->assign('niveau_restitution', bobs_espece::restitution_public);
	}

	protected function before_travaux() {
		$this->assign('travaux', clicnat_travaux::liste($this->db));
		self::header_cacheable(600);
	}

	protected function before_fiche() {
		self::header_cacheable(3600);
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
		$this->assign_by_ref("l_oise", $espece->entrepot_liste_communes_presence("60"));
		$this->assign_by_ref("l_somme", $espece->entrepot_liste_communes_presence("80"));

		// legislation
		$f = file_get_contents("textes_legislation_retenus.txt");
		$textes = explode("\n",$f);
		$this->assign_by_ref("textes_legislation_retenus", $textes);
	}

	protected function before_kml_repartition() {
		$url = sprintf("%s?action=taxon_repartition_kml&id=%d", URL_API, $_GET['id']);
		self::header_kml();
		self::header_filename(sprintf("repartition_esp_id%d_%s.kml", $_GET['id'], strftime("%Y%m%d")));
		self::header_cacheable(3600*3);
		echo file_get_contents($url);
		exit();
	}

	protected function before_fiche_communes_csv() {
		bobs_element::cli($_GET['id']);
		$fo = fopen("php://output","w");

		if (!$fo)
			throw new Exception('fo');
		if (empty($_GET['id']))
			throw new InvalidArgumentException('numéro espèce');

		require_once(OBS_DIR.'espece.php');

		$espece = get_espece($this->db, $_GET['id']);

		if (!$espece)
			throw new Exception('espèce inconnue');

		if (!$espece->get_restitution_ok(bobs_espece::restitution_public))
			throw new Exception('espèce sensible');

		$nom = strtolower($espece->__toString());
		$nom = str_replace(array(" ;,'"), array("____"),$nom);
		self::header_csv("communes_$nom.csv");
		self::header_cacheable(3600*3);
		fputcsv($fo,array("code_insee","nom","dernière année","url"));
		foreach (array("2","60","80") as $dept) {
			$l = $espece->entrepot_liste_communes_presence($dept);
			foreach ($l as $commune) {
				$ec = get_espace_commune($this->db, $commune['id_espace']);
				fputcsv($fo, array(
					sprintf("%02d%03d", $ec->dept,$ec->code_insee),
					$ec->nom2,
					$commune["ymax"],
					"http://www.clicnat.fr/?page=commune&id={$commune['id_espace']}"
				));
			}
		}
		fclose($fo);
		exit();
	}

	protected function before_definitions() {
		$especes = bobs_espece::liste_especes_sensibles($this->db);
		$this->assign_by_ref('ls', $especes);
		self::header_cacheable(3600*3);
	}

	protected function before_carte_wfs() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'travaux.php');

		switch ($_GET['id']) {
			case ID_TRAVAIL_CARTE_COMMUNES:
				$this->redirect('?page=carte_communes');
				break;
			case ID_TRAVAIL_CARTE_RESEAUX:
				$this->redirect('?page=carte_reseaux');
				break;
			default:
				$travail = clicnat_travaux::instance($this->db, $_GET['id']);
				$this->assign_by_ref("travail", $travail);
				break;
		}
		self::header_cacheable(3600*3);
	}

	protected function before_carte_kml() {
		$url = sprintf("%s?action=espaces_liste_publique_kml&id_liste=%d", URL_API, $_GET['id']);
		self::header_kml();
		self::header_filename(sprintf("espaces_liste_%d_%s.kml", $_GET['id'], strftime("%Y%m%d")));
		self::header_cacheable(3600*3);
		echo file_get_contents($url);
		exit();
	}

	protected function before_carte_communes() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'travaux.php');
		$classes = array();
		foreach (bobs_classe::get_classes() as $c) {
			$classes[$c] = bobs_classe::get_classe_lib_par_lettre($c, true);
		}
		$travail = clicnat_travaux::instance($this->db, ID_TRAVAIL_CARTE_COMMUNES);
		$this->assign_by_ref("travail", $travail);
		$this->assign_by_ref('classes', $classes);
		self::header_cacheable(3600*3);
	}

	protected function before_carte_reseaux() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'travaux.php');
		$travail = clicnat_travaux::instance($this->db, ID_TRAVAIL_CARTE_RESEAUX);
		$reseaux = bobs_reseau::liste_reseaux($this->db);
		$this->assign_by_ref("travail", $travail);
		$this->assign_by_ref('reseaux', $reseaux);
		self::header_cacheable(3600*3);
	}

	protected function before_carte_wms() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'travaux.php');
		$travail = clicnat_travaux::instance($this->db, $_GET['id']);
		$this->assign_by_ref("travail", $travail);
	}

	private function espace_carte_wfs_cache_file($id_liste) {
		return "/tmp/espace_carte_wfs_getfeature_$id_liste.xml";
	}
	
	private function espace_carte_sld_cache_file($id_liste) {
		return "/tmp/espace_carte_sld_$id_liste.xml";
	}

	protected function before_liste_espace_carte_wfs() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'espace.php');
		require_once(OBS_DIR.'wfs.php');
		
		$listes_public = array(3,224,234,PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX);

		$data = file_get_contents('php://input'); // contenu de _POST
		$doc = new DomDocument();
		@$doc->loadXML($data);
		self::header_xml();
		self::header_cacheable(3600*3);
		$gf = new clicnat_wfs_get_feature($this->db, $doc);
		$sel = $gf->get_liste_espaces();
		if (array_search($sel->id_liste_espace, $listes_public) !== false) {
			$fichier_cache = $this->espace_carte_wfs_cache_file($sel->id_liste_espace);
			if (!file_exists($fichier_cache))
				file_put_contents($fichier_cache, $gf->reponse()->saveXML());
			header('Content-Length: '.filesize($fn));
			echo file_get_contents($fichier_cache);
			exit(0);
		} else {
			//WFS Exception
			throw new Exception('WFS Exception...');
		}
		exit();
	}
	
	protected function before_commune() {
		bobs_element::cli($_GET['id']);
		if (empty($_GET['id']))
		    throw new InvalidArgumentException('numéro de commune');
		require_once(OBS_DIR.'espace.php');
		$espace = get_espace_commune($this->db, $_GET['id']);
		$classes = bobs_espece::get_classes();
		$compteurs = array();
		foreach ($classes as $c) {
			$compteurs[$c]['n'] = 0;
			$compteurs[$c]['nc'] = 0;
			$classes_libs[$c] = $compteurs[$c]['lib'] = bobs_espece::get_classe_lib_par_lettre($c);
			$compteurs[$c]['classe'] = $c;
		}
		$especes = $espace->entrepot_liste_especes();
		$especes->trier_par_classe_ordre_famille_nom();
		foreach ($especes as $esp) {
			if (!$esp->exclure_restitution) {
				$compteurs[$esp->classe]['n']++;
				if (!$esp->get_restitution_ok(bobs_espece::restitution_public))
					$compteurs[$esp->classe]['nc']++;
			}
		}
		$this->assign('groupes', bobs_espece::get_classes());
		$this->assign_by_ref('liste_especes', $especes);
		$this->assign_by_ref('n_especes', $especes->count());
		$this->assign_by_ref('compteurs', $compteurs);
		$this->assign_by_ref('commune', $espace);
		$this->assign_by_ref('titre_page', $espace);
		$this->assign_by_ref('classes_libs', $classes_libs);
		self::header_cacheable(3600*3);
	}

	protected function before_commune_especes_csv() {
		$espace = get_espace_commune($this->db, (int)$_GET['id']);
		self::header_csv("especes_{$espace->nom}.csv");
		self::header_cacheable(3600*3);
		$f = fopen("php://output","w");
		$cols = array("id_espece","cd_nom","classe","ordre","famille","nom_s","nom_v","menace","rarete","pas_affiché_liste");
		fputcsv($f, $cols);
		$especes = $espace->entrepot_liste_especes();
		$especes->trier_par_classe_ordre_famille_nom();
		foreach ($especes as $espece) {
			if (!$espece->get_restitution_ok(bobs_espece::restitution_public))
				continue;
			$refreg = $espece->get_referentiel_regional();
			$ligne = array(
				$espece->id_espece,
				$espece->taxref_inpn_especes,
				$espece->get_classe_lib_par_lettre($espece->classe),
				$espece->ordre,
				$espece->famille,
				$espece->nom_s,
				$espece->nom_f,
				isset($refreg['categorie'])?$refreg['categorie']:'',
				isset($refreg['indice_rar'])?$refreg['indice_rar']:'',
				$espece->exclure_restitution
			);
			fputcsv($f, $ligne);
		}
		fclose($f);
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
		self::header_cacheable();
	}

	/**
	 * @brief liste des espèces sensibles
	 */
	protected function before_ls() {
		require_once(OBS_DIR.'espece.php');
		$especes = bobs_espece::liste_sensibles($this->db);
		$this->assign_by_ref('ls', $especes);
		$this->assign('titre_page', 'Liste des espèces sensibles');
		self::header_cacheable();
	}

	/*
	 * @brief liste des espèces sensibles
	 */
	protected function before_lz() {
		require_once(OBS_DIR.'espece.php');
		$especes = bobs_espece::liste_determinantes_znieff($this->db);
		$this->assign_by_ref('lz', $especes);
		$this->assign('titre_page', 'Liste des espèces déterminantes ZNIEFF');
		self::header_cacheable();
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
			case 'lz':
				$especes = bobs_espece::liste_determinantes_znieff($this->db);
				break;
			default:
				throw new Exception('liste inconnue');
		}
		$fname = tempnam("/tmp", "liste_espece");
		$f = fopen($fname, "w");
		$especes->csv($f);
		fclose($f);
		self::header_csv("liste_espece_{$_GET['liste']}.csv", filesize($fname));
		echo file_get_contents($fname);
		unlink($fname);
		self::header_cacheable();
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
		self::header_cacheable();
	}
	
	protected function before_classe() {
		require_once(OBS_DIR.'espece.php');
		$classe = new bobs_classe($this->db, $_GET['classe']);
		$this->assign_by_ref('classe', $classe);
		self::header_cacheable(3600);
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
	
	protected function before_wfs() {
		require_once(OBS_DIR.'wfs.php');
		self::header_xml();
		self::header_cacheable(3600*3);
		$op = clicnat_wfs_op($this->db, $_GET);
		echo $op->reponse()->saveXML();
		exit();
		
	}
	
	protected function before_partenaires() {
		self::header_cacheable(86400*10);
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
		$im = new bobs_document_image($_GET['id']);
		if ($im->est_en_attente())
			throw new Exception("pas encore vérifiée");
		self::header_cacheable(86400*10);
		$im->get_image_redim(250,0);
		exit();
	}

	protected function before_img_esp_grand() {
		require_once(OBS_DIR.'/docs.php');
		$im = new bobs_document_image($_GET['id']);
		if ($im->est_en_attente())
			throw new Exception("pas encore vérifiée");
		self::header_cacheable(86400*10);
		$im->get_image_redim(600,0);
		exit();
	}

	protected function before_audio() {
		require_once(OBS_DIR.'/'.'docs.php');
		$doc = new bobs_document_audio($_GET['id']);
		$doc->get_audio();
		exit();
	}

	public function before_occtax() {
		/* Rewrite rules:
		 * 	RewriteEngine on
		 * 	RewriteRule ^(.*)/occtax/(.*)$ $1/?page=occtax&guid=$2 [PT]
		 */
		try {
			self::header_xml();
			if (!isset($_GET['guid']))
				throw new Exception('guid');

			require_once(OBS_DIR.'sinp.php');

			$citation = bobs_citation::by_guid($this->db, $_GET['guid']);
			$doc = new DOMDocument('1.0','utf-8');
			$doc->formatOutput = true;
			$root = $doc->createElement("Collection");
			$root->setAttributeNs(GML_NS_URL, 'gml:id', "root");
			$c_sinp = new clicnat_citation_export_sinp($this->db, $citation->id_citation);
			$root->appendChild($c_sinp->occurence($doc,true));
			$doc->appendChild($root);
			echo $doc->saveXML();
			exit();
		} catch (Exception $e) {
			self::header_404();
			echo "<i>occurence inconnue</i>";
		}
	}

	protected function before_sld_communes() {
		self::header_xml();
		$travail = get_travail($this->db, ID_TRAVAIL_CARTE_COMMUNES);
		$liste_espace = $travail->liste_espace();
		require_once("classes.php");
		$params = array(
			"styles" => $classes,
			"layername" => "liste_espace_{$liste_espace->id_liste_espace}"
		);
		require_once(OBS_DIR.'sld.php');
		echo clicnat_sld_rampe::xml($params);
		exit();
	}

	protected function before_sld_reseaux() {
		require_once(OBS_DIR.'sld.php');

		$fichier_cache = $this->espace_carte_sld_cache_file(PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX);
		
		if (!file_exists($fichier_cache)) {
			$liste_espaces = new clicnat_listes_espaces($this->db, PROMONTOIRE2_ID_LISTE_CARTO_RESEAUX);
	
			$doc = clicnat_sld_rampe::liste_espaces_attrs_min_max($liste_espaces, "/(.+)_species/", 8, 120);
			$doc->formatOutput = true; 
			file_put_contents($fichier_cache, $doc->saveXML());
		}
		self::header_xml();
		echo file_get_contents($fichier_cache);
		exit();
	}

	protected function before_accueil() {
		self::header_cacheable(3600);
	}

	protected function before_listes() {
		self::header_cacheable(3600);
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

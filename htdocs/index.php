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
		$this->assign_by_ref("l_oise", $espece->entrepot_liste_communes_presence("60"));
		$this->assign_by_ref("l_somme", $espece->entrepot_liste_communes_presence("80"));

		// legislation
		$f = file_get_contents("textes_legislation_retenus.txt");
		$textes = explode("\n",$f);
		$this->assign_by_ref("textes_legislation_retenus", $textes);


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
		$this->header_csv("communes_$nom.csv");
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
	}

	protected function before_carte_wfs() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'travaux.php');

		if ($_GET['id'] == ID_TRAVAIL_CARTE_COMMUNES)
			$this->redirect('?page=carte_communes');

		$travail = clicnat_travaux::instance($this->db, $_GET['id']);
		$this->assign_by_ref("travail", $travail);
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
		
		$listes_public = array(3,224,234);

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
			$compteurs[$esp->classe]['n']++;
			if (!$esp->get_restitution_ok(bobs_espece::restitution_public))
				$compteurs[$esp->classe]['nc']++;
		}
		$this->assign('groupes', bobs_espece::get_classes());
		$this->assign_by_ref('liste_especes', $especes);
		$this->assign_by_ref('n_especes', $especes->count());
		$this->assign_by_ref('compteurs', $compteurs);
		$this->assign_by_ref('commune', $espace);
		$this->assign_by_ref('titre_page', $espace);
		$this->assign_by_ref('classes_libs', $classes_libs);
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

	/*
	 * @brief liste des espèces sensibles
	 */
	protected function before_lz() {
		require_once(OBS_DIR.'espece.php');
		$especes = bobs_espece::liste_determinantes_znieff($this->db);
		$this->assign_by_ref('lz', $especes);
		$this->assign('titre_page', 'Liste des espèces déterminantes ZNIEFF');
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
		$this->header_csv("liste_espece_{$_GET['liste']}.csv", filesize($fname));
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

	public function before_occtax() {
		/* Rewrite rules:
		 * 	RewriteEngine on
		 * 	RewriteRule ^(.*)/occtax/(.*)$ $1/?page=occtax&guid=$2 [PT]
		 */
		try {
			$this->header_xml();
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
			$this->header_404();
			echo "<i>occurence inconnue</i>";
		}
	}

	protected function before_sld_communes() {
		self::header_xml();
		require_once("classes.php");
		$params = array(
			"styles" => $classes,
			"layername" => "liste_espace_124"
		);
		require_once(OBS_DIR.'sld.php');
		echo clicnat_sld_rampe::xml($params);
		exit();
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

{include file=head.tpl}
<script type="text/javascript" src="http://deco.picardie-nature.org/proj4js/lib/proj4js-compressed.js"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/OpenLayers-2.12/OpenLayers.js"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/carto.js"></script>
{assign var=espece_inpn value=$espece->get_inpn_ref()}
{assign var=referentiel value=$espece->get_referentiel_regional()}
{literal}
<style>
div.onglet_fiche_espece {
	display:none;
}
#carte {
	width:100%;
	height:400px;
}
</style>
<script>
function fiche_espece_onglet_actif(id) {
	$('.onglet_fiche_espece').hide();
	$('#'+id).show();
}

function layer_repartition(id_espece) {
	var resolution = 5000;
	var l = new OpenLayers.Layer.Vector("Répartition par année", {
		strategies: [new OpenLayers.Strategy.Fixed(), new OpenLayers.Strategy.Filter()],
		projection: new OpenLayers.Projection("EPSG:2154"),
		protocol: new OpenLayers.Protocol.WFS({
			"url": "/wfs_repartition",
			"featureType": "species"+id_espece+"crs2154res"+resolution+"m",
			"featureNS": "http://mapserver.gis.umn.edu/mapserver",
			"srsName": "EPSG:2154",
			"version": "1.1.0",
		})
	});
	l.events.register("featuresadded",null,function (e) {
		// ajout des couches déduites de celle-ci
		var l5 = layer_repartition_5ans(e.features);
		l.setVisibility(false);
		l.map.addLayers(l5);
	});
	l.refresh();
	return l;
}

function layer_repartition_5ans(features) {
	var b2 = 2013-5;
	var b1 = 2013-10;
	var l1 = new OpenLayers.Layer.Vector("avant "+b1, { projection: new OpenLayers.Projection("EPSG:2154") });
	var l2 = new OpenLayers.Layer.Vector("entre "+b1+" et "+b2, { projection: new OpenLayers.Projection("EPSG:2154") });
	var l3 = new OpenLayers.Layer.Vector("après "+b2, { projection: new OpenLayers.Projection("EPSG:2154") });
	var carres_ids = {"p1":{},"p2":{},"p3":{}};
	var carres_geoms = {"p1":[],"p2":[],"p3":[]};
	for (var i=0; i<features.length; i++) {
		var y = parseInt(features[i].data["annee"]);
		var id_carre = features[i].data["x0"]+"."+features[i].data["y0"];
		var per = "p3";
		if (y < b1) {
			per = "p1";
		} else if (y >=b1 && y <= b2) {
			per = "p2";
		}
		if (carres_ids[per][id_carre])
			continue;
		carres_ids[per][id_carre] = true;
		carres_geoms[per].push(new OpenLayers.Feature.Vector(features[i].geometry.clone()));
	}
	l3.addFeatures(carres_geoms["p3"]);
	l2.addFeatures(carres_geoms["p2"]);
	l1.addFeatures(carres_geoms["p1"]);
	return [l1,l2,l3];
}

var carte = false;
function page_fiche_init() {
	$(".b_onglets").click(function (evt) {
		var lien = $(this);
		var li = lien.parent();
		var ul = li.parent();
		ul.children().removeClass('active');
		li.addClass('active');
		fiche_espece_onglet_actif(lien.attr("onglet"));
		console.log(lien.attr("onglet"));
		if (lien.attr("onglet") == "fiche_repartition") {
			if (!carte) {
				var id_espece = $('#espece').attr('id_espece');
				carte = new Carto('carte');
				var m  = carte.map;
				var la= layer_repartition(id_espece);
				m.addLayers([layer_repartition(id_espece)]);
	//			m.addLayers(layer_repartition_5ans(la));
			}
		}
	});
	fiche_espece_onglet_actif("fiche_resume");
}

$(document).ready(page_fiche_init);
</script>
{/literal}
<div style="display:none;">
	<div id="dlg-legende" title="En savoir plus sur les classes utilisées">
		<b>Dernière observation avant {$borne_b}</b>
		<p>Les données de plus de 10 ans sont considérées comme très anciennes
		   de part l'évolution des milieux qui a pu survenir durant ce laps
		   de temps, le changement de statuts des espèces, etc.</p>
		<b>Dernière observation entre {$borne_b} et {$borne_a}</b>
		<p>Une donnée remontant à plus de 5 ans
		   mérite actualisation afin de vérifier la présence ou l'absence de
		   l'espèce.</p>
		<b>Dernière observation après {$borne_a}</b>
		<p>Les données naturalistes de moins de 5 ans
		   peuvent être considérées comme des données récentes. L'actualisation
		   des informations est ici moins prioritaire, hormis pour les espèces
		   en liste rouge régionale.</p>		  
	</div>
	<div id="dlg-photos" title="{$espece}"></div>
</div>

<div class="row">
	<div class="col-sm-12">
		<h1 id="espece" id_espece="{$espece->id_espece}">
			<img src="image/30x30_g_{$espece->classe|lower}.png"/>
			{if !$espece->nom_f}
				{$espece->nom_s}
			{else}
				{$espece->nom_f} <small><i>{$espece->nom_s}</i></small>
			{/if}
			<a href="#" id="btn_rech" class="btn btn-default"><span class="glyphicon glyphicon-search"></span></a>
		</h1>
	</div>
	<div class="well" id="div_rech_espece" style="display:none;">
		<div class="form-group">
			<label for="in_espece">Rechercher une espèce</label>
			<input class="form-control" type="text" id="in_espece" placeholder="{$espece}">
		</div>
	</div>
</div>
<div class="row">
	<div class="col-sm-12">
		<ul class="nav nav-tabs nav-justified">
			<li class="active"><a class="b_onglets" href="#" onglet="fiche_resume">Présentation</a></li>
			<li><a class="b_onglets" href="#" onglet="fiche_medias">Médias</a></li>
			<li><a class="b_onglets" href="#" onglet="fiche_repartition">Répartition géographique</a></li>
			<li><a class="b_onglets" href="#" onglet="fiche_statut">Statut</a></li>
			<li><a class="b_onglets" href="#" onglet="fiche_biblio">Bibliographie</a></li>
		</ul>
	</div>
</div>
<div class="row onglet_fiche_espece" id="fiche_resume">
	<div class="col-sm-3">
		{assign var=image_aff_ok value=0}
		{foreach from=$espece->documents_liste() item=img}
			{if $image_aff_ok eq 0}
				{if !$img->est_en_attente()}
					{if $img->get_type() == 'image'}
						<img style="width:100%; height:100%;" src="?page=img_esp&id={$img->get_doc_id()}"∕>
						{assign var=image_aff_ok value=1}
					{/if}
				{/if}
			{/if}
		{/foreach}
		{if $image_aff_ok eq 0}
			Pas de photos pour illustrer cette fiche
		{/if}
	</div>

</div>
<div class="row onglet_fiche_espece" id="fiche_medias">
	<div class="col-sm-12">
		{foreach from=$espece->documents_liste() item=img}
			{if !$img->est_en_attente()}
				{if $img->get_type() == 'image'}
					<img src="?page=img_esp&id={$img->get_doc_id()}"∕>
				{/if}
			{/if}
		{/foreach}
		{if $image_aff_ok eq 0}
			Pas de photos pour illustrer cette fiche
		{/if}
	</div>
</div>
<div class="row onglet_fiche_espece" id="fiche_repartition">
	<div class="col-sm-10">
		<div id="carte">
		</div>
	</div>
	<div class="col-sm-3">
	</div>
</div>
<div class="row onglet_fiche_espece" id="fiche_statut">
	<div class="col-sm-6">
		<h1>Statut</h1>
		<table class="table">
				{if $referentiel.statut_origine}
				<tr>
					<td>Statut d'origine</td>
					<td><a target="_blank" href="?page=definitions#gl_statut_org">{$referentiel.statut_origine}</a></td>
				</tr>
				{/if}
				{if $referentiel.statut_bio}
				<tr>
					<td>Statut biologique</td>
					<td><a target="_blank" href="?page=definitions#gl_statut_bio">{$referentiel.statut_bio}</a></td>
				</tr>
				{/if}
				{if $referentiel.indice_rar}
				<tr>
					<td>Indice de rareté</td>
					<td><a target="_blank" href="?page=definitions#gl_indice_rare">{$espece->get_indice_rar_lib($referentiel.indice_rar)}</a></td>
				</tr>
				{/if}
				{if $referentiel.niveau_con}
				<tr>
					<td>Niveau de connaissance</td>
					<td><a target="_blank" href="?page=definitions#gl_niveau_conn">{$referentiel.niveau_con}</a></td>
				</tr>
				{/if}
				{if $referentiel.categorie}
				<tr>
					<td>Degré de menace</td>
					<td><a target="_blank" href="?page=definitions#gl_statut_menace">{$espece->get_degre_menace_lib($referentiel.categorie)}</a></td>
				</tr>
				{/if}
				{if $referentiel.etat_conv}
				<tr>
					<td>État de conservation</td>
					<td><a target="_blank" href="?page=definitions#gl_etat_pri_conv">{$referentiel.etat_conv}</a></td>
				</tr>
				{/if}
				{if $referentiel.prio_conv_cat}
				<tr>
					<td>Priorité de conservation</td>
					<td><a target="_blank" href="?page=definitions#gl_etat_pri_conv">{$referentiel.prio_conv_cat}</a></td>
				</tr>
				{/if}
			</table>
	</div>
	<div class="col-sm-6">
		{if $espece->commentaire}
			<h1>Répartition régionale</h1>
			<div>{$espece->commentaire}</div>
		{/if}
		{if $espece->habitat}
			<h1>Habitat principal</h1>
			<div>{$espece->habitat}</div>
		{/if}
		{if $espece->menace}
			<h1>Menaces potentielles</h1>
			<div>{$espece->menace}</div>
		{/if}
		{if $espece->action_conservation}
			<h1>Actions de conservation</h1>
			<div>{$espece->action_conservation}</div>
		{/if}
		{if $espece->commentaire_statut_menace}
			<h1>Commentaires sur le statut de menace</h1>
			<div>{$espece->commentaire_statut_menace}</div>
		{/if}
	</div>
</div>
<div class="row onglet_fiche_espece" id="fiche_biblio">
	<div class="col-sm-12">
		<div>
			{foreach from=$docs item=article}
				<p><a href="http://archives.picardie-nature.org/?action=lecteur&document={$article->id_biblio_document}#page{$article->premiere_page-1}" target="_blank">{$article->titre}</a> <small> paru dans <a href="http://archives.picardie-nature.org/?action=lecteur&document={$article->id_biblio_document}" target="_blank">{$article->titre_doc}</a></small></p>
			{/foreach}
		</div>

	</div>
</div>
{literal}
<script>


</script>
{/literal}
{*
<div class="row">
	<div class="col-sm-3">
		<div class="list-group">
			<a href="#" class="list-group-item">
				Images
			</a>
			<a href="#" class="list-group-item">Répartition géographique</a>
			<a href="#" class="list-group-item">Répartition communale</a>
			<a href="#" class="list-group-item">Statut de l'espèce</a>
			<a href="#" class="list-group-item">Bibliographie</a>
		</div>
	</div>
	<div class="col-sm-9">
	</div>
</div>
*}
{*
<div class="colonne">
	<script>//{literal}
		function ouvre_photo(doc_id) {
			$('#dlg-photos').html('<img src="?page=img_esp_grand&id='+doc_id+'" /><br/><small>Photo : '+auteurs[doc_id]+"</small>");
			$('#dlg-photos').dialog({
				width:620,
				height:520,
				modal:true,
				beforeClose: function (e,u) { J('.olControlPanZoom').css("display", "block"); }
			});
			$('#dlg-photos').css("z-index", "9999");
			$('.olControlPanZoom').css("display", "none");
		}
		var auteurs = new Array();
	//{/literal}
	</script>

	<div style="height:8px;"></div>
	<div class="carousel" id="car">
		<ul>
		{assign var=n_images value=0}
		{assign var=n_sons value=0}
		{foreach from=$espece->documents_liste() item=img}			
			{if !$img->est_en_attente()}
				{if $img->get_type() == 'image'}
				<li>
					{assign var=n_images value=$n_images+1}
					<img src="?page=img_esp&id={$img->get_doc_id()}" onclick="javascript:ouvre_photo('{$img->get_doc_id()}');" />
					<script>auteurs['{$img->get_doc_id()}'] = "{$img->get_auteur()}";</script>
				</li>
				{elseif $img->get_type() == 'audio'}
					{assign var=n_sons value=$n_sons+1}
				{/if}
			{/if}
		{/foreach}				
		{if $n_images == 0}
			<li><img src="image/vide1.png" /></li>
		{/if}
		</ul>
	</div>
	{if $n_images>1}
		{literal}
			<script>
				var f = function () {
					if (!$.browser.webkit) {
						$('#car ul').moodular({dispTimeout:3000});
					} else {
						$('#car li').hide();
						$('#car li:first').show();
						setInterval("suivante()", 4000);
					}
				};


				function suivante() {
					var i_show = -1;
					var i_cache = -1;
					var liste = $('#car li');

					for (var i=0; i<liste.length; i++) {
						if (liste[i].style.display != 'none') {
							i_show = i;
							break;
						}
					}

					if (i_show > -1) {
						if (i_show == liste.length - 1) {
							i_cache = i_show;
							i_show = 0;
						} else {
							i_cache = i_show;
							i_show = i_show + 1;
						}
						$(liste[i_cache]).hide(); 
						$(liste[i_show]).show(); 
					}
				}

				 $(document).ready(f);
			</script>
		{/literal}		
	{/if}
	{if $n_sons > 0}
	    <div style="height:8px;"></div>
	    <h1>Écouter</h1>
	    <div class="colonne-bloc colonne-pied">
		{foreach from=$espece->documents_liste() item=enreg}
			{if $enreg->get_type() eq 'audio'}
				<object type="application/x-shockwave-flash" data="swf/player_mp3_mini.swf" width="200" height="20">
					<param name="movie" value="player_mp3_mini.swf" />
					<param name="bgcolor" value="#C6E548" />
					<param name="FlashVars" value="mp3=%3Fpage%3Daudio%26id%3D{$enreg->get_doc_id()}" />
				</object>
				<div style="display:none" id="d_{$enreg->get_doc_id()}" title="Enregistrement audio">
					enregistrement de {$enreg->get_auteur()}
				</div><br/>
				<small><a href="javascript:;" id="a_{$enreg->get_doc_id()}">à propos de cet enregistrement</a></small><br/>
				<script>
				J('#a_{$enreg->get_doc_id()}').click(function () {literal}{{/literal}
					J('#d_{$enreg->get_doc_id()}').dialog();
				{literal}}{/literal});
				</script>

			{/if}
		{/foreach}
	    </div>
	{/if}
	{if $espece->invasif}
	    <div style="height:8px;"></div>
	    <h1>Statut invasif</h1>
	    <div class="colonne-bloc colonne-pied">
		<a href="?page=li">
			Cette espèce est considérée comme invasive
		</a>
	    </div>
	{/if}
 	{if $referentiel.id_espece > 0}
		{assign var=liste_rouge value=0}
		{if $referentiel.categorie eq 'VU'}{assign var=liste_rouge value=1}{/if}
		{if $referentiel.categorie eq 'EN'}{assign var=liste_rouge value=1}{/if}
		{if $referentiel.categorie eq 'CR'}{assign var=liste_rouge value=1}{/if}
		{if $liste_rouge == 1}
	    		<div style="height:8px;"></div>
			<h1>Espèce menacée</h1>
			<div class="colonne-bloc colonne-pied">
				<a href="?page=rl">Cette espèce est inscrite à la liste rouge régionale</a>
			</div>
		{/if}
	{/if}
	{if $espece_inpn}
	<!-- 
	{assign var=protections value=$espece_inpn->get_protections()}
		{if count($protections)>0}
				<h1>Protection réglementaire</h1>
			    <ul>
			    {foreach from=$espece_inpn->get_protections() item=prot}
					<li><a href="{$prot.url}">{$prot.intitule}{if strlen($prot.article) > 0}<i>- {$prot.article}</i>{/if}</a></li>
			    {/foreach}
			    </ul>
			    <small><a href="http://inpn.mnhn.fr/isb/download/fr/refEspecesReglem.jsp">Source MNHN-INPN</a></small>
		{/if}
	-->
	{/if}
	{if $referentiel.id_espece}
		<div style="height:8px;"></div>
		<h1>Référentiel faune</h1>
		<div class="colonne-bloc colonne-pied">
		<div class="bobs-table">
			<p>Indique le degré de rareté et de menace pour
			 cette espèce en Picardie.
			 Vous pouvez consulter la <a href="http://www.picardie-nature.org/spip.php?article773" target="_blank">page</a> 
			 consacrée au référentiel sur le site de Picardie-Nature pour en savoir plus.
			</p>
		<table width="100%">
			{if $referentiel.statut_origine}
			<tr>
				<td>Statut d'origine</td>
				<td><a target="_blank" href="?page=definitions#gl_statut_org">{$referentiel.statut_origine}</a></td>
			</tr>
			{/if}
			{if $referentiel.statut_bio}
			<tr>
				<td>Statut biologique</td>
				<td><a target="_blank" href="?page=definitions#gl_statut_bio">{$referentiel.statut_bio}</a></td>
			</tr>
			{/if}
			{if $referentiel.indice_rar}
			<tr>
				<td>Indice de rareté</td>
				<td><a target="_blank" href="?page=definitions#gl_indice_rare">{$espece->get_indice_rar_lib($referentiel.indice_rar)}</a></td>
			</tr>
			{/if}
			{if $referentiel.niveau_con}
			<tr>
				<td>Niveau de connaissance</td>
				<td><a target="_blank" href="?page=definitions#gl_niveau_conn">{$referentiel.niveau_con}</a></td>
			</tr>
			{/if}
			{if $referentiel.categorie}
			<tr>
				<td>Degré de menace</td>
				<td><a target="_blank" href="?page=definitions#gl_statut_menace">{$espece->get_degre_menace_lib($referentiel.categorie)}</a></td>
			</tr>
			{/if}
			{if $referentiel.etat_conv}
			<tr>
				<td>État de conservation</td>
				<td><a target="_blank" href="?page=definitions#gl_etat_pri_conv">{$referentiel.etat_conv}</a></td>
			</tr>
			{/if}
			{if $referentiel.prio_conv_cat}
			<tr>
				<td>Priorité de conservation</td>
				<td><a target="_blank" href="?page=definitions#gl_etat_pri_conv">{$referentiel.prio_conv_cat}</a></td>
			</tr>
			{/if}
		</table>
		</div>
		</div>
	{else}
		<div style="height:8px;"></div>
		<h1>Référentiel faune</h1>
		<div class="colonne-bloc colonne-pied">
			Ce taxon n'a pas été inclus dans le référentiel faune
			tel que défini en 2005.<br/>
			Vous pouvez consulter la <a href="http://www.picardie-nature.org/spip.php?article773" target="_blank">page</a> 
			 consacrée au référentiel sur le site de Picardie Nature pour en savoir plus.
		</div>
	{/if}
	{if !$espece->get_restitution_ok($niveau_restitution)}
		<div style="height:8px;"></div>
		<h1>Espèce sensible</h1>
		<div class="colonne-bloc colonne-pied">
			<a href="?page=definitions#gl_sensible">
				Espèce considérée comme sensible dont la localisation communale vous est cachée.
			</a>
		</div>
	{/if}
</div>

<div id="zone_carte">
{if $espece->get_atlas()}
	
		<!-- <img src="?page=fiche_atlas&id={$espece->id_espece}"/> -->
		<div id="carte" style=" width:100%; height:480px;"></div>
		<ul style="float:right; list-style: none; background-color:white; padding:6px; border-style: solid;border-color: red; border-width: 1px;}">
			<li><span style="background-color: red;">&nbsp;&nbsp;&nbsp;</span> observations avant {$borne_b},</li>
			<li><span style="background-color: yellow;">&nbsp;&nbsp;&nbsp;</span> entre {$borne_b} et {$borne_a},</li>
			<li><span style="background-color: #00ff00;">&nbsp;&nbsp;&nbsp;</span> après {$borne_a}.</li>
		</ul>
		<p>Chaque point représente un carré de 5km de côté où au moins une observation a eu lieu,
		la couleur du point vous indiquant l'ancienneté de la dernière observation.</p>
		{literal}
		<a href="javascript:;" onclick="javascript:J('#dlg-legende').dialog({width:320,height:400});">
			En savoir plus sur les classes utilisées			
		</a>.
		{/literal}
	
{else}
	<div class="pas_de_carte_dispo">	
		<h1>Pas de carte disponible</h1>
		<p>Nous n'avons pas encore généré d'atlas pour cette espèce.</p>
	</div>
{/if}
</div>

<div style="clear:both;"></div>

{assign var=ocommunes value=$espece->liste_communes_presentes_2()}
<style> /* {literal} */
/* {/literal} */
</style>
<div>
	{if $espece->get_restitution_ok($niveau_restitution)}
	<div class="tvilles" style="width:50%; float:left;">
		<h1>Liste des communes où l'espèce a été observée</h1>
		<table>
			<tr>
				<th width="33%">
					Aisne
					{assign var=commune_n value=0}
					{foreach from=$ocommunes item=commune}{if $commune.dept == 2}{assign var=commune_n value=$commune_n+1}{/if}{/foreach}
					{if $commune_n > 1}<br/>{$commune_n} communes{/if}
				</th>
				<th width="33%">
					Oise
					{assign var=commune_n value=0}
					{foreach from=$ocommunes item=commune}{if $commune.dept == 60}{assign var=commune_n value=$commune_n+1}{/if}{/foreach}
					{if $commune_n > 1}<br/>{$commune_n} communes{/if}
				</th>
				<th width="33%">
					Somme
					{assign var=commune_n value=0}
					{foreach from=$ocommunes item=commune}{if $commune.dept == 80}{assign var=commune_n value=$commune_n+1}{/if}{/foreach}
					{if $commune_n > 1}<br/>{$commune_n} communes{/if}
				</th>
			</tr>
			<tr>
				<td >
				<div class="tvilles_z">
				{assign var=presence value=0}
				{foreach from=$ocommunes item=commune}					
					{if $commune.dept == 2}
						{assign var=presence value=1}
						<a href="?page=commune&id={$commune.id_espace}" title="{$commune.nom}">{$commune.nom2} <small>({$commune.ymax})</small></a>
					{/if}
				{/foreach}
				{if $presence == 0}Non citée dans ce département{/if}
				</div>
				</td>
				<td>
				<div class="tvilles_z">
				{assign var=presence value=0}
				{foreach from=$ocommunes item=commune}					
					{if $commune.dept == 60}
						{assign var=presence value=1}
						<a href="?page=commune&id={$commune.id_espace}" title="{$commune.nom}">{$commune.nom2} <small>({$commune.ymax})</small></a>
					{/if}
				{/foreach}
				{if $presence == 0}Non citée dans ce département{/if}
				</div>
				</td>		
				<td>
				<div class="tvilles_z">
				{assign var=presence value=0}
				{foreach from=$ocommunes item=commune}					
					{if $commune.dept == 80}
						{assign var=presence value=1}
						<a href="?page=commune&id={$commune.id_espace}" title="{$commune.nom}">{$commune.nom2} <small>({$commune.ymax})</small></a>
					{/if}
				{/foreach}
				{if $presence == 0}Non citée dans ce département{/if}
				</div>
				</td>
			</tr>
		</table>
	</div>
	{/if}
	<div class="desc" style="width:49%; float:left;">
		{if $espece->commentaire}
			<h1>Répartition régionale</h1>
			<div>{$espece->commentaire}</div>
		{/if}
		{if $espece->habitat}
			<h1>Habitat principal</h1>
			<div>{$espece->habitat}</div>
		{/if}
		{if $espece->menace}
			<h1>Menaces potentielles</h1>
			<div>{$espece->menace}</div>
		{/if}
		{if $espece->action_conservation}
			<h1>Actions de conservation</h1>
			<div>{$espece->action_conservation}</div>
		{/if}
		{if $espece->commentaire_statut_menace}
			<h1>Commentaires sur le statut de menace</h1>
			<div>{$espece->commentaire_statut_menace}</div>
		{/if}
		{if $docs}
			<h1>Articles citant cette espèce</h1>
			<div>
				{foreach from=$docs item=article}
					<p><a href="http://archives.picardie-nature.org/?action=lecteur&document={$article->id_biblio_document}#page{$article->premiere_page-1}" target="_blank">{$article->titre}</a> <small> paru dans <a href="http://archives.picardie-nature.org/?action=lecteur&document={$article->id_biblio_document}" target="_blank">{$article->titre_doc}</a></small></p>
				{/foreach}
			</div>
		{/if}
	</div>
</div>
*}
<div style="clear:both;" class="info"> {include file="pas_exhaustif.tpl"} </div>
{include file=foot.tpl}

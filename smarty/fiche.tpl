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
	height:550px;
/*	margin-left:15px;
	margin-right:15px;*/
}
#carte_cont {
	width:100%;
	left:0px;
	top:0px;
	margin-left: 15px;
	height:550px;
	z-index: 0;
	position: absolute;
}
.overflow-300px {
	height:550px;
	max-height:550px;
	overflow: auto;
}

#chargement-en-cours {
	z-index: 1;
	position: absolute;
	text-align: center;
	width: 60%;
	margin-left: 20%;
	margin-top: 275px;

}
</style>
<script>
// Variables globales
var carte = false;
var position_annee = 0;
var annees = false;
var annees_auto = false;

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
		}),
		styleMap: annees_style(2012)
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
	var y = 2013;
	var b2 = y-5;
	var b1 = y-10;

	var style = new OpenLayers.Style();
	style.addRules([
		new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
				type: OpenLayers.Filter.Comparison.EQUAL_TO,
				property: "periode",
				value: 1
			}),
			symbolizer: {
				fillOpacity:0.8,
				fillColor: 'red',
				strokeWidth:0
			}
		}),
		new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
				type: OpenLayers.Filter.Comparison.EQUAL_TO,
				property: "periode",
				value: 2
			}),
			symbolizer: {
				fillOpacity:0.8,
				fillColor: 'yellow',
				strokeWidth:0
			}
		}),
		new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
				type: OpenLayers.Filter.Comparison.EQUAL_TO,
				property: "periode",
				value: 3
			}),
			symbolizer: {
				fillOpacity:0.8,
				fillColor: 'green',
				strokeWidth:0
			}
		})
	]);
	var l = new OpenLayers.Layer.Vector("Pas de 5 ans", { projection: new OpenLayers.Projection("EPSG:2154"), styleMap: style });

	var pa = 1; // avant b2
	var pb = 2; // b2 a b1
	var pc = 3; // b1 a b

	var carres = [];
	var carres_index = {};
	var yok = {};
	annees = []; // pas de mot clé "var" (global)
	for (var i=0; i<features.length; i++) {
		var y = parseInt(features[i].data["annee"]);
		var id_carre = features[i].data["x0"]+"-"+features[i].data["y0"];
		var per = pc;
		if (y < b1) {
			per = pa;
		} else if (y >=b1 && y <= b2) {
			per = pb;
		}
		if (carres_index[id_carre] == undefined) {
			carres_index[id_carre] = carres.push(new OpenLayers.Feature.Vector(features[i].geometry.clone()))-1;
			carres[carres_index[id_carre]].attributes.periode = per;
		} else {
			var old_per = carres[carres_index[id_carre]].attributes.periode;
			carres[carres_index[id_carre]].attributes.periode = Math.max(old_per, per);
		}

		// tableau global des annees
		if (yok[y] == undefined) {
			annees.push(y);
			yok[y] = 1;
		}
	}
	l.addFeatures(carres);
	annees.sort();
	return [l];
}

function annees_style(y) {
	var style = new OpenLayers.Style();
	style.addRules([
		new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
				type: OpenLayers.Filter.Comparison.EQUAL_TO,
				property: "annee",
				value: y
			}),
			symbolizer: {
				fillOpacity:0.8,
				fillColor: 'green',
				strokeWidth:0
			}
		}),
		new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
				type: OpenLayers.Filter.Comparison.LESS_THAN,
				property: "annee",
				value: y
			}),
			symbolizer: {
				display: 'none'
			}
		}),
		new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
				type: OpenLayers.Filter.Comparison.GREATER_THAN,
				property: "annee",
				value: y
			}),
			symbolizer: {
				display: 'none'
			}
		})

	]);
	return style;
}

function annees_set_annee(y) {
	l = carte.map.getLayersByName("Répartition par année")[0];
	style = annees_style(y);
	l.styleMap = style;
	l.redraw();
	$('#a').html(y);
}

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
				carte.loading_update = function (e) {
					if (this.nb_loading > 0) {
						$('#chargement-en-cours').show();
					} else {
						$('#chargement-en-cours').hide();
					}
				};
				var m  = carte.map;
				var la = layer_repartition(id_espece);
				carte.registerloading(la);
				m.addLayers([la]);
			}
		}
	});
	fiche_espece_onglet_actif("fiche_resume");
	$('#btn_rech').click(function () {
		$("#div_rech_espece").toggle(
			function () {
				var inp = $("#in_espece");
				inp.autocomplete({source: '?page=autocomplete_espece',
					select: function (event,ui) {
						document.location.href = '?page=fiche&id='+ui.item.value;
						event.target.value = '';
						return false;
					}
				}).data("ui-autocomplete")._renderItem = function (ul,item) {
					return $("<li>").append("<a>"+item.label+"</a>").appendTo(ul);
				};
				inp.focus();
			}
		);
	});
	$('.ctrl_carte').click(function() {
		var c = $(this);
		switch (c.attr('name')) {
			case 'l':
				annees_auto = false;
				var oldlayer = null;
				var newlayer = null;
				if (c.attr('id') == 'annee') {
					newlayer = carte.map.getLayersByName("Répartition par année")[0];
					oldlayer = carte.map.getLayersByName("Pas de 5 ans")[0];
				} else {
					oldlayer = carte.map.getLayersByName("Répartition par année")[0];
					newlayer = carte.map.getLayersByName("Pas de 5 ans")[0];
				}

				oldlayer.setVisibility(false);
				newlayer.setVisibility(true);

				$('#legende-5ans').toggle();
				$('#legende-annee').toggle();

				$('#adeb').html(annees[0]);
				$('#afin').html(annees[annees.length-1]);
				break;
			case 'f':
				var fondroutier = carte.map.getLayersByName("Openstreetmap ton clair")[0];
				var fondphoto = carte.map.getLayersByName("Picardie 2008-2010")[0];
				if (c.attr('id') == 'photo') 
					carte.map.setBaseLayer(fondphoto);
				else
					carte.map.setBaseLayer(fondroutier);
				break;
		}
	});
	$(".btn_change_annee").click( function () {
		var btn = $(this);
		var sens = btn.attr('sens');

		if (sens == "auto") {
			annees_auto = !annees_auto;
			return false;
		}

		if ((sens == "+") && (position_annee < (annees.length-1)))
			position_annee++;
		if ((sens == "-") && (position_annee > 0))
			position_annee--;

		annees_set_annee(annees[position_annee]);

		return false;
	});

	window.setInterval(function () {
			if (annees_auto) {
				position_annee = (position_annee+1)%annees.length;
				annees_set_annee(annees[position_annee]);
			}
		},
		1500
	);
}

$(document).ready(page_fiche_init);
</script>
{/literal}
<div style="display:none;">
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
			<li class="active"><a class="b_onglets" href="javascript:;" onglet="fiche_resume">Présentation</a></li>
			<li><a class="b_onglets" href="javascript:;" onglet="fiche_medias">Médias</a></li>
			<li><a class="b_onglets" href="javascript:;" onglet="fiche_repartition">Répartition géographique</a></li>
			<li><a class="b_onglets" href="javascript:;" onglet="fiche_biblio">Bibliographie régionale</a></li>
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
						<img style="width:100%;" src="?page=img_esp&id={$img->get_doc_id()}"∕>
						{assign var=image_aff_ok value=1}
					{/if}
				{/if}
			{/if}
		{/foreach}
		{if $image_aff_ok eq 0}
			Pas de photos pour illustrer cette fiche
		{/if}
		{if $referentiel}
			<span class="label label-default">Menace : {$referentiel.categorie}</span>
			<span class="label label-default">Rareté : {$referentiel.indice_rar}</span>
		{/if}
		{if $espece->determinant_znieff}
			<span class="label label-primary">Espèce déterminante ZNIEFF</span>
		{/if}
		{if $espece->invasif}
			<span class="label label-warning">Invasive</span>
		{/if}
		{if $espece->absent_region}<span class="label label-info">Espèce absente de la région</span>{/if}
		
	</div>	
	<div class="col-sm-6">
		{assign var=n_texte value=0}
		{if $espece->commentaire}
			<h1>Répartition régionale</h1>
			<div>{$espece->commentaire}</div>
			{assign var=n_texte value=$n_texte+1}
		{/if}
		{if $espece->habitat}
			<h1>Habitat principal</h1>
			<div>{$espece->habitat}</div>
			{assign var=n_texte value=$n_texte+1}
		{/if}
		{if $espece->menace}
			<h1>Menaces potentielles</h1>
			<div>{$espece->menace}</div>
			{assign var=n_texte value=$n_texte+1}
		{/if}
		{if $espece->action_conservation}
			<h1>Actions de conservation</h1>
			<div>{$espece->action_conservation}</div>
			{assign var=n_texte value=$n_texte+1}
		{/if}
		{if $espece->commentaire_statut_menace}
			<h1>Commentaires sur le statut de menace</h1>
			<div>{$espece->commentaire_statut_menace}</div>
			{assign var=n_texte value=$n_texte+1}
		{/if}
		{if $n eq 0}
			<p>Ce <a href="?page=definitions#gl_taxon" target="_blank">taxon</a> est cité {$espece->get_nb_citations()} fois dans la base de données.</p>
			{if $espece->ordre}
				<p>Il appartient à l'ordre des {$espece->ordre}
				{if $espece->famille}et à la famille des {$espece->famille}{/if}
			{/if}
		{/if}
	</div>

	<div class="col-sm-3">
		<h1>Statut</h1>
		{if $referentiel}
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
		{else}
			Ce <a target="_blank" href="?page=definitions#gl_taxon">taxon</a> n'a pas été évalué.
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
	<div class="row">
		<div class="col-sm-12" style="height:550px;">
			<div>
				<div id="carte_cont"><div id="carte" class="container"></div></div>
				<div id="chargement-en-cours">
					<span>Chargement des données en cours</span>
					<div class="progress progress-striped active">
						<div class="progress-bar"  role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="row">
		<div class="col-sm-4">
			<div class="container">
				<div id="legende-5ans" class="clegende">
					<h4>Légende</h4>
					<span style="background-color:green;">&nbsp;&nbsp;&nbsp;</span> Dernière observation datant de - de 5 ans<br/>
					<span style="background-color:yellow;">&nbsp;&nbsp;&nbsp;</span> Dernière observation datant de - de 10 ans<br/>
					<span style="background-color:red;">&nbsp;&nbsp;&nbsp;</span> Dernière observation datant de + de 10 ans
				</div>
				<div id="legende-annee" class="clegende" style="display:none;">
					<h4>Légende</h4>
					<div>Utiliser les flèches pour changer l'année affichée</div>
					<ul class="pagination">
						<li><a href="#" class="btn_change_annee" sens="-">&laquo;</a></li>
						<li class="disabled"><a id="adeb" href="#">xxxx</a></li>
						<li class="active"><a href="#" id="a" >xxxx</a></li>
						<li class="disabled"><a id="afin" href="#">xxxx</a></li>
						<li><a href="#" class="btn_change_annee" sens="auto" title="changement année automatique">
							<span class="glyphicon glyphicon-repeat"></span>
						</a></li>
						<li><a href="#" class="btn_change_annee" sens="+">&raquo;</a></li>
					</ul>
				</div>
			</div>
		</div>
		<div class="col-sm-4">
			<div class="container">
				<h4>Données</h4>
				<div class="checkbox"><label><input checked type="radio" name="l" id="5ans" class="ctrl_carte">Répartition par pas de 5 ans</label></div>
				<div class="checkbox"><label><input type="radio" name="l" id="annee" class="ctrl_carte">Répartition par année</label></div>
			</div>
		</div>
		<div class="col-sm-4">
			<div class="container">
				<h4>Fond de carte</h4>
				<div class="checkbox"><label><input checked type="radio" name="f" id="route" class="ctrl_carte">Réseau routier</label></div>
				<div class="checkbox"><label><input type="radio" name="f" id="photo" class="ctrl_carte">Photographie aérienne</label></div>
			</div>
		</div>
		<!--
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
		-->
	</div>
	{if $espece->get_restitution_ok($niveau_restitution)}
	<div class="row">
		<div class="container">
			<h2>Répartition communale</h2>
			<div class="col-sm-3">
				<div class="panel panel-default">
					{if $l_aisne}
					<div class="panel-heading"><span class="label label-primary pull-right">{$l_aisne->count()}</span> Aisne</div>
					<div class="panel-body overflow-300px">
						<ul class="nav nav-pills nav-stacked">
						{foreach from=$l_aisne item=c}
							<li><a href="?page=commune&id={$c.id_espace}"><span class="badge pull-right">{$c.ymax}</span>{$c.nom2}</a></li>
						{/foreach}
					</div>
					{/if}
				</div>
			</div>
			<div class="col-sm-3">
				<div class="panel panel-default">
					{if $l_oise}
					<div class="panel-heading"><span class="label label-primary pull-right">{$l_oise->count()}</span> Oise</div>
					<div class="panel-body overflow-300px">
						<ul class="nav nav-pills nav-stacked">
						{foreach from=$l_oise item=c}
							<li><a href="?page=commune&id={$c.id_espace}"><span class="badge pull-right">{$c.ymax}</span>{$c.nom2}</a></li>
						{/foreach}
						</ul>
					</div>
					{/if}
				</div>
			</div>
			<div class="col-sm-3">
				<div class="panel panel-default">
					{if $l_somme}
					<div class="panel-heading"><span class="label label-primary pull-right">{$l_somme->count()}</span> Somme</div>
					<div class="panel-body overflow-300px">
						<ul class="nav nav-pills nav-stacked">
						{foreach from=$l_somme item=c}
							<li><a href="?page=commune&id={$c.id_espace}"><span class="badge pull-right">{$c.ymax}</span>{$c.nom2}</a></li>
						{/foreach}
						</ul>
					</div>
					{/if}
				</div>

			</div>
			<div class="col-sm-3">
				<a style="margin-top: 30px;" href="#" class="btn btn-primary">Télécharger la liste des communes</a>
				<div id="donut" style="height: 200px; width: 200px; margin-left: auto; margin-right: auto; margin-top: 30px; margin-bottom: 30px;"></div>
				<script>
				var d_somme =  {if $l_somme}{$l_somme->count()}{else}0{/if};
				var d_oise =  {if $l_oise}{$l_oise->count()}{else}0{/if};
				var d_aisne =  {if $l_aisne}{$l_aisne->count()}{else}0{/if};
				{literal}
				Morris.Donut({
					element: 'donut',
					data: [
						{label: "Somme", value: d_somme},
						{label: "Oise", value: d_oise},
						{label: "Aisne", value: d_aisne}
					]
				});
				{/literal}
				</script>
			</div>
		</div>
	</div>
	{else}
		<div class="row">
			<div class="col-sm-12">
				<h2>Répartition communale</h2>
				<div class="container">
					<div class="alert alert-warning">
						<b>Pas de liste communale disponible !</b>
						Ce taxon est considéré comme sensible, <a href="?page=definitions#gl_cachee" target="_blank">en savoir plus</a>.
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
<div class="row onglet_fiche_espece" id="fiche_statut">
</div>
<div class="row onglet_fiche_espece" id="fiche_biblio">
	<div class="col-sm-12">
		{section loop=$docs name=p step=2}
		{assign var=article value=$docs[p]}
		{assign var=index value=$smarty.section.p.index+1}
		{assign var=articleb value=$docs[$index]}
		<div class="row">
			<div class="col-sm-6">{include file=_article_biblio.tpl article=$article}</div>
			{if $articleb}
			<div class="col-sm-6">{include file=_article_biblio.tpl article=$articleb}</div>
			{/if}
		</div>
		{/section}
	</div>
</div>
{include file="pas_exhaustif.tpl"}
{include file=foot.tpl}

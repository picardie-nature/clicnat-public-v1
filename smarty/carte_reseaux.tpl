{include file=head.tpl}
{assign var=liste_espace value=$travail->liste_espace()}
<div class="row">
	<div class="col-sm-9">
		<h1>{$travail->titre}</h1>
		<div>
			<div class="btn-group" id="btn_vues" role="group"></div>
		</div>
	</div>
	<div class="col-sm-3">
	</div>
</div>
<div class="row">
	<div class="col-sm-9">
		<div style="height:550px;">
			<div id="carte_cont"> 
				<div id="carte"></div>
			</div>
			<div id="chargement-en-cours">
				<div class="progress progress-striped active">
					<div class="progress-bar"  role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>
				</div>
			</div>
		</div>	
		<h3>Description</h3>
		<p>{$travail->description|markdown}</p>
	</div>
	<div class="col-sm-3">
		<h3>Légende</h3>
		<div id="legende"></div>
		<h3>Maille</h3>
		<div id="commune"></div>
		<ul class="list-group" id="commune_liste"></ul>
		<h3>Attribution</h3>
		<p>{$liste_espace} : {$liste_espace->mention}</p>
		<a href="?page=carte_kml&id={$liste_espace->id_liste_espace}" class="btn btn-primary">Télécharger KML</a>
	</div>
</div>

{include file="_carte.tpl"}

<script>
var reseaux = new Array();
{foreach from=$reseaux item=r}
reseaux['{$r->id}'] = "{$r}";
{/foreach}
{literal}
function carte_ajout_layer_wfs(map, id_liste, titre, mention) {
	var lv  = new OpenLayers.Layer.Vector(titre, {
		styleMap: new OpenLayers.StyleMap(),
		strategies: [new OpenLayers.Strategy.Fixed()],
		projection: map.displayProjection,
		protocol: new OpenLayers.Protocol.WFS({
			url: "?page=liste_espace_carte_wfs",
			featureType: "liste_espace_"+id_liste,
			featureNS: "http://www.clicnat.org/espace"
		}),
		attribution: mention
	});
	map.addLayer(lv);
	map.events.register('featureover', map, function (e) { 
		var dc = $('#commune');
		dc.html("<h4>"+e.feature.data.nom+"</h4>");
		var cname = $('.btn-style.btn-success').attr('stylename');
		dc.append(e.feature.data[cname]+" taxons<br/>");
		dc.append(e.feature.data[cname.replace("_species","_occurences")]+" occurrences");
	});
	return lv;
}
var sld = undefined;
var wfs;
var styles;
var carte;
var id_liste_espace = {/literal}{$liste_espace->id_liste_espace};{literal}
var mention_liste_espace = {/literal}"{$liste_espace->mention}";{literal}

function feature_over(e) {
	var dc = $('#commune');
	dc.html("<h4>"+e.feature.data.nom+"</h4>");
	var cname = $('.btn-style.btn-success').attr('stylename');
	dc.append(e.feature.data[cname]+" taxons<br/>");
	dc.append(e.feature.data[cname.replace("_species","_occurences")]+" occurrences");
}

function page_init() {
	carte = new Carto('carte');
	carte.loading_update = Carto.prototype.loading_update;
	carte.ajout_layer_wfs(id_liste_espace, "Mailles", mention_liste_espace, null, feature_over);
	OpenLayers.Request.GET({
		url: "?page=sld_reseaux",
		success: function (r) {
			var f = new OpenLayers.Format.SLD();
			sld = f.read(r.responseXML || r.responseText);
			
			$('#vues').html("");
			styles = sld.namedLayers["liste_espace_{/literal}{$liste_espace->id_liste_espace}{literal}"].userStyles;
			for (var i=0; i<styles.length;i++) {
				if (styles[i].name.match(/^.*_species/)) {
					var cl = styles[i].name;
					cl = cl.replace(/_species$/,'').toLowerCase();
					$('#btn_vues').append("<button type=\"button\" class=\"btn btn-default btn-style\" stylename=\""+styles[i].name+"\" >"+reseaux[cl]+"</button>");
				}
			}
			$('.btn-style').click(function () {
				$('.btn-style').removeClass("btn-success");
				$(this).addClass("btn-success");
				var style_name_wanted = $(this).attr("stylename");
				for (var i=0; i<styles.length;i++) {
					if (styles[i].name == style_name_wanted) {
						layers = carte.map.getLayersByName("Mailles");
						layers[0].styleMap.styles["default"] = styles[i];
						layers[0].redraw();
						var dl = $('#legende');
						dl.html("");
						for (var j=0;j<styles[i].rules.length;j++) {
							dl.append("<div>"+styles[i].rules[j].title+"<span class='pull-left' style='background-color:"+styles[i].rules[j].symbolizer.Polygon.fillColor+"'>&nbsp;&nbsp;&nbsp;</span></div>");
						}
						break;
					}
				}
			});
			$('.btn-style')[0].click();
		}
	});
	var pt = new OpenLayers.LonLat(2.80151, 49.69606);
	pt.transform(new OpenLayers.Projection(carte.map.displayProjection), new OpenLayers.Projection(carte.map.projection));
	carte.map.setCenter(pt, 7);
}

$(document).ready(page_init);
{/literal}
</script>
{include file=foot.tpl}

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
	<div class="col-sm-9" >
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
		<h3>Commune</h3>
		<div id="commune"></div>
		<ul class="list-group" id="commune_liste"></ul>
		<h3>Attribution</h3>
		<p>{$liste_espace} : {$liste_espace->mention}</p>
		<a href="?page=carte_kml&id={$liste_espace->id_liste_espace}" class="btn btn-primary">Télécharger KML</a>
	</div>
</div>
{include file="_carte.tpl"}
<script>
var classes = new Array();
{foreach from=$classes item=cl key=c}
classes['classe_{$c}'] = "{$cl}";
{/foreach}
{literal}
function feature_over(e) {
	var dc = $('#commune');
	dc.html("<h4>"+e.feature.data.nom+"</h4>");
	if (e.feature.data.total > 0)
		dc.append("<p>"+e.feature.data.total+" espèces au total</p>");
	var ul = $('#commune_liste');
	ul.html("");
	for (var key in e.feature.data) {
		if (key.match(/classe_.*/)) {
			if (key == "classe__")
				continue;
			if (e.feature.data[key] == 0)
				continue;
			cl = key.replace(/^classe_/,'').toLowerCase();
			ul.append("<li class=\"list-group-item\"><img src=\"image/20x20_g_"+cl+".png\"> "+classes[key]+" <span class=\"badge\">"+e.feature.data[key]+"</span>");
		}
	}
}

var sld = undefined;
var wfs;
var styles;
var carte;
var id_liste_espace = {/literal}{$liste_espace->id_liste_espace};{literal}
var mention_liste_espace = {/literal}"{$liste_espace->mention}";{literal}

function page_init() {
	carte = new Carto('carte');
	carte.loading_update = Carto.prototype.loading_update;
	carte.ajout_layer_wfs(id_liste_espace, "Communes", mention_liste_espace, null, feature_over);
	OpenLayers.Request.GET({
		url: "?page=sld_communes",
		success: function (r) {
			var f = new OpenLayers.Format.SLD();
			sld = f.read(r.responseXML || r.responseText);
			$('#vues').html("");
			styles = sld.namedLayers["liste_espace_"+id_liste_espace].userStyles;
			for (var i=0; i<styles.length;i++) {
				if (styles[i].name.match(/^classe_.*/)) {
					var cl = styles[i].name;
					cl = cl.replace(/^classe_/,'').toLowerCase();
					var img ="<img src=\"image/20x20_g_"+cl+".png\" alt=\""+styles[i].title+"\">";
					$('#btn_vues').append("<button type=\"button\" class=\"btn btn-default btn-style\" title=\""+styles[i].title+"\"stylename=\""+styles[i].name+"\" >"+img+"</button>");
				} else {
					$('#btn_vues').append("<button type=\"button\" class=\"btn btn-default btn-style\" stylename=\""+styles[i].name+"\" >"+styles[i].title+"</button>");
				}
			}


			// change event
			$('.btn-style').click(function () {
				$('.btn-style').removeClass("btn-success");
				$(this).addClass("btn-success");
				var style_name_wanted = $(this).attr("stylename");
				for (var i=0; i<styles.length;i++) {
					if (styles[i].name == style_name_wanted) {
						layers = carte.map.getLayersByName("Communes");
						if (layers[0] == undefined)
							return false;
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

			// premier si aucun de sélectionné
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

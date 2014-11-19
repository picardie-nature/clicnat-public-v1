{include file=head.tpl}
{assign var=liste_espace value=$travail->liste_espace()}
<div class="row">
	<div class="col-sm-12">
		<h1>{$travail->titre}</h1>
		<div>
			<div class="btn-group" id="btn_vues" role="group">
				
			</div>
		</div>
		<div id="map" style="width:100%; height:500px; background-color: #aaa;"></div>
	</div>
</div>
<div class="row">
	<div class="col-sm-6">
		<h3>Description</h3>
		<p>{$travail->description|markdown}</p>
	</div>
	<div class="col-sm-6">
		<h3>Légende</h3>
		<div id="legende"></div>
		<h3>Attribution</h3>
		<p>{$liste_espace} : {$liste_espace->mention}</p>
		<h3>Téléchargement</h3>
		<a href="#" class="btn btn-primary">Télécharger KML</a>
	</div>

</div>


<script type="text/javascript" src="http://deco.picardie-nature.org/proj4js/lib/proj4js-compressed.js"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/OpenLayers-2.12/OpenLayers.js"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/carto.js"></script>

<script>
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
	return lv;
}
var sld = undefined;
var wfs;
var styles;
var carte = new Carto('map');
var m  = carte.map;
OpenLayers.Request.GET({
	url: "?page=sld_communes",
	success: function (r) {
		var f = new OpenLayers.Format.SLD();
		sld = f.read(r.responseXML || r.responseText);
		
		$('#vues').html("");
		styles = sld.namedLayers["liste_espace_124"].userStyles;
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
		$('.btn-style').click(function () {
			$('.btn-style').removeClass("btn-success");
			$(this).addClass("btn-success");
			var style_name_wanted = $(this).attr("stylename");
			for (var i=0; i<styles.length;i++) {
				if (styles[i].name == style_name_wanted) {
					layers = m.getLayersByName("Communes");
					console.log(layers);
					layers[0].styleMap.styles["default"] = styles[i];
					layers[0].redraw();
					var dl = $('#legende');
					dl.html("");
					for (var j=0;j<styles[i].rules.length;j++) {
						dl.append("<div>"+styles[i].rules[j].title+"<span style='color:"+styles[i].rules[j].symbolizer.Polygon.fillColor+">&nbsp;&nbsp;&nbsp;</span></div>");
					}
					console.log("done");
					break;
				}
			}
		});
	}
});
//{/literal}

wfs = carte_ajout_layer_wfs(m, {$liste_espace->id_liste_espace}, "Communes", "{$liste_espace->mention}");
//m.addLayer(wfs);
var pt = new OpenLayers.LonLat(2.80151, 49.69606);
pt.transform(new OpenLayers.Projection(m.displayProjection), new OpenLayers.Projection(m.projection));
m.setCenter(pt, 7);
</script>
{include file=foot.tpl}

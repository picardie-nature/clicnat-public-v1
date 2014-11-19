{include file=head.tpl}
{assign var=liste_espace value=$travail->liste_espace()}
<div class="row">
	<div class="col-sm-12">
		<h1>{$travail->titre}</h1>
		<div id="map" style="width:100%; height:500px; background-color: #aaa;"></div>
	</div>
</div>
<div class="row">
	<div class="col-sm-6">
		<h3>Description</h3>
		<p>{$travail->description|markdown}</p>
	</div>
	<div class="col-sm-6">
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
function carte_ajout_layer_wfs(map, id_liste, titre, mention, style) {
	var lv  = new OpenLayers.Layer.Vector(titre, {
		styleMap: style,
		strategies: [new OpenLayers.Strategy.BBOX()],
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

var carte = new Carto('map');
var m  = carte.map;
var stylemap = new OpenLayers.StyleMap(new OpenLayers.Style({
		    strokeColor: "#f44",
		    strokeOpacity: 1,
		    strokeWidth: 4,
		    fillColor: "#ff0000",
		    fillOpacity: 0.5,
		    pointRadius: 6,
		    label: "${getNom}",
		    fontSize: 13,
		    fontFamily: "Arial",
		    labelAlign: "cc",
		    fontWeight: "bold"
	},{context: {
		getNom: function(feature) {
			if (feature.layer.map.getZoom() > 10) {
				return feature.attributes.nom;
			} else {
				return "";
			}
		}
	}
}));

//{/literal}

var wfs = carte_ajout_layer_wfs(m, {$liste_espace->id_liste_espace}, "{$liste_espace}", "{$liste_espace->mention}", stylemap);
m.addLayer(wfs);
var pt = new OpenLayers.LonLat(2.80151, 49.69606);
pt.transform(new OpenLayers.Projection(m.displayProjection), new OpenLayers.Projection(m.projection));
m.setCenter(pt, 8);
</script>
{include file=foot.tpl}

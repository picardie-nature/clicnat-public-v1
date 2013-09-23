{include file=head.tpl}
<style>
{literal}
.olControlAttribution {
	background-color:white;
	opacity:0.8;
}
{/literal}
</style>
<h1>Identification des secteurs routiers mortels pour les amphibiens de Picardie</h1>
<div id="map" style="width:100%; height:500px; background-color: #aaa;"></div>
<p>
Ces données proviennent, pour la plupart, d'alertes par des usagers de la route ou des adhérents qui constatent, entre février et avril, des secteurs routiers avec une mortalité d'amphibiens importante. 
Cette carte est loin d'être exhaustive et mérite d'être complétée. Si vous avez connaissance d'autres secteurs routiers mortels pour les amphibiens, signalez-le !
<ul>
	<li>Par mail à : virginie.coffinet@picardie-nature.org<br/><small> Merci de bien décrire le lieu (n° de route, commune, paysages alentours..., le nombre estimé d'animaux écrasés, les espèces identifiées (si possible!)</small></li>
	<li>Par Internet : sur <a href="http://routes.picardie-nature.org/">http://routes.picardie-nature.org/</a></li>
</p>
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
	console.log(lv);
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


var wfs = carte_ajout_layer_wfs(m, 3, 'Points noirs', 'Picardie-Nature - 2012', stylemap);
m.addLayer(wfs);
var pt = new OpenLayers.LonLat(2.80151, 49.69606);
pt.transform(new OpenLayers.Projection(m.displayProjection), new OpenLayers.Projection(m.projection));
m.setCenter(pt, 8);
</script>
{/literal}
{include file=foot.tpl}


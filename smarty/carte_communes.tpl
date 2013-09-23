{include file="head.tpl"}
<script type="text/javascript" src="http://deco.picardie-nature.org/proj4js/lib/proj4js-compressed.js"></script>
<script type="text/javascript" src="http://deco.picardie-nature.org/openlayers/OpenLayers.js"></script>
<h1>Nombre d'espèces animales recensées par communes (non exhaustif)</h1>
<div style="width:19%;float:right;">
    <b>Légende</b><br/>
    <span class="legende" style="background-color:rgb(255,255,255); color:black;">&nbsp;0&nbsp;espèce</span>
    <span class="legende" style="background-color:rgb(187,251,1); color:black;">&nbsp;1 à 20&nbsp;espèces</span>
    <span class="legende" style="background-color:rgb(29,234,18); color:rgb(251,119,1);">&nbsp;21 à 100&nbsp;espèces</span>
    <span class="legende" style="background-color:rgb(18,224,234);">&nbsp;101 à 200&nbsp;espèces</span>
    <span class="legende" style="background-color:rgb(176,96,174);">&nbsp;201 à 500&nbsp;espèces</span>
    <span class="legende" style="background-color:rgb(111,96,174);">&nbsp;501 à 1000&nbsp;espèces</span>
    <span class="legende" style="background-color:rgb(250,96,79);">&nbsp;&gt; 1000&nbsp;espèces</span>
    <br/><br/>
    <b>A propos de cette carte</b>
    <p>Cette carte présente le nombre d'espèces, consignées dans la base sur chaque commune,
    avec pour objectif premier de stimuler la collecte de nouvelles observations.</p>
    <p>Vous pouvez vous déplacer et zoomer sur la carte. En cliquant sur celle-ci, une fenêtre
    vous indiquera le nom de la commune et le nombre d'espèces.</p>
    <p>Info : {$maj}</p>
</div>
<div id="carte" style=" width:80%; height:480px;"></div>
<div id="popup_content" style="display:none;"></div>
<div style="clear:both;" class="info"> {include file="pas_exhaustif.tpl"} </div>
<script type="text/javascript">
{literal}
	<!--
	var glob_pt;
	var map;
	
	function carte_communes_map_init() {	
		// code valable uniquement pour l'interface de saisie
		OpenLayers.Control.PubClique = OpenLayers.Class(OpenLayers.Control, {                
			defaultHandlerOptions: {
				single: true,
				double: false,
				pixelTolerance:false,
				stopSingle: false,
				stopDouble: false
			},

			initialize: function(options) {
				this.handlerOptions = OpenLayers.Util.extend({}, this.defaultHandlerOptions);
				OpenLayers.Control.prototype.initialize.apply(this, arguments); 
				this.handler = new OpenLayers.Handler.Click(this, {click: this.trigger}, this.handlerOptions);
			}, 

			trigger: function(e) {
				var pt = e.object.getLonLatFromViewPortPx(e.xy);
				glob_pt = pt;
				log(pt);
				var url = '?page=geocode&lon='+pt.lon+'&lat='+pt.lat;
				J('#popup_content').load(url, function () {
					var popup = new OpenLayers.Popup(null, glob_pt, null, J('#popup_content').html(), true);
					popup.panMapIfOutOfView = true;					
					map.addPopup(popup);
					});
			}
		});
					
		Proj4js.defs["EPSG:2154"] = "+proj=lcc +lat_1=49 +lat_2=44 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
		
		var p_map = new OpenLayers.Projection('EPSG:2154');
		var p_ext = new OpenLayers.Projection('EPSG:4326');
		var opts = {
			 projection: p_map
		};
		
		var z = new OpenLayers.Bounds();
		z.extend(new OpenLayers.LonLat(1.1526, 50.4655));
		z.extend(new OpenLayers.LonLat(4.4595, 48.8079));
		z = z.transform(p_ext, p_map);
		
		map = new OpenLayers.Map('carte', opts);

		layer = new OpenLayers.Layer.WMS.Untiled(
				'Communes',
				'?',
				{
					page: 'ms_communes'
				},{										
					projection: p_map,
					units: "m",
					maxExtent: z,
					maxResolution: "auto"
				});
		map.addLayer(layer);
		map.zoomToExtent(z);
		c = new OpenLayers.Control.PubClique();
		map.addControl(c);
		c.activate();
    }
{/literal}
	carte_communes_map_init()
  -->
</script>
{include file="foot.tpl"}

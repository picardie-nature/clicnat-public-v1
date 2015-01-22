{*
Éléments communs aux cartes avec du WFS
*}

<script type="text/javascript" src="http://deco.picardie-nature.org/proj4js/lib/proj4js-compressed.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/openlayers/2.13.1/OpenLayers.js"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/carto.js"></script>
<script type="text/javascript" src="carto_wfs.js"></script>
<style>
/*{literal}*/
#carte {
	width:100%;
	height:550px;
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
#chargement-en-cours {
	z-index: 1;
	position: absolute;
	text-align: center;
	width: 60%;
	margin-left: 20%;
	margin-top: 275px;
}
/*{/literal}*/
</style>
<script>
{literal}
{/literal}
</script>

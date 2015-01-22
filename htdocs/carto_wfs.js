Carto.prototype.loading_update = function (e) {
	console.log("nb_loading = "+this.nb_loading);
	if (this.nb_loading > 0) {
	 	$('#chargement-en-cours').show();
	} else {
		$('#chargement-en-cours').hide();
	}
}

Carto.prototype.ajout_layer_wfs = function (id_liste, titre, mention, style, feature_over) {
	if (style == null) {
		console.log("style vide - def par défaut");
		style = new OpenLayers.StyleMap();
	}
	
	var lv  = new OpenLayers.Layer.Vector(titre, {
		styleMap: style,
		strategies: [new OpenLayers.Strategy.Fixed()],
		projection: carte.map.displayProjection,
		protocol: new OpenLayers.Protocol.WFS({
			url: "?page=liste_espace_carte_wfs",
			featureType: "liste_espace_"+id_liste,
			featureNS: "http://www.clicnat.org/espace"
		}),
		attribution: mention
	});
	this.map.addLayer(lv);
	this.registerloading(lv);
	// il est déjà en train de charger
	this.nb_loading += 1;
	if (feature_over != undefined) {
		this.map.events.register('featureover', this.map, feature_over);
	}
	return lv;
}

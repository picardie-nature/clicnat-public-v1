{include file="head.tpl"}
<div class="row">
	<div class="col-sm-12">
		<h1>Clicnat : La faune sauvage en un clic pour tous les Picards</h1>
		{texte nom="promontoire_accueil_1"}
	</div>
</div>
<div class="row">
	<div class="col-sm-6" id="bloc-commune">
		<div class="bloc-commune-cont">
			<p>
			    <h3>Rechercher par commune</h3>
			    &nbsp;&nbsp;&gt;&nbsp;<input id="commune" type="text" name="commune" placeholder="Amiens"/><br/>
			    <small>
			    <p>Tapez ici les premières lettres du nom de la commune
			     de votre choix puis sélectionnez celle-ci dans le menu déroulant</p>
			    </small>
			    <br/>
			</p>
		</div>
	</div>
	<div class="col-sm-6"  id="bloc-espece">
		<p>
		    <h3>Rechercher une espèce</h3>
		    &nbsp;&nbsp;&gt;&nbsp;<input type="text" name="espece" id="espece" placeholder="Chouette"/><br/>
		    <small><p>Tapez ici le nom d'une espèce </p></small>
		    <a class="btn btn-primary" href="?page=rl">Zoom sur les espèces menacées de la région</a>
		    <br/>
		</p>
	</div>    
</div>
<div id="accueil">{texte nom="promontoire_accueil_2"}</div>
<script>
    //{literal}
    $('#commune').autocomplete({source: '?page=autocomplete_commune',
	select: function (event,ui) {
		document.location.href = '?page=commune&id='+ui.item.value;
		event.target.value = '';
		return false;	    
	}
    });
    $('#espece').autocomplete({source: '?page=autocomplete_espece',
	select: function (event,ui) {
		document.location.href = '?page=fiche&id='+ui.item.value;
		event.target.value = '';
		return false;
	}
    }).data("ui-autocomplete")._renderItem = function (ul,item) {
    	return $("<li>").append("<a>"+item.label+"</a>").appendTo(ul);
    };
    //{/literal}
</script>
{include file="foot.tpl"}

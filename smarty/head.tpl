<!DOCTYPE html>
<html lang="fr">
<head>
	<title>{if $titre_page}{$titre_page} - {/if}Picardie Nature</title>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=7" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
	<!-- <link href="http://deco.picardie-nature.org/jquery/css/redmond/jquery-ui-1.8.2.custom.css" media="all" rel="stylesheet" type="text/css" /> -->

	<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">
	<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap-theme.min.css">
	<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css">
	<link href="css/style.css?v={$smarty.now|date_format:"%d%m%Y%H"}" media="all" rel="stylesheet" type="text/css" />
	<link rel="stylesheet" href="http://cdn.oesmith.co.uk/morris-0.4.3.min.css">
</head>
<body>
	<script src="//code.jquery.com/jquery.js"></script>
	<script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
	<script src="//cdnjs.cloudflare.com/ajax/libs/raphael/2.1.0/raphael-min.js"></script>
	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
	<script src="http://cdn.oesmith.co.uk/morris-0.4.3.min.js"></script>
	<script>
	{literal}
	//var J = jQuery.noConflict();

	function log(msg) {
		try {
			if (console.firebug)
				console.info(msg);
		} catch (e) {
			return false;
		}
	}

	function dialog_vignette(div_id, obs_id)
	{
	    $(div_id+'-img').src='?t=obs_vignette&id='+obs_id;
	    J('#'+div_id).dialog({title: "Observation #"+obs_id,width: 500,height: 400});
	}
	
	{/literal}
	</script>
	<!--[if IE]>
	<style>
		{literal}
		.hoverscroll {
			display: inline;
		}
		{/literal}
	</style>
	<![endif]-->

	<!--  div class="bloc-haut" style="min-width: 1000px;"> -->
	<div class="container">
		<div class="navbar navbar-default" role="navigation">
			<div id="banniere" class="hidden-xs">
				<div id="banniere2"></div>
			</div>
			<div class="navbar-header">
				<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
					<span class="sr-only">Toggle navigation</span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</button>
				<a class="navbar-brand" href="?page=accueil">Clicnat</a>
			</div>
			<div class="collapse navbar-collapse navbar-ex1-collapse">
				<ul class="nav navbar-nav">
					<li class="active"><a href="?page=accueil">Accueil</a></li>
					<li class="active"><a href="?page=listes">Listes</a></li>
					<li class="active"><a href="?page=travaux">Études et travaux</a></li>
					<li class="active"><a href="?page=definitions">Glossaire</a></li>
					<li class="active"><a href="?page=partenaires">Contributeurs et partenaires</a></li>
					<li class="active"><a href="?page=saisie">Saisir vos données</a></li>
				</ul>
			</div>
		</div>
	</div>

	<div class="container">

{include file="head.tpl" titre_page="Liste espèces - référentiels"}
<div class="row">
	<div class="col-sm-12">
		<h1>Listes d'espèces - référentiels</h1>
	</div>
</div>
{assign var=rclass value="col-xs-12 col-sm-6 col-md-4 col-lg-3"}
<div class="row">
	<div class="{$rclass}">
		<div class="panel panel-default">
			<div class="panel-heading">Espèces de la liste rouge picarde</div>
			<div class="panel-body">
				<p>La liste rouge des espèces menacées de Picardie est constituée
				des espèces définies comme Vulnérables (VU), En danger (EN) et 
				En danger critique (CR).</p>
				<div class="pull-right">
					<a class="btn btn-success" href="?page=rl"><span class="glyphicon glyphicon-search"></span> Voir la liste</a>
					<a class="btn btn-success" href="?page=liste_csv&liste=rl" title="Télécharger"><span class="glyphicon glyphicon-download-alt"></span></a>
				</div>
			</div>
		</div>
	</div>
	<div class="{$rclass}">
		<div class="panel panel-default">
			<div class="panel-heading">Espèces invasives</div>
			<div class="panel-body">
				<p>Ces espèces ne sont pas originaires de la région (non indigènes) et perturbent les milieux 
				naturels en place. Elles peuvent ainsi concurrencer les espèces européennes et fragiliser la 
				biodiversité de nos contrées.</p>
				<div class="pull-right">
					<a class="btn btn-success" href="?page=li"><span class="glyphicon glyphicon-search"></span> Voir la liste</a>
					<a class="btn btn-success" href="?page=liste_csv&liste=li" title="Télécharger"><span class="glyphicon glyphicon-download-alt"></span></a>
				</div>
			</div>
		</div>
	</div>
	<div class="{$rclass}">
		<div class="panel panel-default">
			<div class="panel-heading">Espèces sensibles</div>
			<div class="panel-body">
				<p>Pour cette liste d'espèces, il ne sera pas donné d'indication
				quant à leur localisation à l'échelon communal, afin de ne pas nuire à la pérennité des 
				populations. Ces informations communales sont donc "cachées".</p>
				<div class="pull-right">
					<a class="btn btn-success" href="?page=ls"><span class="glyphicon glyphicon-search"></span> Voir la liste</a>
					<a class="btn btn-success" href="?page=liste_csv&liste=ls" title="Télécharger"><span class="glyphicon glyphicon-download-alt"></span></a>
				</div>
			</div>
		</div>
	</div>
	<div class="{$rclass}">
		<div class="panel panel-default">
			<div class="panel-heading">Espèces déterminantes de ZNIEFF</div>
			<div class="panel-body">
				<p>Il s'agit des espèces susceptibles d'engendrer la mise en place d'une <a href="http://fr.wikipedia.org/wiki/Zone_naturelle_d%27int%C3%A9r%C3%AAt_%C3%A9cologique,_faunistique_et_floristique">Zone Naturelle d'Intérêt Écologique, Faunistique et Floristique</a>.</p> 
				<div class="pull-right">
					<a class="btn btn-success" href="?page=lz"><span class="glyphicon glyphicon-search"></span> Voir la liste</a>
					<a class="btn btn-success" href="?page=liste_csv&liste=lz" title="Télécharger"><span class="glyphicon glyphicon-download-alt"></span></a>
				</div>
			</div>
		</div>
	</div>
</div>
<div class="row">
	<div class="col-sm-12">
		<h1>Toutes les espèces</h1>
	</div>
</div>
<div class="row">
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=A">
				<img src="image/30x30_g_a.png">
				<div class="caption" style="text-align:center;">
					<h3>Araignées</h3>
				</div>
			</a>
		</div>
	</div>
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=I">
				<img src="image/30x30_g_i.png">
				<div class="caption" style="text-align:center;">
					<h3>Insectes</h3>
				</div>
			</a>
		</div>
	</div>
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=B">
				<img src="image/30x30_g_b.png">
				<div class="caption" style="text-align:center;">
					<h3>Amphibiens</h3>
				</div>
			</a>
		</div>
	</div>
</div>
<div class="row">
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=M">
				<img src="image/30x30_g_m.png">
				<div class="caption" style="text-align:center;">
					<h3>Mammifères</h3>
				</div>
			</a>
		</div>
	</div>
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=O">
				<img src="image/30x30_g_o.png">
				<div class="caption" style="text-align:center;">
					<h3>Oiseaux</h3>
				</div>
			</a>
		</div>
	</div>
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=P">
				<img src="image/30x30_g_p.png">
				<div class="caption" style="text-align:center;">
					<h3>Poissons</h3>
				</div>
			</a>
		</div>
	</div>
</div>
<div class="row">
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=R">
				<img src="image/30x30_g_r.png">
				<div class="caption" style="text-align:center;">
					<h3>Reptiles</h3>
				</div>
			</a>
		</div>
	</div>
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=C">
				<img src="image/30x30_g_c.png">
				<div class="caption" style="text-align:center;">
					<h3>Crustacés</h3>
				</div>
			</a>
		</div>
	</div>
	<div class="col-sm-4">
		<div class="thumbnail">
			<a class="thumbnail" href="?page=classe&classe=H">
				<img src="image/30x30_g_h.png">
				<div class="caption" style="text-align:center;">
					<h3>Hydrozoaires</h3>
				</div>
			</a>
		</div>
	</div>

</div>

{include file="foot.tpl"}

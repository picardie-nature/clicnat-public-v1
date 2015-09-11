{include file="head.tpl"}
{include file="menaces.tpl"}
{include file="raretes.tpl"}
<div class="row">
	<div class="col-sm-12">
		<h1 id="commune">{$commune->nom2} ({$commune->dept|string_format:"%02d"}) <a href="#" id="btn_rech" class="btn btn-default"><span class="glyphicon glyphicon-search"></span></a>
			<a class="btn btn-primary pull-right" href="?page=commune_especes_csv&id={$commune->id_espace}">Télécharger <span class="glyphicon glyphicon-download"></span></a>
		</h1>
		<div class="well" id="div_rech_commune" style="display:none;">
			<div class="form-group">
				<label for="commune">Rechercher une commune</label>
				<input class="form-control" type="text" id="in_commune" placeholder="{$commune->nom2}">
			</div>
		</div>

		Vous pouvez cliquer sur un des groupes pour découvrir la liste
		des <b>{$n_especes}</b> espèces ou <a target="_blank" href="?page=definitions#gl_taxon">taxons</a> <a href="?page=definitions#gl_consignees">consignés</a> dans la base de données.
		<p>Communes voisines :
		{foreach from=$commune->get_voisins() item=voisin}
			{if $commune->id_espace != $voisin.id_espace}
				<a href="?page=commune&id={$voisin.id_espace}">{$voisin.nom2}</a>&nbsp;&nbsp;
			{/if}
		{/foreach}
		</p>
	</div>
</div>
<div class="row">
	<div class="col-sm-3" id="paneau">
		<div class="nav list-group">
			{foreach from=$compteurs item=groupe}
			{if $groupe.classe neq "_"}
			<a class="list-group-item" href="#classe{$groupe.classe}" classe="{$groupe.classe}">
				<h4><img src="image/20x20_g_{$groupe.classe|lower}.png"/> 
				{$groupe.lib}</h4>
				<p>
				{if $groupe.n eq 1}
					une espèce
					{if $groupe.nc gt 0} cachée{/if}
				{/if}
				{if $groupe.n gt 1}
					{$groupe.n} espèces
					{if $groupe.nc eq 1}
						dont une espèce sensible absente de la liste
					{/if}
					{if $groupe.nc gt 1}
						dont {$groupe.nc} espèces sensibles absentes de la liste
					{/if}
				{/if}
				{if $groupe.n eq 0}
					{if $groupe.nc eq 0}
						aucune espèce consignée
					{/if}
				{/if}
				</p>
			</a>
			{/if}
			{/foreach}
		</div>
	</div>
	<div class="col-sm-9" id="liste">
	{assign var=n value=0}
	{assign var=classe value=''}
	{assign var=n_cache value=0}
	{foreach from=$liste_especes item=espece name=liste2}


		{if $classe != $espece->classe}
			{if strlen($classe)>0}
					</div>
				</div><!-- fin -->
			{/if}
			{assign var=classe value=$espece->classe}
				<div class="panel panel-default">
					<div class="panel-heading" id="classe{$classe}">
						<a href="#commune" class="btn btn-default pull-right">
							<span class="glyphicon glyphicon-circle-arrow-up"></span>
						</a>
						<h4>{$classes_libs.$classe} </h4>
					</div>
					<div class="panel-body">
						<div class="row">
							<div class="col-xs-4">Nom de l'espèce</div>
							<div class="col-xs-2">Rareté</div>
							<div class="col-xs-2">Menace</div>
							<div class="col-xs-4">Années</div>
						</div>
		{/if}
			{assign var=n value=$n+1}	
			{assign var=r value=$espece->get_referentiel_regional()}
			{if $espece->get_restitution_ok($niveau_restitution) && !$espece->exclure_restitution}	
				<div class="row">
					<div class="col-xs-4">
						<a href="?page=fiche&id={$espece->id_espece}" title="{$espece->nom_s}">{$espece}</a>
					</div>
					<div class="col-xs-2" style="background-color:#f7f7f7;">
						{if $r.indice_rar}
							<a href="javascript:ouvre_rare('{$r.indice_rar}');">{$r.indice_rar}</a>
						{else}
							&nbsp;
						{/if}
					</div>
					<div class="col-xs-2">
						{if $r.categorie}
							<!-- <img style="cursor: pointer;" src="image/min-{$r.categorie|lower}.png" onclick="javascript:ouvre_statut('{$r.categorie}');"/>-->
							<a href="javascript:ouvre_statut('{$r.categorie}');">{$r.categorie}</a>
						{else}
							&nbsp;
						{/if}
					</div>
					<div class="col-xs-4" style="text-align:center;background-color:#f7f7f7; ">
						{assign var=ya value=$commune->entrepot_premiere_annee_obs($espece->id_espece)}
						{assign var=yb value=$commune->entrepot_derniere_annee_obs($espece->id_espece)}
						{if $ya eq $yb}
							{$ya}
						{else}
							{$ya} à {$yb}
						{/if}
					</div>
				</div>
			{else}
				{assign var=n_cache value=$n_cache+1}	
			{/if}
	{foreachelse}
		<div class="well">
			<h3>Aucun inventaire sur cette commune.</h3>
			<p>
				Si vous souhaitez contribuer à l'acquisition de connaissances
				faunistiques sur cette commnune vous pouvez contribuer en saisissant vos observations.<br/><br/>
				<a href="?page=saisie">Saisir mes données</a><br/>
			</p>
		</div>
	{/foreach}
		</div><!-- panel body -->
	</div>
</div><!-- /row -->
</div>
<div class="row">
	<div class="col-sm-12 alert alert-info">
		{include file="pas_exhaustif.tpl"}
	</div>
</div>

<script>
//{literal}
function init() {
	$('#btn_rech').click(function () {
		$("#div_rech_commune").toggle(
			function () {
				var inp = $("#in_commune");
				inp.autocomplete({
					source: '?page=autocomplete_commune',
					select: function (event,ui) {
						document.location.href = '?page=commune&id='+ui.item.value;
						event.target.value = '';
						return false;
					}
    				});
				inp.focus();
			}
		);
	});
}
init();
//{/literal}
</script>
<div style="clear:both;"></div>
{include file="foot.tpl"}

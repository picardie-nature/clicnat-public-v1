{include file="head.tpl"}
<div class="row">
	<div class="col-sm-9">
		{texte nom="promontoire_liste_det_znieff"}
	</div>
	<div class="col-sm-3">
		<div style="height:5em;"></div>
		<a class="btn btn-primary" href="?page=liste_csv&liste=lz"><span class="glyphicon glyphicon-download-alt"></span> Télécharger la liste</a>
	</div>
</div>
{assign var=classe value=''}
{foreach from=$lz item=esp name=rl}
	{if $classe != $esp->classe}
	    {if $classe != ""}</div>{/if}
	    {assign var=classe value=$esp->classe}
	     <div class="row">
		  <div class="col-sm-12">
		      <h2>
		         <img src="image/30x30_g_{$classe|lower}.png"/>
			 {$esp->get_classe_lib_par_lettre($esp->classe)}
		       </h2>
		  </div>
	     </div>
	     <div class="row">
	{/if}
	<div class="col-sm-4">
		<div class="well">
			{assign var=rr value=$esp->get_referentiel_regional()}
			<div onclick="javascript:ouvre_statut('{$rr.categorie}');" class="lr_statut">{$rr.categorie}</div>
			<a style="margin-bottom: 1px; padding-bottom:1px; border-bottom: 0px;" href="?page=fiche&id={$esp->id_espece}">{$esp}<br/>
			<span style="color:black;"><small>{$esp->nom_s}</small></span></a>
		</div>
	</div>
{/foreach}
</div>
{include file="pas_exhaustif.tpl"}
{include file="foot.tpl"}

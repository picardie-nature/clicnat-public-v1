{include file="head.tpl" titre_page="Études et travaux"}
<div class="row">
	<div class="col-sm-12">
		{texte nom="promontoire_travaux_1"}
	</div>
</div>
<div class="row">
	<div class="col-sm-3">
		<div class="nav list-group">
		{foreach from=$travaux item=t}
			<a class="list-group-item" href="#t{$t->id_travail}">{$t->titre}</a>
		{/foreach}
		</div>
	</div>
	<div class="col-sm-9">
	{foreach from=$travaux item=t}
		<div class="row">
			<div class="col-sm-12">
				<div class="panel panel-default panel-success">
					<div class="panel-heading" id="t{$t->id_travail}">{$t->titre}</div>
					<div class="panel-body">{$t->description|markdown}</div>
					<div class="panel-footer">
						{if $t->type eq "lien"}
							<a href="{$t->lien()}" class="btn btn-primary">Voir</a>
						{/if}
						{if $t->type eq "images"}
							{assign var=imgs value=$t->images()}
							{$imgs|@count} image(s)
							{foreach from=$imgs item=img}
								<a href="{$img}" class="btn" target="_blank"><span class="glyphicon glyphicon-picture"></span></a>
							{/foreach}
						{/if}
						{if $t->type eq "wfs"}
							<a href="?page=carte_wfs&id={$t->id_travail}" class="btn btn-primary">Consulter la carte</a>
						{/if}
						{if $t->type eq "wms"}
							<a href="?page=carte_wms&id={$t->id_travail}" class="btn btn-primary">Consulter la carte</a>
						{/if}

					</div>
				</div>
			</div>
		</div>
	{/foreach}
	</div>
</div>
{include file="foot.tpl"}

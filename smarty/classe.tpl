{include file="head.tpl" titre_page=$classe}
<h1>{$classe}</h1>
	{if $classe->a_classement_simple()}
		{assign var=nom_prec value=false}
		{foreach from=$classe->liste_especes_nom_simple() item=e}
			{if $nom_prec != $e.nom_simple}
				{if $nom_prec}
						</table>
					</div>
					</div>
				{/if}
				{assign var=nom_prec value=$e.nom_simple}
				<div class="desc lordre">
				<h1>{$e.nom_simple}</h1>
				<div>
					<table width="100%">
						<tr>
							<th>Ordre</th>
							<th>Famille</th>
							<th width="30%">Nom</th>
							<th width="30%">Nom scientifique</th>
						</tr>
			{/if}
			{if $e.absent_region neq "t"}
				<tr>
					<td>{$e.ordre}</td>
					<td>{$e.famille}</td>
					<td><a href="?page=fiche&id={$e.id_espece}">{$e.nom_f}</a></td>
					<td><a href="?page=fiche&id={$e.id_espece}"><i>{$e.nom_s}</i></a></td>
				</tr>
			{/if}
		{/foreach}
					</table>
				</div>
				</div>
	{else}
		{foreach from=$classe->get_ordres() item=ordre}
		{if strlen(trim($ordre.ordre))>0}
			<div class="desc lordre">
			<h1>{$ordre.ordre}</h1>
			<div>
				{assign var=md5 value=$ordre.md5}
				<table width="100%">
					<tr>
						<th>Ordre</th>
						<th>Famille</th>
						<th width="30%">Nom</th>
						<th width="30%">Nom scientifique</th>
					</tr>
					{foreach from=$classe->especes_ordre_md5($md5) item=e}
					{if $e.absent_region neq "t"}
					<tr>
						<td>{$e.ordre}</td>
						<td>{$e.famille}</td>
						<td><a href="?page=fiche&id={$e.id_espece}">{$e.nom_f}</a></td>
						<td><a href="?page=fiche&id={$e.id_espece}"><i>{$e.nom_s}</i></td>
					</tr>
					{/if}
					{/foreach}
				</table>
			</div>
			</div>
		{/if}
		{/foreach}
	{/if}
{include file="foot.tpl"}

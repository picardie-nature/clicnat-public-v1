{assign var=url_biblio value="http://archives.picardie-nature.org"}
<div class="media">
	<a href="{$url_biblio}/?action=lecteur&document={$article->id_biblio_document}#page{$article->premiere_page-1}" target="_blank" class="pull-left">
		<img src="{$url_biblio}/?action=page&document={$article->id_biblio_document}&w=160&n={$article->premiere_page-1}" class="ombre"/>
	</a>
	<div class="media-body">
		<h4 class="media-heading">{$article->titre}</h4>
		<p>
			paru dans <a href="{$url_biblio}/?action=lecteur&document={$article->id_biblio_document}" target="_blank">{$article->titre_doc}</a>
			{if $article->annee_publi}en {$article->annee_publi}{/if}
		</p>
		{if $article->auteurs|@count > 1}
		<p>
		Auteurs : 
		</p>
		{/if}
		{if $article->auteurs|@count}
			par <a href="{$url_biblio}/?action=auteur&id={$article->auteurs[0]->id_biblio_auteur}">{$article->auteurs[0]->prenom} {$article->auteurs[0]->nom}</a>
		{/if}
	</div>
</div>


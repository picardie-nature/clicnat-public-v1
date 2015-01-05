{include file="head.tpl" titre_page="Participez"}
<h1>Saisir des données</h1>
<div class="desc" style="width:49%; float:left;">
	<h1>Je n'ai pas encore de compte</h1>
	<div>
	<form method="post" action="http://poste.obs.picardie-nature.org/?t=inscription">
		<input type="hidden" name="ins" value="1"/>
		<p class="directive">Nom</p>
		<p class="valeur"><input type="text" name="nom" width="30"/></p>

		<p class="directive">Prénom</p>
		<p class="valeur"><input type="text" name="prenom" width="30"/></p>

		<p class="directive">Adresse e-mail</p>
		<p class="valeur"><input type="text" name="email" width="30"/></p>

		<br/>
		<p class="valeur"><input type="submit" value="Envoyer votre demande d'ouverture de compte"/></p>
	</form>
	<p>Deux étapes sont nécessaires à l'ouverture d'un nouveau compte observateur. Vous devez remplir le formulaire ci-contre. Vous recevrez un email de confirmation.</p>
	<p>Dans ce message de confirmation vous trouverez un lien qui nous permettra de valider votre adresse email.</p>
	<p>Il vous restera à accepter la charte du naturaliste pour obtenir votre mot de passe.</p>
	<p>Attention, vous devez utiliser votre nom et prénom, pas de pseudonyme. Les comptes créés avec un pseudonyme seront désactivés.</p>
	</div>
</div>
<div class="desc" style="width:49%; float:left;">
	<h1>J'ai déjà un compte</h1>
	<div>
		<form method="post" action="http://poste.obs.picardie-nature.org/?t=accueil">
			<p class="directive">Nom d'utilisateur</p>
			<p class="valeur"><input type="text" name="username" value="" id="fm"/></p>
			<p class="directive">Mot de passe</p>
			<p class="valeur"><input type="password" name="password" value=""/></p>
			<p class="valeur"><input type="hidden" name="act" value="login"/></p>
			<p class="valeur"><input type="submit" value="Envoyer"/></p>
		</form>
		<br/>
		<b>Mot de passe perdu ?</b><br/>
		<form method="post" action="http://poste.obs.picardie-nature.org/?t=accueil">
			<p class="directive">Votre adresse e-mail</p>
			<p class="valeur"><input type="text" name="adr"/></p>
			<p class="valeur"><input type="submit" value="Envoyer"/></p>
		</form>
	</div>
</div>
<div style="clear:both;"></div>
{include file="foot.tpl"}

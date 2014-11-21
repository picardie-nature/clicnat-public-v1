{include file="head.tpl"}
<h1>Contributeurs et partenaires</h1>
<div class="row">
	<div class="col-sm-6">
		<p>Les contributeurs sont de natures très variées :
			<ul>
				<li>Principalement bénévoles <small>({$pourcentage_benevole_pn}%)</small> et salariés <small>({$pourcentage_pro_pn}%)</small> de Picardie Nature</li>
				<li>
					Structures partenaires <small>({$pourcentage_autre}%)</small>
					{texte nom="promontoire_principaux_partenaires"}
				</li>
			</ul>
		</p>
	</div>
	<div class="col-sm-6">
		<div class="row">
			<div class="col-sm-6">
				<div class="well">
				<p>Le présent travail s'appuie sur une mobilisation de <span class="badge">{$n_observateurs}</span> contributeurs dont 
				<span class="badge">{$n_observateurs_2006}</span> contributeurs ont fourni des données « récentes » depuis 2006.</p>
				</div>
			</div>
			<div class="col-sm-6">
				<div class="well">
				<p>Le volume de données de la base de données s'élève actuellement à <span class="badge">{$n_citations}</span> ({$maj}).</p>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="col-sm-12">
				<p>La base de données et la restitution publique qui en est faite sur ce site ont été développées par 
				Picardie Nature avec le soutien financier de l'Europe, la DREAL Picardie (Direction Régionale 
				de l'Environnement, de l'Aménagement et du logement), le Conseil Régional de Picardie et les 
				Conseils Généraux de la Somme et de l'Aisne.</p>
			</div>
		</div>
	</div>
</div>
{include file="foot.tpl"}

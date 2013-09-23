{literal}
<style>
	.gras {
		font-weight: bold;
	}
</style>
<script>
function ouvre_statut(st)
{
	$('#S').dialog({modal: true, width:320, height:400, buttons: {Fermer: function (e) {$(this).dialog('close');}}});
	$('.cc').removeClass('gras');
	$('#c_'+st).addClass('gras');
	
}
</script>
{/literal}
<div class="w_info" id="S" title="Liste des niveaux de menace">
	<ul>
		<li class="cc" id="c_NE"><a target="_blank" href="?page=definitions#gl_ne">NE - Non évalué</a></li>
		<li class="cc" id="c_NA"><a target="_blank" href="?page=definitions#gl_na">NA - Non applicable</a></li>
		<li class="cc" id="c_DD"><a target="_blank" href="?page=definitions#gl_dd">DD - Données insuffisantes</a></li>
		<li class="cc" id="c_LC"><a target="_blank" href="?page=definitions#gl_lc">LC - Préoccupation mineure</a></li>
		<li class="cc" id="c_NT"><a target="_blank" href="?page=definitions#gl_nt">NT - Quasi menacée</a></li>
		<li class="cc" id="c_VU"><a target="_blank" href="?page=definitions#gl_vu">VU - Vulnérable</a></li>
		<li class="cc" id="c_EN"><a target="_blank" href="?page=definitions#gl_en">EN - En danger</a></li>
		<li class="cc" id="c_CR"><a target="_blank" href="?page=definitions#gl_cr">CR - En danger critique d'extinction</a></li>
		<li class="cc" id="c_RE"><a target="_blank" href="?page=definitions#gl_re">RE - Éteint au niveau régional</a></li>
	</ul>
	<!-- <li class="cc" id="c_II"><a target="_blank" href="?page=definitions#gl_ii">?? - Non renseigné</a></li> -->
	<!-- <p>Espèce dont nous ne pouvons indiquer le statut de menace. 4 raisons principales conduisent à cet état de fait : </p>
	<p> statut non reproducteur de l'espèce (ex : oiseau).
	espèce non identifiée au rang d'espèce (ex : grive sp)
	taxon évalué au rang d'espèce et non de la sous-espèce (et vice-versa)
	espèce non recensée dans le référentiel faune initial (ex : mollusques, coléoptères, araignées...)</p> -->

</div>

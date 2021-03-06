<?php
$couleurs2 = array("#DBF7F3","#F04E4C");
$couleurs3 = array("#DBF7F3","#E98683","#F04E4C");
$couleurs6 = array("#FFFFFF","#DBF7F3","#E69A98","#E98683","#F04E4C","#F90808");
$couleurs8 = array("#FFFFFF","#DBF7F3","#E2BEBA","#E69A98","#E98683","#ED6D6B","#F04E4C","#F90808");
$classes = array(
	"total" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 50,	"fillcolor" => $couleurs8[1]),
			array("min" => 50,	"max" => 100,	"fillcolor" => $couleurs8[2]),
			array("min" => 100,	"max" => 200,	"fillcolor" => $couleurs8[3]),
			array("min" => 200,	"max" => 400,	"fillcolor" => $couleurs8[4]),
			array("min" => 400,	"max" => 800,	"fillcolor" => $couleurs8[5]),
			array("min" => 800,	"max" => 1600,	"fillcolor" => $couleurs8[6]),
			array("min" => 1600,	"max" => 3200,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre total d'espèces",
		"property" => "total"
	),
	"classe_A" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 5,	"fillcolor" => $couleurs8[1]),
			array("min" => 5,	"max" => 10,	"fillcolor" => $couleurs8[2]),
			array("min" => 10,	"max" => 20,	"fillcolor" => $couleurs8[3]),
			array("min" => 20,	"max" => 40,	"fillcolor" => $couleurs8[4]),
			array("min" => 40,	"max" => 80,	"fillcolor" => $couleurs8[5]),
			array("min" => 80,	"max" => 160,	"fillcolor" => $couleurs8[6]),
			array("min" => 160,	"max" => 320,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre d'araignées",
		"property" => "classe_A"
	),
	"classe_B" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 2,	"fillcolor" => $couleurs8[1]),
			array("min" => 2,	"max" => 4,	"fillcolor" => $couleurs8[2]),
			array("min" => 4,	"max" => 6,	"fillcolor" => $couleurs8[3]),
			array("min" => 6,	"max" => 8,	"fillcolor" => $couleurs8[4]),
			array("min" => 8,	"max" => 10,	"fillcolor" => $couleurs8[5]),
			array("min" => 10,	"max" => 12,	"fillcolor" => $couleurs8[6]),
			array("min" => 12,	"max" => 20,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre d'amphibiens",
		"property" => "classe_B"
	),
	"classe_I" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 25,	"fillcolor" => $couleurs8[1]),
			array("min" => 25,	"max" => 50,	"fillcolor" => $couleurs8[2]),
			array("min" => 50,	"max" => 100,	"fillcolor" => $couleurs8[3]),
			array("min" => 100,	"max" => 200,	"fillcolor" => $couleurs8[4]),
			array("min" => 200,	"max" => 400,	"fillcolor" => $couleurs8[5]),
			array("min" => 400,	"max" => 800,	"fillcolor" => $couleurs8[6]),
			array("min" => 800,	"max" => 1600,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre d'insectes",
		"property" => "classe_I"
	),	
	"classe_M" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 5,	"fillcolor" => $couleurs8[1]),
			array("min" => 5,	"max" => 10,	"fillcolor" => $couleurs8[2]),
			array("min" => 10,	"max" => 15,	"fillcolor" => $couleurs8[3]),
			array("min" => 15,	"max" => 20,	"fillcolor" => $couleurs8[4]),
			array("min" => 20,	"max" => 30,	"fillcolor" => $couleurs8[5]),
			array("min" => 30,	"max" => 40,	"fillcolor" => $couleurs8[6]),
			array("min" => 40,	"max" => 60,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre de mammifères",
		"property" => "classe_M"
	),
	"classe_O" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 10,	"fillcolor" => $couleurs8[1]),
			array("min" => 10,	"max" => 20,	"fillcolor" => $couleurs8[2]),
			array("min" => 20,	"max" => 50,	"fillcolor" => $couleurs8[3]),
			array("min" => 50,	"max" => 90,	"fillcolor" => $couleurs8[4]),
			array("min" => 90,	"max" => 130,	"fillcolor" => $couleurs8[5]),
			array("min" => 130,	"max" => 200,	"fillcolor" => $couleurs8[6]),
			array("min" => 200,	"max" => 400,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre d'oiseaux",
		"property" => "classe_O"
	),
	"classe_P" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 5,	"fillcolor" => $couleurs8[1]),
			array("min" => 5,	"max" => 10,	"fillcolor" => $couleurs8[2]),
			array("min" => 10,	"max" => 15,	"fillcolor" => $couleurs8[3]),
			array("min" => 15,	"max" => 20,	"fillcolor" => $couleurs8[4]),
			array("min" => 20,	"max" => 30,	"fillcolor" => $couleurs8[5]),
			array("min" => 30,	"max" => 40,	"fillcolor" => $couleurs8[6]),
			array("min" => 40,	"max" => 60,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre poissons",
		"property" => "classe_P"
	),	
	"classe_R" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 2,	"fillcolor" => $couleurs8[1]),
			array("min" => 2,	"max" => 3,	"fillcolor" => $couleurs8[2]),
			array("min" => 3,	"max" => 4,	"fillcolor" => $couleurs8[3]),
			array("min" => 4,	"max" => 5,	"fillcolor" => $couleurs8[4]),
			array("min" => 5,	"max" => 6,	"fillcolor" => $couleurs8[5]),
			array("min" => 6,	"max" => 7,	"fillcolor" => $couleurs8[6]),
			array("min" => 7,	"max" => 10,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre de reptiles",
		"property" => "classe_R"
	),	
	"classe_L" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 3,	"fillcolor" => $couleurs8[1]),
			array("min" => 3,	"max" => 6,	"fillcolor" => $couleurs8[2]),
			array("min" => 6,	"max" => 10,	"fillcolor" => $couleurs8[3]),
			array("min" => 10,	"max" => 20,	"fillcolor" => $couleurs8[4]),
			array("min" => 20,	"max" => 30,	"fillcolor" => $couleurs8[5]),
			array("min" => 30,	"max" => 40,	"fillcolor" => $couleurs8[6]),
			array("min" => 40,	"max" => 60,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre de bivalves",
		"property" => "classe_L"
	),	
	"classe_N" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs2[0]),
			array("min" => 1,	"max" => 10,	"fillcolor" => $couleurs2[1])
		),
		"titre" => "Nombre d'anélides",
		"property" => "classe_N"
	),	
	"classe_C" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs6[0]),
			array("min" => 1,	"max" => 5,	"fillcolor" => $couleurs6[1]),
			array("min" => 5,	"max" => 10,	"fillcolor" => $couleurs6[2]),
			array("min" => 10,	"max" => 15,	"fillcolor" => $couleurs6[3]),
			array("min" => 15,	"max" => 20,	"fillcolor" => $couleurs6[4]),
			array("min" => 20,	"max" => 40,	"fillcolor" => $couleurs6[5])
		),
		"titre" => "Nombre de crustacés",
		"property" => "classe_C"
	),	
	"classe_H" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs2[0]),
			array("min" => 1,	"max" => 10,	"fillcolor" => $couleurs2[1])
		),
		"titre" => "Nombre d'hydrozoaires",
		"property" => "classe_H"
	),	
	"classe_S" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs3[0]),
			array("min" => 1,	"max" => 5,	"fillcolor" => $couleurs3[1]),
			array("min" => 5,	"max" => 10,	"fillcolor" => $couleurs3[2])
		),
		"titre" => "Nombre de chilopodes",
		"property" => "classe_S"
	),
	"classe_D" => array (
		"rules" => array(	
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs3[0]),
			array("min" => 1,	"max" => 5,	"fillcolor" => $couleurs3[1]),
			array("min" => 5,	"max" => 10,	"fillcolor" => $couleurs3[2])
		),
		"titre" => "Nombre de diplopodes",
		"property" => "classe_D"
	),	
	"classe_G" => array (
		"rules" => array(
			array("min" => 0,	"max" => 1,	"fillcolor" => $couleurs8[0]),
			array("min" => 1,	"max" => 5,	"fillcolor" => $couleurs8[1]),
			array("min" => 5,	"max" => 10,	"fillcolor" => $couleurs8[2]),
			array("min" => 10,	"max" => 20,	"fillcolor" => $couleurs8[3]),
			array("min" => 20,	"max" => 30,	"fillcolor" => $couleurs8[4]),
			array("min" => 30,	"max" => 40,	"fillcolor" => $couleurs8[5]),
			array("min" => 40,	"max" => 80,	"fillcolor" => $couleurs8[6]),
			array("min" => 80,	"max" => 160,	"fillcolor" => $couleurs8[7])
		),
		"titre" => "Nombre gastéropodes",
		"property" => "classe_G"
	)
);
?>

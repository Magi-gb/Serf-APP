# Guía d'estils - SerfApp

## Colors

* Fons: #F2F2E9
* Text: #0D0D0D
* Accent: #F2293A (vermell) #5E78E6 (blau) #EDD754 (groc)

*Els colors d'accent es poden alternar amb el color de fons segons necessitat. En aquests casos el color de text serà el #F2F2E9.*

## Tipografies

* Impact: Ús per títols amb la jerarquía més alta (h1 i h2).
* Arial Rounded MT Bold: Ús per títols de jerarquía Baixa (h3) i per accentuar text. S'ha de tenir en compte que és una tipografia de contrast, el seu ús no ha de ser massa regular.
* Arial: Ús per a cossos de text.

## Comportaments estètics dels elements:

* Enllaços:
	* Unhovered: Cos de text en negreta.
	* Hovered: Cos de text en negreta, *underlined* i amb color d'accent blau (preferiblement).
* Botons: Tots els botons, independentment del seu estat, han de tenir les cantonades arrodonides.
	* Unhovered: Cos de text en negreta
	* Hovered: Cos de text en negreta. *Faded resize* a una mida un 5% approx. més gran que la original.
	* Clicked: Cos de text en negreta. *Faded resize* a la mida original. Color de fons amb menys *brightness* i saturació.
* SideBar: Alineada sempre a l'esquerra. El color de fons ha de ser un color d'accent (preferiblement el blau).
	* Hovered: Cos de text en negreta. Canvi de color de fons del bloc sel·leccionat a #F2F2E9. Canvi del color de text al color de fons de l'element. 
	* Active: Es fixen els canvis de l'estat anterior.
* Blocs de input: Color de text és 0D0D0D a 50% d'opacitat. Per comoditat s'utilitzarà la traducción a rgba següent: (13, 13, 13, 0.5). Si és un input soble el color de fons base (#F2F2E9), el fons de l'element ha de ser blanc pur (#FFFFFF).
	* Focus: S'afegeix un *outline* amb un color d'accent. Groc si és selección normal, vermell si s'ha detectat qualsevol error a l'*input*.



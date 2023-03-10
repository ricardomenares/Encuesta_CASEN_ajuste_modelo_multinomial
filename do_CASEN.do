clear all
version 17
cd "C:\Users\ricar\Desktop\SEMESTRE 8\Análisis de datos categóricos\4. Trabajo final"

use "C:\Users\ricar\Desktop\SEMESTRE 8\Análisis de datos categóricos\4. Trabajo final\Casen_datos.dta"

keep folio id_persona id_vivienda sexo pco1 region estrato p5  cod_upm expr expp expc varstrat varunit s13 dautr qautr /*sist_salud*/
count
tabulate region sexo,chi2
tabulate region sexo [fw=expr]
tabulate sexo region if region==5 [fw=expr]

keep  if region==5 & pco1==1/*mantener solo región Valparaíso y jefes de hogar*/

/*Sistema de salud por quintil de ingresos per capita*/
tab s13  /*sistema de salud*/
tab s13[fw=expr]

drop if s13 ==2 | s13==4 |s13==9 

recode s13 (1=0) (3=1) (5=2)
lab define newlabel 0 "FONASA" 1 "ISAPRE" 2 "Otro", modify
lab val s13 newlabel

 
tab s13 [fw=expr]
tab dautr /*decil ingreso per capita*/
tab qautr /*quintil ingreso per capita*/
tab pco1 /*parentesco con jefe de hogar*/
tab r2     /*inmigrante o no 5 años antes de 2020*/
tab sexo 

tab sexo 
tab s13 sexo , chi2
tab s13 sexo , chi2
tab s13 sexo [fw=expr],chi2
ktau s13 sexo 


tab qautr s13 , chi2
tab s13 qautr, chi2 
tab qautr s13 [fw=expr], chi2
ktau qautr s13 

/*Gráficos individuales*/

graph bar (count), over(s13, relabel(1 "FONASA" 2 "ISAPRE" 3 "Otro")) ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 5500)) blabel(bar, format(%12,0gc)) b1title(Sistema previsional) bar(1,fcolor(blue) lcolor(black)) graphregion(color(white) lcolor(none))

graph bar (count) [fw=expr], over(s13, relabel(1 "FONASA" 2 "ISAPRE" 3 "Otro")) ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 550000)) blabel(bar, format(%12,0gc)) b1title(Sistema previsional) bar(1,fcolor(blue) lcolor(black)) graphregion(color(white) lcolor(none))

graph bar (count), over(sexo) ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 3200)) blabel(bar, format(%12,0gc)) b1title(Sexo) bar(1,fcolor(brown) lcolor(black)) graphregion(color(white) lcolor(none))

graph bar (count) [fw=expr], over(sexo) ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 350000)) blabel(bar, format(%12,0gc)) b1title(Sexo) bar(1,fcolor(brown) lcolor(black)) graphregion(color(white) lcolor(none))

graph bar (count), over(qautr) ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 1400)) blabel(bar, format(%12,0gc)) b1title(Quintil de ingresos per cápita regional) bar(1,fcolor(green) lcolor(black)) graphregion(color(white) lcolor(none))

graph bar (count) [fw=expr], over(qautr) ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 145000)) blabel(bar, format(%12,0gc)) b1title(Quintil de ingresos per cápita regional) bar(1,fcolor(green) lcolor(black)) graphregion(color(white) lcolor(none))

/*Gráficos mixtos*/
graph bar (count), over(sexo) over(s13, relabel(1 "FONASA" 2 "ISAPRE" 3 "Otro")) asyvar  ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 3000)) blabel(bar, format(%12,0gc)) b1title(Sistema previsional)  legend(position(0) bplacement(neast)) graphregion(color(white) lcolor(none))

graph bar (count) [fw=expr], over(sexo) over(s13, relabel(1 "FONASA" 2 "ISAPRE" 3 "Otro")) asyvar  ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 3000)) blabel(bar, format(%12,0gc)) b1title(Sistema previsional)  legend(position(0) bplacement(neast)) graphregion(color(white) lcolor(none))

graph bar (count), over(qautr) over(s13, relabel(1 "FONASA" 2 "ISAPRE" 3 "Otro")) asyvar  ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 1300)) blabel(bar, format(%12,0gc)) b1title(Sistema previsional) legend(position(0) bplacement(neast) lab(1 "Q1") lab(2 "Q2") lab(3 "Q3") lab(4 "Q4") lab(5 "Q5")) graphregion(color(white) lcolor(none)) legend(subtitle("Quintil"))

graph bar (count) [fw=expr], over(qautr) over(s13, relabel(1 "FONASA" 2 "ISAPRE" 3 "Otro")) asyvar  ytitle(Frecuencia) ylabel(,format(%12,0gc)) yscale(r(0 1300)) blabel(bar, format(%12,0gc)) b1title(Sistema previsional) legend(position(0) bplacement(neast) lab(1 "I") lab(2 "II") lab(3 "III") lab(4 "IV") lab(5 "V")) graphregion(color(white) lcolor(none)) legend(subtitle("Quintil"))


/* Definición muestra compleja*/
svyset varunit [pw=expr], strata(varstrat) singleunit(certainty)

/*Aplicación Regresión Multinomial*/

svy: mlogit s13 qautr sexo /*modelo con muestra compleja*/

test qautr
/*svy: mlogit s13 qautr sexo, rrr*/ /*odds ratio*/


predict p1 p2 p3

sort sexo
by sexo: tab p1 qautr
by sexo: tab p2 qautr
by sexo: tab p3 qautr


tab qautr sexo if qautr==5
tab p2 s13
tab p3 s13

list s13 p1 in 1/50
list s13 p2 in 1/50
list s13 p3 in 1/50

summarize p1
summarize p2
summarize p3


svyset _n 

svy: mlogit s13 qautr sexo

predict y1 y2 y3

sort qautr
twoway (line p1 qautr if sexo ==1) (line p1 qautr if sexo==2) (line y1 qautr if sexo==1) (line y1 qautr if sexo==2), legend(order(1 "Hombre m.c con FE" 2 "Mujer m.c con FE" 3 "Hombre m.a.s" 4 "Mujer m.a.s") ring(0) position(1) row(2)) ytitle("Probabilidad de pertenecer a sistema FONASA") graphregion(color(white) lcolor(none)) ylabel(,format(%03,1f)) xtitle(Quintil de ingresos autónomo per cápita regional)

twoway (line p2 qautr if sexo ==1) (line p2 qautr if sexo==2) (line y2 qautr if sexo==1) (line y2 qautr if sexo==2), legend(order(1 "Hombre m.c con FE" 2 "Mujer m.c con FE" 3 "Hombre m.a.s" 4 "Mujer m.a.s") ring(0) position(11) row(2))ytitle("Probabilidad de pertenecer a sistema ISAPRE") graphregion(color(white) lcolor(none)) ylabel(,format(%03,1f)) xtitle(Quintil de ingresos autónomo per cápita regional)

twoway (line p3 qautr if sexo ==1) (line p3 qautr if sexo==2) (line y3 qautr if sexo==1) (line y3 qautr if sexo==2), legend(order(1 "Hombre m.c con FE" 2 "Mujer m.c con FE" 3 "Hombre m.a.s" 4 "Mujer m.a.s") ring(0) position(1) row(2)) ytitle("Probabilidad de pertenecer a otro sistema") graphregion(color(white) lcolor(none)) ylabel(,format(%09,3fc)) xtitle(Quintil de ingresos autónomo per cápita regional)


test qautr sexo


/*Aplicación con muestreo aleatorio simple*/
svyset _n 

svy: mlogit s13 qautr sexo

predict y1 y2 y3

sort sexo
by sexo: tab y1 qautr
by sexo: tab y2 qautr
by sexo: tab y3 qautr
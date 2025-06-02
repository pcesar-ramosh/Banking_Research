********************************************************************************
* FINAL TEST RESEARCH PROPOSAL: MONETARY POLICY TRANSMISSION TO BANKING AND FINANCIAL INTE
* PROFESSOR: PhD. Carlos Burga
* TEACHER ASSISTANT: MSc. Luis Yepez
* AUTORS: Cesar Ramos and Ian Carrasco
* FECHA: March 5, 2025
* SUBJECT: Empirical Macrofinance (Master in Economic Engineering - UNI. Lima Peru)
* DESCRIPTION: 
*   Este script en Stata está diseñado para 
*
* ESTRUCTURA DEL CÓDIGO:
*   1. Configuración inicial del entorno
*   2. Importación y exploración inicial de datos
*   3. Manejo de variables problemáticas (strings, fechas, valores faltantes)
*   4. Definición del panel de datos
*   5. Análisis descriptivo
*   6. Transformaciones comunes de variables
*   7. Gestión de bases de datos (merge, append)
*   8. Manejo de outliers
*   9. Exportación de la base limpia
********************************************************************************

* 1. CONFIGURACIÓN INICIAL DEL ENTORNO ----------------------------------------
cls // Clean Screen
cd "G:\My Drive\Banking_FI_MacroFinance\main" // Current Directory
clear all     // Borra la memoria para evitar conflictos con datos previos
set more off  // Desactiva la pausa entre resultados largos
set mem 500m  // Ajusta la memoria disponible para manejo de bases grandes
set maxvar 10000 // Permite manejar hasta 10,000 variables en Stata

* 2. IMPORTACIÓN Y EXPLORACIÓN INICIAL DE DATOS ------------------------------

**# Bookmark #2


* Original Dataset Excel
import excel "G:\My Drive\Banking_FI_MacroFinance\main\input\Solicitud de Variables Government-Owned Banks __c_last.xlsx", sheet("Consolidado") cellrange(C9:BH13360) firstrow

save "G:\My Drive\Banking_FI_MacroFinance\main\input\Solicitud de Variables Government-Owned Banks __c_last.dta", replace


* Importar datos desde un archivo dta
use "input\Solicitud de Variables Government-Owned Banks __c_last.dta", clear

* Date treatment
gen fecha_num = real(fecha)

* 1. Convertir la variable 'date' de formato numérico AAAAMMDD a fecha mensual AAAAmMM
gen year = floor(fecha_num / 10000)    // Extraer el año
gen month = floor((fecha_num - year * 10000) / 100) // Extraer el mes
* Crear variable de fecha en formato YYYY-MM
gen date_month = ym(year, month)
* 2. Convertir la nueva variable a formato fecha mensual
format date_month %tm // Asigna formato de fecha mensual en Stata
* 3. Verificar que la conversión es correcta
list date year month date_month in 1/10 // Muestra las primeras 10 observaciones
* 4. Definir la estructura de panel (identificador de entidad y tiempo)


* Verificar estructura de la base de datos
describe     // Muestra información general de las variables
summarize    // Estadísticas básicas de todas las variables
list in 1/5  // Visualiza las primeras 5 observaciones



* 3. Convertir variables categóricas a factores numéricos
encode sigsub, gen(sigsub_id)       // Subsistemas  BCO BCP BSP CAC EFV IFD 
encode sigent, gen(sigent_id)       // Todas la Instituciones Financieras
encode subsis, gen(subsis_id)       // Subsistemas  BCO BCP BSP CAC EFV IFD  (Long Version)
encode entidad, gen(entidad_id)     // Todas la Instituciones Financieras (Long Version)

* Eliminamos las variables que ya no vamos a utilizar 
drop sigsub sigent subsis entidad fecha_num fecha

* Fijamos algunas variable para que aparescan al inicio
order year month date_month sigsub sigent subsis entidad, first



* Seleccionamos solo la Categoria de Bancos (Banco Multiples) que en Tamanio representan el 80% de la Cartera
* Filtrar solo "BANCOS" en la variable subs
* NOTA: Hay otro tipo de entidades como se detallan

* keep if sigsub == 1

		/*
		label list sigsub_id
		sigsub_id:
				   1 BCO
				   2 BCP
				   3 BSP
				   4 CAC
				   5 EFV
				   6 IFD
		(Long label)		   
				   1 BANCOS MÚLTIPLES
				   2 BANCOS PYME
				   3 COOPERATIVAS DE AHORRO Y CREDITO
				   4 ENTIDADES DE SEGUNDO PISO
				   5 ENTIDADES FINANCIERAS DE VIVIENDA
				   6 INSTITUCIONES FINANCIERAS DE DESARROLLO

		*/

		/*
		subs				Freq.	Percent	 Cum.
		BANCOS				10,145	 42.18	 42.18
		BANCOS PYME			 1,222	  5.08	 47.26
		COOPT AHO CRED		 5,169	 21.49	 68.75
		ENT SEGUNDO PISO	   806	  3.35	 72.11
		ENT FIN VIVIENDA	 1,019	  4.24	 76.34
		FOND FIN PRIVADOS	   104	  0.43	 76.77
		INST FIN DE DESAR	 5,534	 23.01	 99.78
		MUTU AHOR PRESTAM		52	  0.22	100.00	
		Total				24,051	100.00
		*/

		
* Definir el panel con la nueva variable
xtset  sigent_id date_month, monthly // "enti" es el identificador de entidad bancaria y "subs" es la class de tipo financiera	

* Agregar los labels desde un do que esta en utils\labels_variables
*************************************
do "utils\labels_variables_last.do"
************************************


* Feture Engineering
* Creamos la variables activos de corto plazo
gen activos_corto_plazo = (consum + empres + emp_gr + emp_me + emp_pe + microc + cred_co) / activo
label variable activos_corto_plazo "Activos de Corto Plazo"

gen activos_corto_liquido = (dispon + inv_tem + consum + empres + emp_gr + emp_me + emp_pe + microc + cred_co) / activo
label variable activos_corto_liquido "Activos de Corto Plazo (incluye activos líquidos)"

gen activos_liquidos = (dispon + inv_tem) / activo
label variable activos_liquidos "Activos Líquidos"

* Creamos las variables de pasivos de corto plazo
gen pasivos_corto_plazo = (dep_vp + dep_ch) / pasivo
label variable pasivos_corto_plazo "Pasivos de Corto Plazo"




* Regression Analisis
xtset sigent_id date_month // Define panel structure (bank-level data)
xtreg roe activo pasivo carvig carven consum empres microc pyme, fe vce(robust)


twoway (line roe date_month if entidad_id == 19, color(blue) lwidth(medium)), ///
    title("Evolución del ROE - Entidad 19") ///
    xlabel(, angle(45)) ///
    ytitle("ROE (%)") ///
    xtitle("Fecha")

	
	
* Graphic Analysis
	
graph bar (mean) activos_corto_liquido activos_corto_plazo activos_liquidos, ///
    over(sigsub_id, label(angle(45))) ///
    bar(1, color(blue)) ///
    bar(2, color(red)) ///
    bar(3, color(green)) ///
    ytitle("Proporción sobre Activos Totales") ///
    title("Comparación de Activos de Corto Plazo y Líquidos por Subsistema") ///
    subtitle("Período: Enero 2005 - Diciembre 2024") ///
    legend(order(1 "Corto y Líquido" 2 "Corto Plazo" 3 "Líquidos")) ///
    blabel(bar, format(%9.2f)) /// Muestra valores encima de las barras
    note("Fuente: ASFI") ///
    note("Nota: Activos Líquidos = Disponibilidades + Inversiones Temporarias")
graph save "output\figures\activo_subs_mean.gph", replace
	
graph bar (median) activos_corto_liquido activos_corto_plazo activos_liquidos, ///
    over(sigsub_id, label(angle(45))) ///
    bar(1, color(blue)) ///
    bar(2, color(red)) ///
    bar(3, color(green)) ///
    ytitle("Proporción sobre Activos Totales") ///
    title("Comparación de Activos de Corto Plazo y Líquidos por Subsistema") ///
    subtitle("Período: Enero 2005 - Diciembre 2024") ///
    legend(order(1 "Corto y Líquido" 2 "Corto Plazo" 3 "Líquidos")) ///
    blabel(bar, format(%9.2f)) /// Muestra valores encima de las barras
    note("Fuente: ASFI") ///
    note("Nota: Activos Líquidos = Disponibilidades + Inversiones Temporarias")
graph save "output\figures\activo_subs_median.gph", replace
	
	
* Graphic Analysis - Pasivos de Corto Plazo

graph bar (mean) pasivos_corto_plazo, ///
    over(sigsub_id, label(angle(45))) ///
    bar(1, color(blue)) ///
    ytitle("Proporción sobre Pasivos Totales") ///
    title("Comparación de Pasivos de Corto Plazo por Subsistema") ///
    subtitle("Período: Enero 2005 - Diciembre 2024") ///
    legend(order(1 "Pasivos de Corto Plazo")) ///
    blabel(bar, format(%9.2f)) /// Muestra valores encima de las barras
    note("Fuente: ASFI") ///
    note("Nota: Pasivos de Corto Plazo = Depósitos a la Vista + Cajas de Ahorro")

graph save "output\figures\pasivos_subs_mean.gph", replace


*** Definición de Activos y Pasivos de Corto Plazo ***
gen activos_cp = (cred_c + cred_p + emp_gr + emp_me + emp_pe + microc + cred_co) / activo
label variable activos_cp "Proxi de activos de corto plazo"

gen pasivos_cp = (dep_vp + dep_ch) / pasivo
label variable pasivos_cp "Proxi de pasivos de corto plazo"

*** Cálculo del Income Gap basado en Gómez et al. (2021) ***
gen income_gap = (activos_corto_plazo * activo - pasivos_corto_plazo * pasivo) / activo
label variable income_gap "Income Gap (Activos - Pasivos de Corto Plazo / Activos Totales)"


*1 Gráfico: Activos de Corto Plazo
graph bar (mean) activos_cp, ///
    over(sigsub_id, label(angle(45))) ///
    bar(1, color(green)) ///
    ytitle("Proporción sobre Activos Totales") ///
    title("Comparación de Activos de Corto Plazo por Subsistema") ///
    subtitle("Período: Enero 2005 - Diciembre 2024") ///
    legend(order(1 "Activos de Corto Plazo")) ///
    blabel(bar, format(%9.2f)) ///
    note("Fuente: ASFI") ///
    note("Nota: Activos de Corto Plazo = (Créditos de Consumo + Empresariales + Microcrédito + Comercio) / Activos Totales")

graph save "output/figures/activos_cp_subs_mean.gph", replace

*2 Gráfico: Pasivos de Corto Plazo
graph bar (mean) pasivos_cp, ///
    over(sigsub_id, label(angle(45))) ///
    bar(1, color(blue)) ///
    ytitle("Proporción sobre Pasivos Totales") ///
    title("Comparación de Pasivos de Corto Plazo por Subsistema") ///
    subtitle("Período: Enero 2005 - Diciembre 2024") ///
    legend(order(1 "Pasivos de Corto Plazo")) ///
    blabel(bar, format(%9.2f)) ///
    note("Fuente: ASFI") ///
    note("Nota: Pasivos de Corto Plazo = (Depósitos a la Vista + Cajas de Ahorro) / Pasivos Totales")

graph save "output/figures/pasivos_cp_subs_mean.gph", replace


*3  Gráfico: Income Gap
graph bar (mean) income_gap, ///
    over(sigsub_id, label(angle(45))) ///
    bar(1, color(red)) ///
    ytitle("Proporción sobre Activos Totales") ///
    title("Comparación de Income Gap por Subsistema") ///
    subtitle("Período: Enero 2005 - Diciembre 2024") ///
    legend(order(1 "Income Gap")) ///
    blabel(bar, format(%9.2f)) ///
    note("Fuente: ASFI") ///
    note("Nota: Income Gap = (Activos de Corto Plazo - Pasivos de Corto Plazo) / Activos Totales")

graph save "output/figures/income_gap_subs_mean.gph", replace



	
	
// Filter dataset to include only selected banks
gen incluir = inlist(sigent_id, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)

// Generate a line plot for all selected banks in a single graph
twoway ///
    (line roe date_month if sigent_id == 1, lcolor(blue) lwidth(medium)) ///
    (line roe date_month if sigent_id == 2, lcolor(red) lwidth(medium)) ///
    (line roe date_month if sigent_id == 3, lcolor(green) lwidth(medium)) ///
    (line roe date_month if sigent_id == 5, lcolor(orange) lwidth(medium)) ///
    (line roe date_month if sigent_id == 6, lcolor(purple) lwidth(medium)) ///
    (line roe date_month if sigent_id == 7, lcolor(cyan) lwidth(medium)) ///
    (line roe date_month if sigent_id == 8, lcolor(magenta) lwidth(medium)) ///
    (line roe date_month if sigent_id == 9, lcolor(brown) lwidth(medium)) ///
    (line roe date_month if sigent_id == 10, lcolor(navy) lwidth(medium)) ///
    (line roe date_month if sigent_id == 11, lcolor(olive) lwidth(medium)) ///
    (line roe date_month if sigent_id == 12, lcolor(teal) lwidth(medium)) ///
    (line roe date_month if sigent_id == 13, lcolor(maroon) lwidth(medium)) ///
    (line roe date_month if sigent_id == 14, lcolor(gray) lwidth(medium)) ///
    (line roe date_month if sigent_id == 15, lcolor(black) lwidth(medium)) ///
    (line roe date_month if sigent_id == 16, lcolor(pink) lwidth(medium)) ///
    (line roe date_month if sigent_id == 17, lcolor(gold) lwidth(medium)), ///
    title("Evolución del ROE por Banco") ///
    xlabel(, angle(45)) ///
    ytitle("ROE (%)") ///
    xtitle("Fecha") ///
    legend(order(1 "BCR" 2 "BCT" 3 "BDB" 4 "BEC" 5 "BFO" ///
                 6 "BFS" 7 "BGA" 8 "BIE" 9 "BIS" 10 "BME" ///
                 11 "BNA" 12 "BNB" 13 "BPR" 14 "BSC" ///
                 15 "BSO" 16 "BUN"))

				 

// Definir carpeta de salida relativa al path actual
local outfolder "output\figures"

// Crear y guardar gráficos individuales en la carpeta especificada
foreach bank in 1 2 3 5 6 7 8 9 10 11 12 13 14 15 16 17 {
    twoway (line roe date_month if sigent_id == `bank', ///
        lcolor(blue) lwidth(thick)), ///
        title("ROE - `: label (sigent_id) `bank''") ///
        xlabel(`=tm(2005m1)'(60)`=tm(2025m1)', angle(45) format(%tm)) ///
        ylabel(, format(%9.2f)) ///
        ytitle("ROE (%)") ///
        xtitle("Fecha")

    // Guardar el gráfico en la carpeta relativa a "main"
    graph save "`outfolder'\roe_bank_`bank'.gph", replace
}

// Combinar todos los gráficos en una sola figura
graph combine ///
    "`outfolder'\roe_bank_1.gph" "`outfolder'\roe_bank_2.gph" "`outfolder'\roe_bank_3.gph" "`outfolder'\roe_bank_5.gph" ///
    "`outfolder'\roe_bank_6.gph" "`outfolder'\roe_bank_7.gph" "`outfolder'\roe_bank_8.gph" "`outfolder'\roe_bank_9.gph" ///
    "`outfolder'\roe_bank_10.gph" "`outfolder'\roe_bank_11.gph" "`outfolder'\roe_bank_12.gph" "`outfolder'\roe_bank_13.gph" ///
    "`outfolder'\roe_bank_14.gph" "`outfolder'\roe_bank_15.gph" "`outfolder'\roe_bank_16.gph" "`outfolder'\roe_bank_17.gph", ///
    rows(4) cols(4) title("Evolución del ROE por Banco")

// Exportar la imagen combinada en PNG
graph export "`outfolder'\combined_roe.png", replace



*** Importar otros data sets
*** para luego hacer el merge

**# Bookmark #1


import excel "G:\My Drive\Banking_FI_MacroFinance\main\input\others\IGAE 12 act mes.xlsx", sheet("actividades") cellrange(A2:N422) firstrow clear


* Agregar los labels desde un do que esta en utils\labels_activities
*************************************
do "utils\labels_activities.do"
************************************


gen date_month = monthly(date, "YM")
format date_month %tm

save "G:\My Drive\Banking_FI_MacroFinance\main\input\others\IGAE 12 act mes.dta", replace






	

* Features Engineering
* Reemplazar "NULL" por valores faltantes solo en las variables indicadas
foreach var in pasi patr disp invt invp eerr depp_alv depp_cah depp_apf depp_res depp_pfa ///
              depe_alv depe_cah depe_apf depe_res depe_pfa dpf cart mora ingr ing_cart gast gast_depo {
    replace `var' = "." if `var' == "NULL"
}

* Verificar que el reemplazo se hizo correctamente
foreach var in pasi patr disp invt invp eerr depp_alv depp_cah depp_apf depp_res depp_pfa ///
              depe_alv depe_cah depe_apf depe_res depe_pfa dpf cart mora ingr ing_cart gast gast_depo {
    tab `var' if `var' == "NULL"
}

* Convertir estas variables a numéricas después de limpiar "NULL"
foreach var in pasi patr disp invt invp eerr depp_alv depp_cah depp_apf depp_res depp_pfa ///
              depe_alv depe_cah depe_apf depe_res depe_pfa dpf cart mora ingr ing_cart gast gast_depo {
    capture destring `var', replace
}

* Verificar que todas fueron convertidas correctamente a numéricas
summarize pasi patr disp invt invp eerr depp_alv depp_cah depp_apf depp_res depp_pfa ///
          depe_alv depe_cah depe_apf depe_res depe_pfa dpf cart mora ingr ing_cart gast gast_depo

		  
**** Poner Labels desde otro Do File
*** C:\Cesar\Research\Banking_FI_MacroFinance\main\utils\labels_variables.do	
*ssc install parallel 
*do "C:\Cesar\Research\Banking_FI_MacroFinance\main\utils\labels_variables.do"
* Ejecutar en Paralelor el otro do file
do "utils\labels_variables.do"
  
*duplicates drop enti_id date_month, force

* Identificador de Banco o Categoria
* Generamos le variable "id" combinadad con la region "dept" (1 al 9) Regiones en Bolivia
* Crear una variable que combine el banco (enti_id) y la región (dept)
gen enti_id_region = enti_id * 100 + dept  // Multiplica por 100 para evitar solapamiento

* Verificar la nueva variable
tab enti_id_region

* Definir el panel con la nueva variable
xtset enti_id_region date_month, monthly // "enti" es el identificador de entidad bancaria y "subs" es la class de tipo financiera
		  
* Modificamos las etquietas de los Bancos que se quedaron:
do "utils\new_labels_entities.do"
	
		  
* ####. Guardar la base limpia
* Solo consideramos bancos multiples
save "input\raw_sfin_preliminar_mulbank.dta", replace




* 4. DEFINICIÓN DEL PANEL ---------------------------------------------------

* Especificar el identificador de panel y la variable de tiempo
xtset id time  // 'id' es el identificador de la unidad, 'time' es el periodo

* Verificar estructura del panel
xtdescribe // Resumen del panel: balanceado/desbalanceado, número de observaciones

* 5. ANÁLISIS DESCRIPTIVO ---------------------------------------------------

summarize, detail // Estadísticas descriptivas avanzadas
tabulate sector_num // Distribución de categorías
xtsum variable_interes // Estadísticas dentro y entre unidades de panel

* 6. TRANSFORMACIONES COMUNES -----------------------------------------------

gen ln_variable = ln(variable)  // Transformación logarítmica
gen dif_variable = D.variable    // Diferencia primera
gen lag_variable = L.variable    // Retardo (L1)
gen lead_variable = F.variable   // Adelanto (Lead, F1)

* 7. MANEJO DE BASES DE DATOS -----------------------------------------------

* 7.1 Merge: Unir bases con variables comunes
merge 1:1 id time using "C:/ruta/dataset_adicional.dta", keepusing(variable_x variable_y) nogen

* 7.2 Append: Unir bases con misma estructura de variables
append using "C:/ruta/dataset_adicional.dta"

* 8. MANEJO DE OUTLIERS -----------------------------------------------------

* Winsorización: Limita los valores extremos a percentiles específicos
gen variable_wins = variable
replace variable_wins = r(p5) if variable < r(p5) | variable > r(p95)

* Eliminación de valores extremos
drop if variable > 1000

* 9. EXPORTACIÓN DE LA BASE LIMPIA ------------------------------------------

save "C:/ruta/dataset_limpio.dta", replace
export delimited "C:/ruta/dataset_limpio.csv", replace

********************************************************************************
* FIN DEL SCRIPT
********************************************************************************

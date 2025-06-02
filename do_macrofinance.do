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

* Importar datos desde un archivo dta
use "input\raw_sfin_preliminar.dta", clear
*import delimited "GovernmentOwnedBanks.dta", clear
*import excel "GovernmentOwnedBanks.xlsx", sheet("raw_sfin") cellrange(A2:AA24053) firstrow
* Alternativa si el archivo está en formato Stata

* Date treatment
* 1. Convertir la variable 'date' de formato numérico AAAAMMDD a fecha mensual AAAAmMM
gen year = floor(date / 10000)    // Extraer el año
gen month = floor((date - year * 10000) / 100) // Extraer el mes
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
encode subs, gen(subs_id)       // Convierte "BANCOS" a un identificador numérico
encode enti, gen(enti_id)       // Convierte nombres de bancos a números únicos



* Seleccionamos solo la Categoria de Bancos (Banco Multiples) que en Tamanio representan el 80% de la Cartera
* Filtrar solo "BANCOS" en la variable subs
* NOTA: Hay otro tipo de entidades como se detallan
keep if subs_id == 1

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

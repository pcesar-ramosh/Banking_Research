// Asignación de labels a las variables en Stata


    

label variable date_month "Fecha"
label variable sigsub_id "Sigla Subsistema"
label variable sigent_id "Sigla Entidad"
label variable subsis_id "Subsistema"
label variable entidad_id "Entidad"
label variable careje "Cartera Ejecución"
label variable carven "Cartera Vencida"
label variable carvig "Cartera Vigente"
label variable consum "Consumo"
label variable empres "Empresarial"
label variable microc "Microcrédito"
label variable pyme "Pyme"
label variable sn "SN"
label variable vivien "Vivienda"
label variable viv_otr "Otra Vivienda"
label variable viv_vis "VIS"
label variable cred_c "Consumo"
label variable cred_p "Productivo (A-G)"
label variable cred_t "Turismo"
label variable cred_pi "Propiedad Intelectual"
label variable cred_co "Comercio"
label variable cred_s "Servicios"
label variable cred_v "Veh. eléc, híbr y flex fuel"
label variable emp_gr "Gran Empresa"
label variable emp_hi "Hipotecario y Consumo"
label variable emp_me "Mediana Empresa"
label variable emp_mi "Microempresa"
label variable emp_nd "No definido"
label variable emp_pe "Pequeña Empresa"
label variable activo "Activo"
label variable pasivo "Pasivo"
label variable patrim "Patrimonio"
label variable dispon "Disponibilidades"
label variable inv_tem "Inversiones Temporarias"
label variable inv_per "Inversiones Permanentes"
label variable res_net "Resultado Neto de la Gestión"
label variable dep_vp "Depósitos del público a la vista"
label variable dep_ch "Depósitos en cajas de ahorro"
label variable dep_pf "Depósitos a plazo fijo"
label variable dep_re "Depósitos restringidas"
label variable dep_ac "Depósitos a plazo fijo con anotación en cuenta"
label variable dep_ev "Depósitos de las empresas públicas a la vista"
label variable dep_ec "Depósitos de las empresas públicas en cajas de ahorro"
label variable dep_ep "Depósitos de las empresas públicas a plazo fijo"
label variable dep_er "Depósitos de las empresas públicas restringidas"
label variable dep_ea "Depósitos de las empresas públicas a plazo fijo con anotación en cuenta"
label variable dep_cp "Depósitos a corto plazo en DPF"
label variable dep_dc "Depósitos de corto plazo"
label variable car_vig "Cartera vigente"
label variable car_mor "Cartera en mora"
label variable tot_ing "Total Ingresos"
label variable ing_car "Ingresos por cartera"
label variable tot_gas "Total Gastos"
label variable gas_dep "Gastos por depósitos"
label variable mor_ind "Índice de mora (%)"
label variable roe "ROE"
label variable roa "ROA"
label variable liqui "Liquidez (%)"

// Guardar cambios
save, replace

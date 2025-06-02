* Eliminar etiquetas previas
label drop enti_id

* Redefinir solo con las entidades actuales
label define enti_id_new ///
    1 "BANCO BISA S.A." ///
    2 "BANCO DE CREDITO DE BOLIVIA S.A." ///
    4 "BANCO DE LA NACION ARGENTINA S.A." ///
    5 "BANCO DO BRASIL S.A." ///
    6 "BANCO ECONOMICO S.A." ///
    7 "BANCO FASSIL S.A." ///
    8 "BANCO FORTALEZA S.A." ///
    9 "BANCO GANADERO S.A." ///
    10 "BANCO LOS ANDES PRO-CREDIT" ///
    11 "BANCO MERCANTIL SANTA CRUZ S.A." ///
    12 "BANCO NACIONAL DE BOLIVIA S.A." ///
    13 "BANCO PARA EL FOMENTO A INICIATIVAS ECONOMICAS S.A." ///
    14 "BANCO PRODEM S.A." ///
    18 "BANCO SOLIDARIO S.A." ///
    19 "BANCO UNION S.A."

* Asignar la nueva etiqueta a la variable
label values enti_id enti_id_new

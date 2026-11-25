# -*- coding: utf-8 -*-
"""
================================================================================
PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
Capa 8: Escuelas y Unidades de Postgrado UAGRM (18 Facultades + DGP)
Software SIG Destino: ArcGIS Desktop / ArcMap 10.8
Entorno de ejecucion: Python 2.7 (ArcGIS 10.8 - ArcPy)
================================================================================
"""

import os
import sys
import json
import codecs
import math
import arcpy

# Definicion del Sistema de Referencia de Coordenadas (CRS)
# WGS 84 / UTM Zone 20S (EPSG:32720) - Coordenadas metricas oficiales para Santa Cruz
ESRI_WKT1_UTM20S = (
    'PROJCS["WGS_1984_UTM_Zone_20S",'
    'GEOGCS["GCS_WGS_1984",'
    'DATUM["D_WGS_1984",'
    'SPHEROID["WGS_1984",6378137.0,298.257223563]],'
    'PRIMEM["Greenwich",0.0],'
    'UNIT["Degree",0.0174532925199433]],'
    'PROJECTION["Transverse_Mercator"],'
    'PARAMETER["False_Easting",500000.0],'
    'PARAMETER["False_Northing",10000000.0],'
    'PARAMETER["Central_Meridian",-63.0],'
    'PARAMETER["Scale_Factor",0.9996],'
    'PARAMETER["Latitude_Of_Origin",0.0],'
    'UNIT["Meter",1.0]]'
)

# Dataset base verificado de las 19 Unidades de Postgrado de la UAGRM
DATASET_POSTGRADOS = [
    {
        "id_postg": "PG-00",
        "cod_fac": "DGP",
        "nom_unidad": u"Escuela de Postgrado UAGRM (Dirección General de Posgrado)",
        "nom_facult": u"Rectorado / Dirección General de Posgrado",
        "tipo_ent": "Rectorado_DGP",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Zona Central",
        "modulo_pab": u"Edif. Museo Noel Kempff 5to piso / Pab. 126 Aula 4",
        "direccion": u"Av. Irala N° 565, 5to piso",
        "lat_wgs84": -17.79277,
        "lon_wgs84": -63.18183,
        "telefono": "3-3342899",
        "correo": "posgrado@uagrm.edu.bo",
        "horario": "L-V 08:30-15:30",
        "estado_geo": "Verificado",
        "programas": u"Doctorados, Maestrías Institucionales, Diplomados en Educación Superior",
        "sitio_web": "https://posgrado.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-00.jpg"
    },
    {
        "id_postg": "PG-01",
        "cod_fac": "FICH",
        "nom_unidad": u"Unidad de Postgrado FICH",
        "nom_facult": u"Facultad Integral del Chaco",
        "tipo_ent": "Sede_Provincial",
        "ambito": "Provincial",
        "municipio": "Camiri",
        "campus": "Sede Provincial",
        "modulo_pab": "Sede FICH",
        "direccion": u"Av. Humberto Suárez Roca",
        "lat_wgs84": -20.03331,
        "lon_wgs84": -63.52794,
        "telefono": "3-9522979",
        "correo": "postgradofich@uagrm.edu.bo",
        "horario": "S/D",
        "estado_geo": "Verificado",
        "programas": u"Maestrías en Desarrollo Regional, Diplomados Petroleros y Ambientales",
        "sitio_web": "https://fich.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-01.jpg"
    },
    {
        "id_postg": "PG-02",
        "cod_fac": "FINOR",
        "nom_unidad": u"Unidad de Postgrado FINOR",
        "nom_facult": u"Facultad Integral del Norte",
        "tipo_ent": "Sede_Provincial",
        "ambito": "Provincial",
        "municipio": "Montero",
        "campus": "Sede Provincial",
        "modulo_pab": "Sede FINOR",
        "direccion": u"Barrio Urkupiña, Av. Circunvalación Noroeste",
        "lat_wgs84": -17.33831,
        "lon_wgs84": -63.26956,
        "telefono": "3-9227259",
        "correo": "postgradofinor@uagrm.edu.bo",
        "horario": "L-V 08:00-15:00",
        "estado_geo": "Verificado",
        "programas": u"Diplomados Agroindustriales, Maestrías en Gestión Productiva",
        "sitio_web": "https://finor.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-02.jpg"
    },
    {
        "id_postg": "PG-03",
        "cod_fac": "FCCASCGF",
        "nom_unidad": u"Unidad de Postgrado Ciencias Contables",
        "nom_facult": u"Facultad de Ciencias Contables, Auditoría, Sistemas de Control de Gestión y Finanzas",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Campus Universitario",
        "modulo_pab": "Campus Universitario",
        "direccion": u"Av. Centenario entre 1er y 2do anillo",
        "lat_wgs84": -17.77850,
        "lon_wgs84": -63.19320,
        "telefono": "S/D",
        "correo": "postgradocontaduria@uagrm.edu.bo",
        "horario": "L 08:00-18:30 / Ma-V 08:30-18:30",
        "estado_geo": "Revisar_Campo",
        "programas": u"Maestrías en Auditoría, Finanzas Corporativas y Gestión Tributaria",
        "sitio_web": "https://contaduria.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-03.jpg"
    },
    {
        "id_postg": "PG-04",
        "cod_fac": "FCHDA",
        "nom_unidad": u"Unidad de Postgrado FCHDA",
        "nom_facult": u"Facultad de Ciencias del Hábitat, Diseño y Arte",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Externo",
        "modulo_pab": "Edificio FCHDA 1er Piso",
        "direccion": u"Av. San Martín N° 146",
        "lat_wgs84": -17.77006,
        "lon_wgs84": -63.19206,
        "telefono": "3-3364664",
        "correo": "postgradohabitat@uagrm.edu.bo",
        "horario": "S/D",
        "estado_geo": "Revisar_Campo",
        "programas": u"Maestrías en Arquitectura y Urbanismo, Diplomados en Diseño Sostenible",
        "sitio_web": "https://habitat.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-04.jpg"
    },
    {
        "id_postg": "PG-05",
        "cod_fac": "FH",
        "nom_unidad": u"Unidad de Postgrado Humanidades",
        "nom_facult": u"Facultad de Humanidades",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Campus Universitario",
        "modulo_pab": "Campus Universitario",
        "direccion": u"Calle México esq. Calle Venezuela",
        "lat_wgs84": -17.77790,
        "lon_wgs84": -63.19050,
        "telefono": "61538808",
        "correo": "postgradohumanidades@uagrm.edu.bo",
        "horario": "L-V 08:00-15:00",
        "estado_geo": "Revisar_Campo",
        "programas": u"Maestrías en Educación Superior, Diplomados en Lingüística y Psicología",
        "sitio_web": "https://humanidades.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-05.jpg"
    },
    {
        "id_postg": "PG-06",
        "cod_fac": "FCSH",
        "nom_unidad": u"Unidad de Postgrado en Salud UAGRM",
        "nom_facult": u"Facultad de Ciencias de la Salud Humana",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Zona Central",
        "modulo_pab": "Edificio Salud",
        "direccion": u"Calle Bolívar N° 228",
        "lat_wgs84": -17.78340,
        "lon_wgs84": -63.17820,
        "telefono": "3-3395008",
        "correo": "postgradosalud@uagrm.edu.bo",
        "horario": "L-V 08:30-15:30",
        "estado_geo": "Revisar_Campo",
        "programas": u"Especialidades Médicas, Maestrías en Salud Pública y Epidemiología",
        "sitio_web": "https://salud.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-06.jpg"
    },
    {
        "id_postg": "PG-07",
        "cod_fac": "FCJPSRI",
        "nom_unidad": u"Unidad de Posgrado FCJPSRRII",
        "nom_facult": u"Facultad de Ciencias Jurídicas, Políticas, Sociales y Relaciones Internacionales",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Campus Universitario",
        "modulo_pab": "Campus Universitario",
        "direccion": u"Av. Centenario / Av. Hernando Sanabria casi 2do anillo",
        "lat_wgs84": -17.77919,
        "lon_wgs84": -63.19294,
        "telefono": "76895500",
        "correo": "postgradojuridicas@uagrm.edu.bo",
        "horario": "S/D",
        "estado_geo": "Verificado",
        "programas": u"Maestrías en Derecho Constitucional, Penal, Corporativo y RRII",
        "sitio_web": "https://juridicas.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-07.jpg"
    },
    {
        "id_postg": "PG-08",
        "cod_fac": "FCEE",
        "nom_unidad": u"UAGRM Business School",
        "nom_facult": u"Facultad de Ciencias Económicas y Empresariales",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Zona Central",
        "modulo_pab": "Edificio Propio",
        "direccion": u"Calle Gral. Agustín Saavedra N° 137 esq. Chuquisaca",
        "lat_wgs84": -17.79031,
        "lon_wgs84": -63.17894,
        "telefono": "3-3366814",
        "correo": "contacto@uagrmbs.edu.bo",
        "horario": "L-V 08:30-15:30",
        "estado_geo": "Verificado",
        "programas": u"Maestrías Ejecutivas, MBA Internacional, Diplomados en Marketing y Finanzas",
        "sitio_web": "https://www.uagrmbs.edu.bo",
        "url_foto": "assets/fotos/PG-08.jpg"
    },
    {
        "id_postg": "PG-09",
        "cod_fac": "FCV",
        "nom_unidad": u"Unidad de Postgrado Veterinaria",
        "nom_facult": u"Facultad de Ciencias Veterinarias",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Ciudad Universitaria",
        "modulo_pab": u"Módulo 247",
        "direccion": u"Av. 26 de Febrero entre Av. Busch y Centenario",
        "lat_wgs84": -17.77706,
        "lon_wgs84": -63.19581,
        "telefono": "62217301",
        "correo": "postgradofvc@uagrm.edu.bo",
        "horario": "S/D",
        "estado_geo": "Verificado",
        "programas": u"Especialidades en Cirugía Veterinaria, Maestrías en Sanidad Animal y Zootecnia",
        "sitio_web": "https://veterinaria.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-09.jpg"
    },
    {
        "id_postg": "PG-10",
        "cod_fac": "FCA",
        "nom_unidad": u"Unidad de Postgrado Ciencias Agrícolas (UPCA)",
        "nom_facult": u"Facultad de Ciencias Agrícolas",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Externo",
        "modulo_pab": "Edificio UPCA-FCA",
        "direccion": u"Av. Cristóbal de Mendoza N° 900 (2do anillo)",
        "lat_wgs84": -17.77356,
        "lon_wgs84": -63.16669,
        "telefono": "63437106 / 77635020",
        "correo": "postgradoagricolas@uagrm.edu.bo",
        "horario": "S/D",
        "estado_geo": "Verificado",
        "programas": u"Maestrías en Agricultura de Precisión, Gestión de Cuencas y Riego",
        "sitio_web": "https://agricolas.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-10.jpg"
    },
    {
        "id_postg": "PG-11",
        "cod_fac": "FCET",
        "nom_unidad": u"UPCET / Escuela de Ingeniería",
        "nom_facult": u"Facultad de Ciencias Exactas y Tecnología",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Campus Universitario",
        "modulo_pab": u"Sede 1 Campus / Sede 2 Módulo 290",
        "direccion": u"Calle México esq. Venezuela (y Av. Busch Módulo 290)",
        "lat_wgs84": -17.77794,
        "lon_wgs84": -63.19044,
        "telefono": "60008313",
        "correo": "info@ei-uagrm.edu.bo",
        "horario": "L-V 08:00-18:30",
        "estado_geo": "Verificado",
        "programas": u"Maestrías en Ingeniería de Procesos, Petróleo y Gas, Telecomunicaciones",
        "sitio_web": "https://ingenieria.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-11.jpg"
    },
    {
        "id_postg": "PG-12",
        "cod_fac": "FP",
        "nom_unidad": u"Escuela Superior Politécnica (UPFP)",
        "nom_facult": u"Facultad Politécnica",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Ciudad Universitaria",
        "modulo_pab": u"Módulo 212, 4to piso",
        "direccion": u"Av. Busch 2do anillo, Ciudad Universitaria",
        "lat_wgs84": -17.77520,
        "lon_wgs84": -63.19450,
        "telefono": "63339696",
        "correo": "info@upfp.edu.bo",
        "horario": "L-V 08:00-12:00 y 15:00-19:00",
        "estado_geo": "Revisar_Campo",
        "programas": u"Diplomados Técnicos en Automatización, Mantenimiento Industrial y Redes",
        "sitio_web": "https://politecnica.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-12.jpg"
    },
    {
        "id_postg": "PG-13",
        "cod_fac": "FINI",
        "nom_unidad": u"Unidad de Postgrado FINI",
        "nom_facult": u"Facultad Integral de Ichilo",
        "tipo_ent": "Sede_Provincial",
        "ambito": "Provincial",
        "municipio": u"Yapacaní",
        "campus": "Sede Provincial",
        "modulo_pab": "Sede FINI",
        "direccion": u"Barrio 12 de Octubre, Av. Santa Cruz s/n",
        "lat_wgs84": -17.40250,
        "lon_wgs84": -63.88490,
        "telefono": "69010491",
        "correo": "postgradofini@uagrm.edu.bo",
        "horario": "L-V 08:30-15:30",
        "estado_geo": "Revisar_Campo",
        "programas": u"Diplomados en Desarrollo Agropecuario, Maestrías en Gestión Sostenible",
        "sitio_web": "https://fini.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-13.jpg"
    },
    {
        "id_postg": "PG-14",
        "cod_fac": "FAICHI",
        "nom_unidad": u"Unidad de Postgrado FAICHI",
        "nom_facult": u"Facultad Integral Chiquitana",
        "tipo_ent": "Sede_Provincial",
        "ambito": "Provincial",
        "municipio": "San Ignacio de Velasco",
        "campus": "Sede Provincial",
        "modulo_pab": "Sede FAICHI",
        "direccion": u"Calle Junín Final y Viador Moreno s/n",
        "lat_wgs84": -16.38444,
        "lon_wgs84": -60.96744,
        "telefono": "S/D",
        "correo": "f_integralchiquitana@uagrm.edu.bo",
        "horario": "S/D",
        "estado_geo": "Verificado",
        "programas": u"Diplomados en Recursos Naturales, Maestrías en Desarrollo Comunitario",
        "sitio_web": "https://faichi.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-14.jpg"
    },
    {
        "id_postg": "PG-15",
        "cod_fac": "FCFB",
        "nom_unidad": u"Unidad de Posgrado Farmacia y Bioquímica",
        "nom_facult": u"Facultad de Ciencias Farmacéuticas y Bioquímicas",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Ciudad Universitaria",
        "modulo_pab": u"Módulo 280",
        "direccion": u"Av. Busch entre 2do y 3er anillo",
        "lat_wgs84": -17.77669,
        "lon_wgs84": -63.19094,
        "telefono": "3-3366270",
        "correo": "posgradobiofar@hotmail.com",
        "horario": "S/D",
        "estado_geo": "Verificado",
        "programas": u"Diplomados en Análisis Clínicos, Maestrías en Toxicología y Bioquímica",
        "sitio_web": "https://biofar.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-15.jpg"
    },
    {
        "id_postg": "PG-16",
        "cod_fac": "FICCT",
        "nom_unidad": u"UAGRM School of Engineering (SOE)",
        "nom_facult": u"Facultad de Ingeniería en Ciencias de la Computación y Telecomunicaciones",
        "tipo_ent": "Unidad_Facultativa",
        "ambito": "Urbano",
        "municipio": u"Santa Cruz de la Sierra",
        "campus": "Ciudad Universitaria",
        "modulo_pab": u"Módulo 232 / Módulo 236",
        "direccion": u"Av. Busch, Ciudad Universitaria",
        "lat_wgs84": -17.77631,
        "lon_wgs84": -63.19506,
        "telefono": "73600888 / 3-3553636",
        "correo": "postgradoficct@uagrm.edu.bo",
        "horario": "L-V 09:00-16:00",
        "estado_geo": "Verificado",
        "programas": u"Maestrías en Ciberseguridad, Ciencia de Datos, Software y Redes",
        "sitio_web": "https://ficct.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-16.jpg"
    },
    {
        "id_postg": "PG-17",
        "cod_fac": "FIVC",
        "nom_unidad": u"Unidad de Postgrado FIVC",
        "nom_facult": u"Facultad Integral de los Valles Cruceños",
        "tipo_ent": "Sede_Provincial",
        "ambito": "Provincial",
        "municipio": "Vallegrande",
        "campus": "Sede Provincial",
        "modulo_pab": "Sede FIVC",
        "direccion": u"Av. Tecnológico y Av. Ejército",
        "lat_wgs84": -18.48631,
        "lon_wgs84": -64.10094,
        "telefono": "3-9422317",
        "correo": "postgradofivc@uagrm.edu.bo",
        "horario": "L-V 07:00-18:00",
        "estado_geo": "Verificado",
        "programas": u"Diplomados en Agroecología, Maestrías en Desarrollo Rural y Gestión Hídrica",
        "sitio_web": "https://fivc.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-17.jpg"
    },
    {
        "id_postg": "PG-18",
        "cod_fac": "FINE",
        "nom_unidad": u"Unidad de Postgrado FINE",
        "nom_facult": u"Facultad Integral del Nor-Este",
        "tipo_ent": "Sede_Provincial",
        "ambito": "Provincial",
        "municipio": u"San Julián",
        "campus": "Sede Provincial",
        "modulo_pab": "Sede FINE",
        "direccion": u"Barrio 6 de Agosto, Av. Marcelo Quiroga",
        "lat_wgs84": -16.90650,
        "lon_wgs84": -62.61680,
        "telefono": "3-9658002",
        "correo": "postgradofine@uagrm.edu.bo",
        "horario": "S/D",
        "estado_geo": "Revisar_Campo",
        "programas": u"Diplomados en Producción Agrícola Sostenible y Gestión Educativa",
        "sitio_web": "https://fine.uagrm.edu.bo",
        "url_foto": "assets/fotos/PG-18.jpg"
    }
]

# Esquema de campos para puntos (DBF <= 10 caracteres) con Alias para Geodatabase
FIELDS_PUNTOS = [
    ("id_postg", "TEXT", 10, u"Identificador de Postgrado"),
    ("cod_fac", "TEXT", 12, u"Sigla de Facultad"),
    ("nom_unidad", "TEXT", 120, u"Nombre de la Unidad de Postgrado"),
    ("nom_facult", "TEXT", 120, u"Facultad Académica"),
    ("tipo_ent", "TEXT", 25, u"Tipo de Entidad"),
    ("ambito", "TEXT", 15, u"Ámbito Territorial"),
    ("municipio", "TEXT", 40, u"Municipio de Radicatoria"),
    ("campus", "TEXT", 40, u"Campus o Predio"),
    ("modulo_pab", "TEXT", 50, u"Módulo o Pabellón"),
    ("direccion", "TEXT", 150, u"Dirección Oficial"),
    ("lat_wgs84", "DOUBLE", None, u"Latitud (WGS 84)"),
    ("lon_wgs84", "DOUBLE", None, u"Longitud (WGS 84)"),
    ("lat_ruta", "DOUBLE", None, u"Latitud Nodo de Acceso"),
    ("lon_ruta", "DOUBLE", None, u"Longitud Nodo de Acceso"),
    ("dist_via_m", "DOUBLE", None, u"Distancia a la Vía (m)"),
    ("telefono", "TEXT", 40, u"Teléfono / WhatsApp"),
    ("correo", "TEXT", 80, u"Correo Electrónico"),
    ("horario", "TEXT", 60, u"Horario de Atención"),
    ("estado_geo", "TEXT", 20, u"Estado Geográfico"),
    ("cod_qr", "TEXT", 30, u"Código QR"),
    ("programas", "TEXT", 120, u"Programas de Postgrado"),
    ("sitio_web", "TEXT", 120, u"Sitio Web Oficial"),
    ("url_foto", "TEXT", 150, u"Ruta de Fotografía"),
    ("area_m2", "DOUBLE", None, u"Superficie Estimada (m²)")
]

FIELDS_POLYGONS = [
    ("id_postg", "TEXT", 10, u"Identificador de Postgrado"),
    ("cod_fac", "TEXT", 12, u"Sigla de Facultad"),
    ("nom_unidad", "TEXT", 120, u"Nombre de la Unidad de Postgrado"),
    ("tipo_geom", "TEXT", 20, u"Tipo de Geometría"),
    ("area_m2", "DOUBLE", None, u"Superficie Calculada (m²)")
]

FIELDS_NODOS = [
    ("id_postg", "TEXT", 10, u"Identificador de Postgrado"),
    ("cod_fac", "TEXT", 12, u"Sigla de Facultad"),
    ("nom_unidad", "TEXT", 120, u"Nombre de la Unidad de Postgrado"),
    ("tipo_nodo", "TEXT", 25, u"Tipo de Nodo de Acceso"),
    ("lat_ruta", "DOUBLE", None, u"Latitud Nodo de Acceso"),
    ("lon_ruta", "DOUBLE", None, u"Longitud Nodo de Acceso"),
    ("dist_via_m", "DOUBLE", None, u"Distancia a la Vía (m)"),
    ("cod_qr", "TEXT", 30, u"Código QR")
]

def ensure_cpg_and_prj(folder, shp_name):
    """Genera los archivos .cpg (UTF-8) y .prj (ESRI WKT1) obligatorios para ArcMap 10.8."""
    base = os.path.splitext(shp_name)[0]
    cpg_path = os.path.join(folder, base + ".cpg")
    with open(cpg_path, "w") as f:
        f.write("UTF-8")
    prj_path = os.path.join(folder, base + ".prj")
    with open(prj_path, "w") as f:
        f.write(ESRI_WKT1_UTM20S)

def apply_aliases_gdb(fc_path, fields_def):
    """Asigna alias profesionales a los campos de una Feature Class dentro de una GDB."""
    for item in fields_def:
        fname = item[0]
        falias = item[3] if len(item) > 3 else fname
        try:
            arcpy.AlterField_management(fc_path, fname, new_field_alias=falias)
        except Exception as e:
            print "Aviso al aplicar alias en %s (%s): %s" % (fname, fc_path, e)

def main():
    print "Iniciando generacion de capas SIG para ArcMap 10.8..."
    # Uso de rutas dinámicas relativas
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    out_dir = os.path.join(project_root, "output_postgrados")
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = out_dir

    sr_wgs84 = arcpy.SpatialReference(4326)
    sr_utm20s = arcpy.SpatialReference()
    sr_utm20s.loadFromString(ESRI_WKT1_UTM20S)

    print "CRS WGS84: %s" % sr_wgs84.name
    print "CRS UTM20S: %s" % sr_utm20s.name

    # =========================================================================
    # 1. CREACION DE LA CAPA DE PUNTOS: postgrados_uagrm_pts.shp
    # =========================================================================
    shp_pts_name = "postgrados_uagrm_pts.shp"
    shp_pts_path = os.path.join(out_dir, shp_pts_name)
    if arcpy.Exists(shp_pts_name):
        arcpy.Delete_management(shp_pts_name)

    arcpy.CreateFeatureclass_management(out_dir, shp_pts_name, "POINT", spatial_reference=sr_utm20s)
    ensure_cpg_and_prj(out_dir, shp_pts_name)

    for item in FIELDS_PUNTOS:
        fn, ftype, flen = item[0], item[1], item[2]
        if ftype == "TEXT":
            arcpy.AddField_management(shp_pts_name, fn, ftype, field_length=flen)
        else:
            arcpy.AddField_management(shp_pts_name, fn, ftype)

    field_names_pts = ["SHAPE@"] + [f[0] for f in FIELDS_PUNTOS]

    with arcpy.da.InsertCursor(shp_pts_name, field_names_pts) as cursor:
        for reg in DATASET_POSTGRADOS:
            pt_wgs = arcpy.Point(reg["lon_wgs84"], reg["lat_wgs84"])
            geom_wgs = arcpy.PointGeometry(pt_wgs, sr_wgs84)
            geom_utm = geom_wgs.projectAs(sr_utm20s)

            lat_ruta = reg["lat_wgs84"]
            lon_ruta = reg["lon_wgs84"]
            dist_via = 0.0
            cod_qr = u"UAGRM-PG-" + reg["cod_fac"]
            area_m2 = 0.0

            row_values = [
                geom_utm,
                reg["id_postg"],
                reg["cod_fac"],
                reg["nom_unidad"],
                reg["nom_facult"],
                reg["tipo_ent"],
                reg["ambito"],
                reg["municipio"],
                reg["campus"],
                reg["modulo_pab"],
                reg["direccion"],
                reg["lat_wgs84"],
                reg["lon_wgs84"],
                lat_ruta,
                lon_ruta,
                dist_via,
                reg["telefono"],
                reg["correo"],
                reg["horario"],
                reg["estado_geo"],
                cod_qr,
                reg["programas"],
                reg["sitio_web"],
                reg["url_foto"],
                area_m2
            ]
            cursor.insertRow(row_values)

    ensure_cpg_and_prj(out_dir, shp_pts_name)
    count_pts = arcpy.GetCount_management(shp_pts_name)[0]
    print "Capa de puntos creada con exito: %s (%s registros)" % (shp_pts_name, count_pts)

    # =========================================================================
    # 2. CREACION DE LA CAPA DE POLIGONOS: postgrados_uagrm_poly.shp
    # =========================================================================
    shp_poly_name = "postgrados_uagrm_poly.shp"
    shp_poly_path = os.path.join(out_dir, shp_poly_name)
    if arcpy.Exists(shp_poly_name):
        arcpy.Delete_management(shp_poly_name)

    arcpy.CreateFeatureclass_management(out_dir, shp_poly_name, "POLYGON", spatial_reference=sr_utm20s)
    ensure_cpg_and_prj(out_dir, shp_poly_name)

    for item in FIELDS_POLYGONS:
        fn, ftype, flen = item[0], item[1], item[2]
        if ftype == "TEXT":
            arcpy.AddField_management(shp_poly_name, fn, ftype, field_length=flen)
        else:
            arcpy.AddField_management(shp_poly_name, fn, ftype)

    field_names_poly = ["SHAPE@"] + [f[0] for f in FIELDS_POLYGONS]

    with arcpy.da.InsertCursor(shp_poly_name, field_names_poly) as cursor:
        for reg in DATASET_POSTGRADOS:
            pt_wgs = arcpy.Point(reg["lon_wgs84"], reg["lat_wgs84"])
            geom_wgs = arcpy.PointGeometry(pt_wgs, sr_wgs84)
            geom_utm = geom_wgs.projectAs(sr_utm20s)
            poly_buf = geom_utm.buffer(15.0)  # Buffer circular referencial de 15 m
            calc_area = round(poly_buf.area, 2)

            row_values = [
                poly_buf,
                reg["id_postg"],
                reg["cod_fac"],
                reg["nom_unidad"],
                u"Referencial",
                calc_area
            ]
            cursor.insertRow(row_values)

    ensure_cpg_and_prj(out_dir, shp_poly_name)
    count_poly = arcpy.GetCount_management(shp_poly_name)[0]
    print "Capa de poligonos creada con exito: %s (%s registros)" % (shp_poly_name, count_poly)

    # =========================================================================
    # 3. CREACION DE NODOS DE ACCESO / RUTEO: postgrados_nodos_acceso.shp
    # =========================================================================
    shp_nodos_name = "postgrados_nodos_acceso.shp"
    shp_nodos_path = os.path.join(out_dir, shp_nodos_name)
    if arcpy.Exists(shp_nodos_name):
        arcpy.Delete_management(shp_nodos_name)

    arcpy.CreateFeatureclass_management(out_dir, shp_nodos_name, "POINT", spatial_reference=sr_utm20s)
    ensure_cpg_and_prj(out_dir, shp_nodos_name)

    for item in FIELDS_NODOS:
        fn, ftype, flen = item[0], item[1], item[2]
        if ftype == "TEXT":
            arcpy.AddField_management(shp_nodos_name, fn, ftype, field_length=flen)
        else:
            arcpy.AddField_management(shp_nodos_name, fn, ftype)

    field_names_nodos = ["SHAPE@"] + [f[0] for f in FIELDS_NODOS]

    with arcpy.da.InsertCursor(shp_nodos_name, field_names_nodos) as cursor:
        for reg in DATASET_POSTGRADOS:
            pt_wgs = arcpy.Point(reg["lon_wgs84"], reg["lat_wgs84"])
            geom_wgs = arcpy.PointGeometry(pt_wgs, sr_wgs84)
            geom_utm = geom_wgs.projectAs(sr_utm20s)
            cod_qr = u"UAGRM-PG-" + reg["cod_fac"]

            row_values = [
                geom_utm,
                reg["id_postg"],
                reg["cod_fac"],
                reg["nom_unidad"],
                u"Acceso_Vial",
                reg["lat_wgs84"],
                reg["lon_wgs84"],
                0.0,
                cod_qr
            ]
            cursor.insertRow(row_values)

    ensure_cpg_and_prj(out_dir, shp_nodos_name)
    count_nodos = arcpy.GetCount_management(shp_nodos_name)[0]
    print "Capa de nodos de acceso creada con exito: %s (%s registros)" % (shp_nodos_name, count_nodos)

    # =========================================================================
    # 4. EXPORTACION A FILE GEODATABASE Y ALIAS: postgrados_uagrm.gdb
    # =========================================================================
    gdb_name = "postgrados_uagrm.gdb"
    gdb_path = os.path.join(out_dir, gdb_name)
    if not arcpy.Exists(gdb_path):
        arcpy.CreateFileGDB_management(out_dir, gdb_name)
        print "File Geodatabase creada: %s" % gdb_name

    gdb_pts = os.path.join(gdb_path, "postgrados_uagrm_pts")
    gdb_poly = os.path.join(gdb_path, "postgrados_uagrm_poly")
    gdb_nodos = os.path.join(gdb_path, "postgrados_nodos_acceso")

    if arcpy.Exists(gdb_pts): arcpy.Delete_management(gdb_pts)
    if arcpy.Exists(gdb_poly): arcpy.Delete_management(gdb_poly)
    if arcpy.Exists(gdb_nodos): arcpy.Delete_management(gdb_nodos)

    arcpy.CopyFeatures_management(shp_pts_name, gdb_pts)
    arcpy.CopyFeatures_management(shp_poly_name, gdb_poly)
    arcpy.CopyFeatures_management(shp_nodos_name, gdb_nodos)

    print "Asignando Field Aliases legibles en la File Geodatabase..."
    apply_aliases_gdb(gdb_pts, FIELDS_PUNTOS)
    apply_aliases_gdb(gdb_poly, FIELDS_POLYGONS)
    apply_aliases_gdb(gdb_nodos, FIELDS_NODOS)
    print "Feature Classes y Field Aliases configurados en postgrados_uagrm.gdb con exito."

    # =========================================================================
    # 5. GENERACION DE CSV RESPALDO (UTF-8 con BOM)
    # =========================================================================
    csv_path = os.path.join(out_dir, "postgrados_uagrm.csv")
    csv_header = [
        "id_postg", "cod_fac", "nom_unidad", "nom_facult", "tipo_ent", "ambito",
        "municipio", "campus", "modulo_pab", "direccion", "lat_wgs84", "lon_wgs84",
        "utm_x_20s", "utm_y_20s", "lat_ruta", "lon_ruta", "dist_via_m", "telefono",
        "correo", "horario", "estado_geo", "cod_qr", "programas", "sitio_web",
        "url_foto", "area_m2"
    ]

    with codecs.open(csv_path, "w", encoding="utf-8-sig") as f:
        f.write(u",".join(csv_header) + u"\r\n")
        for reg in DATASET_POSTGRADOS:
            pt_wgs = arcpy.Point(reg["lon_wgs84"], reg["lat_wgs84"])
            geom_wgs = arcpy.PointGeometry(pt_wgs, sr_wgs84)
            geom_utm = geom_wgs.projectAs(sr_utm20s)
            ux = round(geom_utm.firstPoint.X, 3)
            uy = round(geom_utm.firstPoint.Y, 3)
            cod_qr = u"UAGRM-PG-" + reg["cod_fac"]

            def clean_val(v):
                if isinstance(v, (int, float)):
                    return unicode(v)
                s = unicode(v)
                if u"," in s or u'"' in s or u"\n" in s:
                    s = u'"' + s.replace(u'"', u'""') + u'"'
                return s

            row = [
                reg["id_postg"],
                reg["cod_fac"],
                reg["nom_unidad"],
                reg["nom_facult"],
                reg["tipo_ent"],
                reg["ambito"],
                reg["municipio"],
                reg["campus"],
                reg["modulo_pab"],
                reg["direccion"],
                reg["lat_wgs84"],
                reg["lon_wgs84"],
                ux,
                uy,
                reg["lat_wgs84"],
                reg["lon_wgs84"],
                0.0,
                reg["telefono"],
                reg["correo"],
                reg["horario"],
                reg["estado_geo"],
                cod_qr,
                reg["programas"],
                reg["sitio_web"],
                reg["url_foto"],
                0.0
            ]
            f.write(u",".join([clean_val(x) for x in row]) + u"\r\n")

    print "Archivo CSV generado: %s" % csv_path

    # =========================================================================
    # 6. GENERACION DE GEOJSON (WGS 84 / EPSG:4326) PARA WEBGIS
    # =========================================================================
    geojson_path = os.path.join(out_dir, "postgrados_uagrm_web.geojson")
    features = []
    for reg in DATASET_POSTGRADOS:
        pt_wgs = arcpy.Point(reg["lon_wgs84"], reg["lat_wgs84"])
        geom_wgs = arcpy.PointGeometry(pt_wgs, sr_wgs84)
        geom_utm = geom_wgs.projectAs(sr_utm20s)
        ux = round(geom_utm.firstPoint.X, 3)
        uy = round(geom_utm.firstPoint.Y, 3)
        cod_qr = u"UAGRM-PG-" + reg["cod_fac"]

        props = {
            "id_postg": reg["id_postg"],
            "cod_fac": reg["cod_fac"],
            "nom_unidad": reg["nom_unidad"],
            "nom_facult": reg["nom_facult"],
            "tipo_ent": reg["tipo_ent"],
            "ambito": reg["ambito"],
            "municipio": reg["municipio"],
            "campus": reg["campus"],
            "modulo_pab": reg["modulo_pab"],
            "direccion": reg["direccion"],
            "lat_wgs84": reg["lat_wgs84"],
            "lon_wgs84": reg["lon_wgs84"],
            "utm_x_20s": ux,
            "utm_y_20s": uy,
            "lat_ruta": reg["lat_wgs84"],
            "lon_ruta": reg["lon_wgs84"],
            "dist_via_m": 0.0,
            "telefono": reg["telefono"],
            "correo": reg["correo"],
            "horario": reg["horario"],
            "estado_geo": reg["estado_geo"],
            "cod_qr": cod_qr,
            "programas": reg["programas"],
            "sitio_web": reg["sitio_web"],
            "url_foto": reg["url_foto"],
            "area_m2": 0.0
        }

        feature = {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [reg["lon_wgs84"], reg["lat_wgs84"]]
            },
            "properties": props
        }
        features.append(feature)

    geojson_doc = {
        "type": "FeatureCollection",
        "name": "postgrados_uagrm_web",
        "crs": {
            "type": "name",
            "properties": {
                "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
            }
        },
        "features": features
    }

    with codecs.open(geojson_path, "w", encoding="utf-8") as f:
        json.dump(geojson_doc, f, ensure_ascii=False, indent=2)

    print "Archivo GeoJSON generado: %s" % geojson_path
    print "\nGeneracion y pulido de capas completados con 100% de exito."

if __name__ == "__main__":
    main()

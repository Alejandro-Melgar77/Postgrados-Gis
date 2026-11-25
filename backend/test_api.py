# -*- coding: utf-8 -*-
"""
================================================================================
SCRIPT DE PRUEBAS: backend/test_api.py
PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
DESCRIPCION: Suite de pruebas de integracion para la API Backend FastAPI
             utilizando fastapi.testclient.TestClient contra la base real de
             Supabase (PostgreSQL 17 + PostGIS).
================================================================================
"""

import sys
import unittest
from pathlib import Path
from fastapi.testclient import TestClient

# Asegurar que el modulo backend este en sys.path
backend_dir = Path(__file__).resolve().parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from main import app

client = TestClient(app)


class TestBackendFastAPIPostGIS(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        print("\n" + "=" * 75)
        print("INICIANDO SUITE DE PRUEBAS: FASTAPI + SUPABASE POSTGIS")
        print("=" * 75)

    def test_01_root(self):
        """Verifica el endpoint raiz GET /"""
        res = client.get("/")
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["status"], "ok")
        self.assertEqual(data["name"], "API SIG Postgrados UAGRM")
        print("  [OK] GET / -> 200 (API Online)")

    def test_02_health_counts(self):
        """Verifica conexion real a Supabase, PostGIS y conteos exactos (19 y 12)."""
        res = client.get("/api/health")
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["status"], "ok")
        self.assertEqual(data["database"], "connected")
        self.assertIn("3.", data["postgis_version"])
        self.assertEqual(data["counts"]["postgrados"], 19)
        self.assertEqual(data["counts"]["servicios"], 12)
        print(f"  [OK] GET /api/health -> 200 | PostGIS: {data['postgis_version'][:15]}... | Postgrados: 19 | Servicios: 12")

    def test_03_listar_postgrados_total_y_utf8(self):
        """Verifica que /api/postgrados devuelva FeatureCollection con 19 features e integridad UTF-8."""
        res = client.get("/api/postgrados")
        self.assertEqual(res.status_code, 200)
        fc = res.json()
        self.assertEqual(fc["type"], "FeatureCollection")
        self.assertEqual(len(fc["features"]), 19)

        # Verificar integridad de caracteres especiales en PG-00 y PG-03
        pg_map = {f["id"]: f for f in fc["features"]}
        self.assertIn("PG-00", pg_map)
        pg00 = pg_map["PG-00"]["properties"]
        self.assertIn("Dirección General de Posgrado", pg00["nom_unidad"])
        self.assertIn("Dirección", pg00["nom_unidad"])

        pg03 = pg_map["PG-03"]["properties"]
        self.assertIn("Auditoría", pg03["programas"])

        # Verificar geometria
        geom00 = pg_map["PG-00"]["geometry"]
        self.assertEqual(geom00["type"], "Point")
        self.assertAlmostEqual(geom00["coordinates"][0], -63.18183, places=4)
        print(f"  [OK] GET /api/postgrados -> 200 | 19 Features GeoJSON | UTF-8 íntegro (tildes confirmadas)")

    def test_04_filtro_ambito_urbano(self):
        """Verifica que el filtro ?ambito=Urbano devuelva exactamente 13 features."""
        res = client.get("/api/postgrados?ambito=Urbano")
        self.assertEqual(res.status_code, 200)
        fc = res.json()
        self.assertEqual(len(fc["features"]), 13)
        for f in fc["features"]:
            self.assertEqual(f["properties"]["ambito"], "Urbano")
        print("  [OK] GET /api/postgrados?ambito=Urbano -> 200 | 13 Features Urbanas")

    def test_05_busqueda_libre_q(self):
        """Verifica que ?q=FICCT retorne la unidad PG-16."""
        res = client.get("/api/postgrados?q=FICCT")
        self.assertEqual(res.status_code, 200)
        fc = res.json()
        ids = [f["id"] for f in fc["features"]]
        self.assertIn("PG-16", ids)
        ficct_feat = [f for f in fc["features"] if f["id"] == "PG-16"][0]
        self.assertEqual(ficct_feat["properties"]["cod_fac"], "FICCT")
        print("  [OK] GET /api/postgrados?q=FICCT -> 200 | Incluye PG-16 (FICCT)")

    def test_06_obtener_por_id(self):
        """Verifica GET /api/postgrados/{id_postg} para PG-16 y para ID inexistente."""
        res = client.get("/api/postgrados/PG-16")
        self.assertEqual(res.status_code, 200)
        feat = res.json()
        self.assertEqual(feat["type"], "Feature")
        self.assertEqual(feat["id"], "PG-16")

        res_404 = client.get("/api/postgrados/PG-999")
        self.assertEqual(res_404.status_code, 404)
        print("  [OK] GET /api/postgrados/PG-16 -> 200 | PG-999 -> 404")

    def test_07_consulta_qr_movil(self):
        """Verifica el Requisito #21: Consulta movil por codigo QR."""
        res = client.get("/api/postgrados/qr/UAGRM-PG-FICCT")
        self.assertEqual(res.status_code, 200)
        feat = res.json()
        self.assertEqual(feat["type"], "Feature")
        self.assertEqual(feat["id"], "PG-16")
        self.assertEqual(feat["properties"]["cod_qr"], "UAGRM-PG-FICCT")

        # Prueba con QR inexistente -> 404
        res_fail = client.get("/api/postgrados/qr/INEXISTENTE")
        self.assertEqual(res_fail.status_code, 404)
        print("  [OK] GET /api/postgrados/qr/UAGRM-PG-FICCT -> 200 (PG-16) | /qr/INEXISTENTE -> 404")

    def test_08_listar_servicios(self):
        """Verifica GET /api/servicios y filtro por tipo."""
        res = client.get("/api/servicios")
        self.assertEqual(res.status_code, 200)
        fc = res.json()
        self.assertEqual(len(fc["features"]), 12)

        res_med = client.get("/api/servicios?tipo=Centro_Medico")
        self.assertEqual(res_med.status_code, 200)
        fc_med = res_med.json()
        self.assertEqual(len(fc_med["features"]), 3)
        for f in fc_med["features"]:
            self.assertEqual(f["properties"]["tipo"], "Centro_Medico")
        print("  [OK] GET /api/servicios -> 200 (12 servicios) | tipo=Centro_Medico -> 200 (3)")

    def test_09_servicios_cercanos_espacial(self):
        """Verifica el Requisito #22: ST_DWithin y ST_Distance a 600m de la FICCT."""
        # Coordenadas exactas de PG-16 (FICCT): lat -17.77631, lon -63.19506
        res = client.get("/api/servicios/cercanos?lat=-17.77631&lon=-63.19506&radio_m=600")
        self.assertEqual(res.status_code, 200)
        fc = res.json()
        self.assertEqual(fc["type"], "FeatureCollection")
        self.assertGreater(len(fc["features"]), 0)
        self.assertEqual(len(fc["features"]), 11)

        # Comprobar que estan ordenados por distancia ascendente
        distancias = [f["properties"]["distancia_m"] for f in fc["features"]]
        self.assertEqual(distancias, sorted(distancias))

        # El mas cercano debe ser SERV-07 a ~8.83 metros
        primer_serv = fc["features"][0]
        self.assertEqual(primer_serv["id"], "SERV-07")
        self.assertAlmostEqual(primer_serv["properties"]["distancia_m"], 8.83, delta=0.5)
        print(f"  [OK] GET /api/servicios/cercanos -> 200 | 11 servicios a <=600m | Mas cercano: {primer_serv['id']} ({primer_serv['properties']['distancia_m']}m)")

    def test_10_resumen_estadisticas(self):
        """Verifica GET /api/resumen para tarjetas y contadores."""
        res = client.get("/api/resumen")
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertIn("postgrados", data)
        self.assertIn("servicios", data)

        postg = data["postgrados"]
        self.assertEqual(postg["total"], 19)
        self.assertEqual(postg["urbanos"], 13)
        self.assertEqual(postg["provinciales"], 6)
        self.assertEqual(postg["verificados"], 12)
        self.assertEqual(postg["revisar_campo"], 7)

        serv = data["servicios"]
        self.assertEqual(serv["total"], 12)
        self.assertEqual(serv["por_tipo"]["Centro_Medico"], 3)
        self.assertEqual(serv["por_tipo"]["Extintor"], 4)
        self.assertEqual(serv["por_tipo"]["Acceso_Campus"], 3)
        self.assertEqual(serv["por_tipo"]["Punto_Encuentro"], 2)
        print("  [OK] GET /api/resumen -> 200 | Contadores validados con éxito")


if __name__ == "__main__":
    unittest.main(verbosity=2)

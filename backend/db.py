# -*- coding: utf-8 -*-
"""
================================================================================
MODULO: backend/db.py
PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
DESCRIPCION: Capa de persistencia espacial y conexion a PostgreSQL + PostGIS
             en Supabase usando el driver nativo psycopg v3 con dict_row.
================================================================================
"""

import os
from contextlib import contextmanager
from pathlib import Path
from typing import Generator, List, Dict, Any, Optional
from dotenv import load_dotenv
import psycopg
from psycopg.rows import dict_row

# Carga de variables de entorno: busca primero en backend/.env, luego en la raiz ../.env
backend_dir = Path(__file__).resolve().parent
project_root = backend_dir.parent

if (backend_dir / ".env").exists():
    load_dotenv(backend_dir / ".env")
elif (project_root / ".env").exists():
    load_dotenv(project_root / ".env")
else:
    load_dotenv()


def get_database_url() -> str:
    """
    Obtiene la URL de conexion a Supabase asegurando el parametro sslmode=require.
    Lanza RuntimeError si DATABASE_URL no esta definida.
    """
    url = os.getenv("DATABASE_URL", "").strip()
    if not url:
        raise RuntimeError(
            "ERROR: La variable de entorno DATABASE_URL no esta configurada. "
            "Verifica el archivo .env o la configuracion en el panel de Render."
        )

    # Garantizar sslmode=require para conexiones cifradas a Supabase
    if "sslmode=" not in url:
        sep = "&" if "?" in url else "?"
        url = f"{url}{sep}sslmode=require"

    return url


@contextmanager
def get_db_cursor() -> Generator[psycopg.Cursor, None, None]:
    """
    Context manager seguro para obtener un cursor con soporte para dict_row.
    Garantiza el cierre de la conexion y la liberacion de recursos en cada peticion.
    """
    db_url = get_database_url()
    conn = psycopg.connect(db_url, row_factory=dict_row)
    try:
        with conn.cursor() as cur:
            yield cur
    finally:
        conn.close()


def query_all(query: str, params: tuple = ()) -> List[Dict[str, Any]]:
    """Ejecuta una consulta SQL y retorna todas las filas como lista de diccionarios."""
    with get_db_cursor() as cur:
        cur.execute(query, params)
        return cur.fetchall()


def query_one(query: str, params: tuple = ()) -> Optional[Dict[str, Any]]:
    """Ejecuta una consulta SQL y retorna una unica fila o None."""
    with get_db_cursor() as cur:
        cur.execute(query, params)
        return cur.fetchone()

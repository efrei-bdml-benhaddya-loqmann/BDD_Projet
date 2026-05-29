"""Connexion MySQL — helpers légers au-dessus de mysql-connector-python.

Pas d'ORM (choix assumé dans le sujet) : on écrit du SQL brut et on
récupère des dictionnaires Python prêts pour les templates Jinja2.
"""
import os

import mysql.connector
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "planning_entreprise"),
}


def get_connection():
    """Ouvre une connexion MySQL. À fermer par l'appelant (with closing)."""
    return mysql.connector.connect(**DB_CONFIG)


def query(sql, params=None, *, one=False):
    """Exécute un SELECT et renvoie une liste de dicts (ou un seul dict si one=True)."""
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        rows = cur.fetchall()
        cur.close()
        return (rows[0] if rows else None) if one else rows
    finally:
        conn.close()


def execute(sql, params=None):
    """Exécute un INSERT/UPDATE/DELETE, valide, et renvoie lastrowid + rowcount."""
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(sql, params or ())
        conn.commit()
        result = {"lastrowid": cur.lastrowid, "rowcount": cur.rowcount}
        cur.close()
        return result
    finally:
        conn.close()

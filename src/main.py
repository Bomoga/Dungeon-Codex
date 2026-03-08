import psycopg

DSN = "dbname=dungeon_codex_v1 user=postgres password=postgres host=localhost"

def get_conn():
    return psycopg.connect(DSN)

def list_spells():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("""
            SELECT spell_id, name, level
            FROM spell
            ORDER BY level, name;
        """)
        rows = cur.fetchall()
    print("\nSpells:")
    for spell_id, name, level in rows:
        print(f"[{spell_id}] (lvl {level}) {name}")

def list_items():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("""
            SELECT item_id, name, item_type
            FROM item
            ORDER BY rarity, name;
        """)
        rows = cur.fetchall()
    print("\nItems:")
    for item_id, name, rarity in rows:
        print(f"[{item_id}] ({rarity}) {name}")

def create_spell():
    name = input("Spell name: ").strip()
    level = int(input("Level (0-9): ").strip() or "0")
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(
            "INSERT INTO spell (name, level) VALUES (%s, %s) RETURNING spell_id;",
            (name, level),
        )
        new_id = cur.fetchone()[0]
        conn.commit()
    print(f"Created spell with id={new_id}")

def list_monsters_by_env():
    env_name = input("Environment name (e.g. Forgotten Forest): ").strip()
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("""
            SELECT m.monster_id, m.name, m.challenge_rating
            FROM monster m
            JOIN monster_environment me ON me.monster_id = m.monster_id
            JOIN environment e ON e.environment_id = me.environment_id
            WHERE e.name = %s
            ORDER BY m.challenge_rating;
        """, (env_name,))
        rows = cur.fetchall()
    print(f"\nMonsters in environment '{env_name}':")
    for mid, name, cr in rows:
        print(f"[{mid}] CR {cr}: {name}")

def main_menu():
    while True:
        print("\n--- Dungeon Codex ---")
        print("1) List spells")
        print("2) List items")
        print("3) Create a new spell")
        print("4) List monsters by environment")
        print("0) Exit")
        choice = input("Select option: ").strip()
        if choice == "1":
            list_spells()
        elif choice == "2":
            list_items()
        elif choice == "3":
            create_spell()
        elif choice == "4":
            list_monsters_by_env()
        elif choice == "0":
            break
        else:
            print("Invalid choice")

if __name__ == "__main__":
    main_menu()
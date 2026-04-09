import psycopg

DSN = "dbname=dungeon_codex_v1 user=postgres password=postgres host=localhost"


def get_conn():
    return psycopg.connect(DSN)


def list_spells():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("""
            SELECT spell_id, name, level, casting_time, range,
                   duration, concentration, ritual, spell_save, description
            FROM spell ORDER BY level, name;
        """)
        return cur.fetchall()


def list_items(rarity_filter=None):
    with get_conn() as conn, conn.cursor() as cur:
        if rarity_filter:
            cur.execute("""
                SELECT item_id, name, item_type, rarity, description,
                       activation_type, duration, damage_or_healing,
                       damage_type, weight, value_gp, environment_id
                FROM item WHERE rarity = %s ORDER BY name;
            """, (rarity_filter,))
        else:
            cur.execute("""
                SELECT item_id, name, item_type, rarity, description,
                       activation_type, duration, damage_or_healing,
                       damage_type, weight, value_gp, environment_id
                FROM item ORDER BY rarity, name;
            """)
        return cur.fetchall()


def create_spell(name, level):
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(
            "INSERT INTO spell (name, level) VALUES (%s, %s) RETURNING spell_id;",
            (name, int(level)),
        )
        new_id = cur.fetchone()[0]
        conn.commit()
    return new_id


def list_monsters_by_env(env_name):
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("""
            SELECT m.monster_id, m.name, m.challenge_rating
            FROM monster m
            JOIN monster_environment me ON me.monster_id = m.monster_id
            JOIN environment e ON e.environment_id = me.environment_id
            WHERE e.name = %s
            ORDER BY m.challenge_rating;
        """, (env_name,))
        return cur.fetchall()


def list_environments():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("""
            SELECT environment_id, name, terrain_type,
                   danger_level, climate, magic_level
            FROM environment ORDER BY name;
        """)
        return cur.fetchall()


def get_monster_roster():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("""
            SELECT monster_id, name, challenge_rating,
                   hit_points, armor_class, size, type_name, environments
            FROM v_monster_roster ORDER BY challenge_rating, name;
        """)
        return cur.fetchall()


def main_menu():
    while True:
        print("\n--- Dungeon Codex ---")
        print("1) List spells")
        print("2) List items")
        print("3) Create a new spell")
        print("4) List monsters by environment")
        print("5) List all environments")
        print("6) Show monster roster")
        print("0) Exit")
        choice = input("Select option: ").strip()

        if choice == "1":
            for row in list_spells():
                print(f"  [{row[0]}] (lvl {row[2]}) {row[1]}")
        elif choice == "2":
            for row in list_items():
                print(f"  [{row[0]}] ({row[3]}) {row[2]}: {row[1]}")
        elif choice == "3":
            name = input("Spell name: ").strip()
            level = int(input("Level (0-9): ").strip() or "0")
            print(f"Created spell id={create_spell(name, level)}")
        elif choice == "4":
            env = input("Environment name: ").strip()
            rows = list_monsters_by_env(env)
            for mid, name, cr in rows:
                print(f"  [{mid}] CR {cr}: {name}")
            if not rows:
                print("  (none found)")
        elif choice == "5":
            for e in list_environments():
                print(f"  [{e[0]}] {e[1]} | {e[2]} | Danger:{e[3]} | {e[4]} | Magic:{e[5]}")
        elif choice == "6":
            for row in get_monster_roster():
                print(f"  [{row[0]}] CR{row[2]} {row[1]} ({row[5]} {row[6]}) — {row[7] or 'none'}")
        elif choice == "0":
            break
        else:
            print("Invalid choice")


if __name__ == "__main__":
    main_menu()

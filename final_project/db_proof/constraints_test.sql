-- Dungeon Codex – Constraint Tests (dungeon_codex_v1)
-- Each block is wrapped in BEGIN...ROLLBACK so live data is never affected.
-- Run each block individually in pgAdmin.

-- TEST 1: NOT NULL violation
-- Actual error:
--   ERROR:  null value in column "name" of relation "spell" violates not-null constraint
--   DETAIL:  Failing row contains (9, null, 1, 1, 0, 0, f, f, null, null).
--   SQL state: 23502
BEGIN;
INSERT INTO spell (name, level) VALUES (NULL, 1);
ROLLBACK;


-- TEST 2: CHECK constraint violation (level out of 0–9 range)
-- Actual error:
--   ERROR:  new row for relation "spell" violates check constraint "spell_level_check"
--   DETAIL:  Failing row contains (10, Overpowered Blast, 15, 1, 0, 0, f, f, null, null).
--   SQL state: 23514
BEGIN;
INSERT INTO spell (name, level) VALUES ('Overpowered Blast', 15);
ROLLBACK;


-- TEST 3: Foreign key violation (environment_id does not exist)
-- Actual error:
--   ERROR:  insert or update on table "item" violates foreign key constraint "item_environment_id_fkey"
--   DETAIL:  Key (environment_id)=(999) is not present in table "environment".
--   SQL state: 23503
BEGIN;
INSERT INTO item (name, item_type, rarity, environment_id)
VALUES ('Ghost Dagger', 'Weapon', 'Rare', 999);
ROLLBACK;


-- TEST 4: UNIQUE constraint violation (duplicate spell name)
-- Actual error:
--   ERROR:  duplicate key value violates unique constraint "spell_name_key"
--   DETAIL:  Key (name)=(Fire Bolt) already exists.
--   SQL state: 23505
BEGIN;
INSERT INTO spell (name, level) VALUES ('Fire Bolt', 0);
ROLLBACK;

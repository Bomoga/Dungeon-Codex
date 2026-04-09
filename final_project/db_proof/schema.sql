-- Dungeon Codex – Schema (dungeon_codex_v1)

-- Drop in reverse dependency order
DROP TABLE IF EXISTS spell_audit_log      CASCADE;
DROP TABLE IF EXISTS monster_environment  CASCADE;
DROP TABLE IF EXISTS item                 CASCADE;
DROP TABLE IF EXISTS monster              CASCADE;
DROP TABLE IF EXISTS spell                CASCADE;
DROP TABLE IF EXISTS environment          CASCADE;
DROP TABLE IF EXISTS monster_type         CASCADE;
DROP VIEW     IF EXISTS v_monster_roster;
DROP FUNCTION IF EXISTS fn_spell_audit();


CREATE TABLE monster_type (
    type_id  SERIAL      PRIMARY KEY,
    name     VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE environment (
    environment_id  SERIAL        PRIMARY KEY,
    name            VARCHAR(100)  NOT NULL UNIQUE,
    terrain_type    VARCHAR(50)   NOT NULL,
    danger_level    SMALLINT      NOT NULL CHECK (danger_level BETWEEN 1 AND 10),
    climate         VARCHAR(50),
    magic_level     SMALLINT      CHECK (magic_level BETWEEN 0 AND 10)
);

CREATE TABLE spell (
    spell_id      SERIAL        PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL UNIQUE,
    level         SMALLINT      NOT NULL DEFAULT 0 CHECK (level BETWEEN 0 AND 9),
    casting_time  SMALLINT      NOT NULL DEFAULT 1 CHECK (casting_time > 0),
    range         SMALLINT      NOT NULL DEFAULT 0,
    duration      SMALLINT      NOT NULL DEFAULT 0,
    concentration BOOLEAN       NOT NULL DEFAULT FALSE,
    ritual        BOOLEAN       NOT NULL DEFAULT FALSE,
    spell_save    CHAR(3)       CHECK (spell_save IN ('STR','DEX','CON','INT','WIS','CHA')),
    description   TEXT
);

CREATE TABLE item (
    item_id           SERIAL        PRIMARY KEY,
    name              VARCHAR(100)  NOT NULL UNIQUE,
    item_type         VARCHAR(50)   NOT NULL
                      CHECK (item_type IN ('Weapon','Armor','Wondrous','Potion','Ring','Staff','Wand')),
    rarity            VARCHAR(20)   NOT NULL
                      CHECK (rarity IN ('Common','Uncommon','Rare','Very Rare','Legendary')),
    description       TEXT,
    activation_type   VARCHAR(20)   CHECK (activation_type IN ('Action','Bonus','Reaction','None','Attunement')),
    duration          SMALLINT      DEFAULT 0,
    damage_or_healing VARCHAR(10),
    damage_type       VARCHAR(20),
    weight            NUMERIC(6,2)  CHECK (weight >= 0),
    value_gp          NUMERIC(10,2) CHECK (value_gp >= 0),
    environment_id    INT           REFERENCES environment(environment_id) ON DELETE SET NULL
);

CREATE TABLE monster (
    monster_id       SERIAL        PRIMARY KEY,
    name             VARCHAR(100)  NOT NULL UNIQUE,
    challenge_rating NUMERIC(4,1)  NOT NULL CHECK (challenge_rating >= 0),
    hit_points       SMALLINT      NOT NULL CHECK (hit_points > 0),
    armor_class      SMALLINT      NOT NULL CHECK (armor_class >= 1),
    size             VARCHAR(15)   NOT NULL
                     CHECK (size IN ('Tiny','Small','Medium','Large','Huge','Gargantuan')),
    type_id          INT           NOT NULL REFERENCES monster_type(type_id)
);

CREATE TABLE monster_environment (
    monster_id     INT NOT NULL REFERENCES monster(monster_id)     ON DELETE CASCADE,
    environment_id INT NOT NULL REFERENCES environment(environment_id) ON DELETE CASCADE,
    PRIMARY KEY (monster_id, environment_id)
);


-- Advanced Feature 1: View
CREATE OR REPLACE VIEW v_monster_roster AS
SELECT m.monster_id, m.name, m.challenge_rating, m.hit_points,
       m.armor_class, m.size, mt.name AS type_name,
       STRING_AGG(e.name, ', ' ORDER BY e.name) AS environments
FROM monster m
JOIN monster_type mt ON mt.type_id = m.type_id
LEFT JOIN monster_environment me ON me.monster_id = m.monster_id
LEFT JOIN environment e ON e.environment_id = me.environment_id
GROUP BY m.monster_id, m.name, m.challenge_rating,
         m.hit_points, m.armor_class, m.size, mt.name;


-- Advanced Feature 2: Trigger — logs every INSERT/UPDATE on spell
CREATE TABLE spell_audit_log (
    log_id     SERIAL      PRIMARY KEY,
    action     VARCHAR(10) NOT NULL,
    spell_id   INT         NOT NULL,
    spell_name VARCHAR(100),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    changed_by TEXT        NOT NULL DEFAULT CURRENT_USER
);

CREATE OR REPLACE FUNCTION fn_spell_audit()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO spell_audit_log (action, spell_id, spell_name)
    VALUES (TG_OP, NEW.spell_id, NEW.name);
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_spell_audit
AFTER INSERT OR UPDATE ON spell
FOR EACH ROW EXECUTE FUNCTION fn_spell_audit();

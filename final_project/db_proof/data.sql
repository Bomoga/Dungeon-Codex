-- Dungeon Codex – Sample Data (dungeon_codex_v1)
-- Run after schema.sql. Insert order respects FK dependencies.
-- NULL values: spell.spell_save is NULL for spells with no saving throw.
--              item.environment_id is NULL for generic items (Healing Potion).
-- Boundary values: level 0 (min) and 9 (max), danger_level 1 (min) and 10 (max), CR 0.25.

INSERT INTO monster_type (type_id, name) VALUES
(1, 'Beast'),
(2, 'Undead'),
(3, 'Dragon'),
(4, 'Plant');

INSERT INTO environment (environment_id, name, terrain_type, danger_level, climate, magic_level) VALUES
(1, 'Forgotten Forest', 'Forest',     7,  'Temperate', 3),
(2, 'Sunken Ruins',     'Underwater', 8,  'Cold',      5),
(3, 'Ashfield Plains',  'Grassland',  4,  'Arid',      1),
(4, 'Crimson Caverns',  'Cave',       9,  'Hot',       4),
(5, 'Merchant Road',    'Road',       1,  'Temperate', 0),  -- danger_level min boundary
(6, 'Void Rift',        'Planar',     10, NULL,        10); -- danger_level max boundary, NULL climate

INSERT INTO spell (spell_id, name, level, casting_time, range, duration, concentration, ritual, spell_save, description) VALUES
(1, 'Fire Bolt',    0, 1, 120,  0, FALSE, FALSE, NULL,  'Hurl a mote of fire at a creature or object.'),  -- level 0 (min)
(2, 'Cure Wounds',  1, 1,   0,  0, FALSE, FALSE, NULL,  'Restore hit points to a creature you touch.'),
(3, 'Misty Step',   2, 1,   0,  0, FALSE, FALSE, NULL,  'Teleport up to 30 feet to an unoccupied space.'),
(4, 'Fireball',     3, 1, 150,  0, FALSE, FALSE, 'DEX', 'A bright streak explodes in a 20-foot-radius sphere.'),
(5, 'Hold Monster', 5, 1,  90, 60, TRUE,  FALSE, 'WIS', 'Paralyze a creature you can see within range.'),
(6, 'Detect Magic', 1, 1,   0, 10, TRUE,  TRUE,  NULL,  'Sense the presence of magic within 30 feet.'),
(7, 'Wish',         9, 1,   0,  0, FALSE, FALSE, NULL,  'Reshape reality itself.');  -- level 9 (max)

INSERT INTO item (item_id, name, item_type, rarity, description, activation_type, duration, damage_or_healing, damage_type, weight, value_gp, environment_id) VALUES
(1, 'Thornwood Staff', 'Weapon',   'Uncommon', 'A gnarled staff carved from a cursed oak.',  'Action', 0,  '1d6', 'Piercing', 4.0,   250, 1),
(2, 'Tidal Amulet',    'Wondrous', 'Rare',     'Grants water breathing for 1 hour per day.', 'Bonus',  60, NULL,  NULL,       0.1,   800, 2),
(3, 'Ember Cloak',     'Armor',    'Rare',     'Resistance to fire damage.',                 'None',   0,  NULL,  NULL,       2.0,  1200, 4),
(4, 'Ashstep Boots',   'Wondrous', 'Uncommon', 'Leave no tracks on natural terrain.',        'None',   0,  NULL,  NULL,       1.0,   400, 3),
(5, 'Spore Bomb',      'Weapon',   'Common',   'Explodes in a cloud of poisonous spores.',   'Action', 0,  '2d4', 'Poison',   0.5,    50, 1),
(6, 'Healing Potion',  'Potion',   'Common',   'Restores 2d4+2 hit points when consumed.',  'Action', 0,  '2d4', NULL,       0.5,    50, NULL); -- NULL environment_id

INSERT INTO monster (monster_id, name, challenge_rating, hit_points, armor_class, size, type_id) VALUES
(1, 'Shadow Wolf',     1.0,   22,  13, 'Medium', 1),
(2, 'Cave Troll',      5.0,   95,  15, 'Large',  1),
(3, 'Sea Wraith',      6.0,  110,  13, 'Medium', 2),
(4, 'Ember Drake',     8.0,  136,  17, 'Large',  3),
(5, 'Fungal Shambler', 2.0,   45,  12, 'Medium', 4),
(6, 'Cave Sprite',     0.25,   7,  12, 'Tiny',   1); -- CR 0.25 (boundary low)

INSERT INTO monster_environment (monster_id, environment_id) VALUES
(1, 1),  -- Shadow Wolf      → Forgotten Forest
(2, 4),  -- Cave Troll       → Crimson Caverns
(3, 2),  -- Sea Wraith       → Sunken Ruins
(4, 4),  -- Ember Drake      → Crimson Caverns
(4, 3),  -- Ember Drake      → Ashfield Plains
(5, 1),  -- Fungal Shambler  → Forgotten Forest
(5, 4),  -- Fungal Shambler  → Crimson Caverns
(6, 4),  -- Cave Sprite      → Crimson Caverns
(6, 5);  -- Cave Sprite      → Merchant Road

-- Sync sequences after explicit-ID inserts
SELECT setval('monster_type_type_id_seq',        (SELECT MAX(type_id)        FROM monster_type));
SELECT setval('environment_environment_id_seq',   (SELECT MAX(environment_id) FROM environment));
SELECT setval('spell_spell_id_seq',               (SELECT MAX(spell_id)       FROM spell));
SELECT setval('item_item_id_seq',                 (SELECT MAX(item_id)        FROM item));
SELECT setval('monster_monster_id_seq',           (SELECT MAX(monster_id)     FROM monster));

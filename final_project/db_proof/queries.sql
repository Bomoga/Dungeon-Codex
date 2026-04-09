-- Dungeon Codex – Queries (dungeon_codex_v1)

-- Q1: All spells by level
SELECT spell_id, name, level, concentration, ritual, spell_save
FROM spell
ORDER BY level, name;

-- Q2: All items by rarity
SELECT item_id, name, item_type, rarity, value_gp
FROM item
ORDER BY rarity, name;

-- Q3: Monsters in a specific environment (3-table JOIN)
SELECT m.monster_id, m.name, m.challenge_rating, m.size
FROM monster m
JOIN monster_environment me ON me.monster_id = m.monster_id
JOIN environment e ON e.environment_id = me.environment_id
WHERE e.name = 'Forgotten Forest'
ORDER BY m.challenge_rating;

-- Q4: Monster count per environment (GROUP BY + COUNT)
SELECT e.name AS environment, e.danger_level,
       COUNT(me.monster_id) AS monster_count
FROM environment e
LEFT JOIN monster_environment me ON me.environment_id = e.environment_id
GROUP BY e.environment_id, e.name, e.danger_level
ORDER BY monster_count DESC, e.name;

-- Q5: Items with their environment name (LEFT JOIN)
SELECT i.name AS item, i.item_type, i.rarity,
       COALESCE(e.name, 'N/A') AS found_in, i.value_gp
FROM item i
LEFT JOIN environment e ON e.environment_id = i.environment_id
ORDER BY i.rarity, i.name;

-- Q6: Concentration spells (WHERE filter)
SELECT name, level, duration, spell_save
FROM spell
WHERE concentration = TRUE
ORDER BY level, name;

-- Q7: Average CR by monster size (GROUP BY + AVG)
SELECT size,
       ROUND(AVG(challenge_rating)::NUMERIC, 2) AS avg_cr,
       COUNT(*) AS monster_count
FROM monster
GROUP BY size
ORDER BY avg_cr DESC;

-- Q8: Full monster roster from view
SELECT monster_id, name, challenge_rating, size, type_name,
       COALESCE(environments, 'None') AS environments
FROM v_monster_roster
ORDER BY challenge_rating, name;

-- Q9: Spells with window function (count per level + overall rank)
SELECT name, level,
       COUNT(*) OVER (PARTITION BY level) AS spells_at_this_level,
       ROW_NUMBER() OVER (ORDER BY level, name) AS overall_rank
FROM spell
ORDER BY level, name;

-- Q10: Monsters in high-danger environments (danger_level >= 7)
SELECT e.name AS environment, e.danger_level, e.terrain_type,
       m.name AS monster, m.challenge_rating
FROM environment e
JOIN monster_environment me ON me.environment_id = e.environment_id
JOIN monster m ON m.monster_id = me.monster_id
WHERE e.danger_level >= 7
ORDER BY e.danger_level DESC, m.challenge_rating DESC;

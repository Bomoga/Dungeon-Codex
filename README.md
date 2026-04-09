# Dungeon Codex

A D&D-themed relational database application for managing spells, magic items, monsters, and the environments they inhabit.

## Overview

Dungeon Codex is built on PostgreSQL and exposes data through two interfaces:

- **Web app** (Flask) — browse and filter all content, add new spells via a form
- **CLI** — interactive terminal menu for quick lookups and data entry

The database models a fantasy RPG reference system with six normalized tables, a denormalized view, and an audit trigger.

---

## Database Schema

| Table | Description |
|---|---|
| `monster_type` | Lookup table for creature types (Beast, Undead, Dragon, etc.) |
| `environment` | Named locations with terrain type, danger level, climate, and magic level |
| `spell` | Spells with level, casting time, range, duration, concentration, ritual, save, and description |
| `item` | Magic items with type, rarity, activation, damage/healing, weight, and value |
| `monster` | Creatures with challenge rating, HP, AC, size, and type |
| `monster_environment` | Junction table linking monsters to the environments they inhabit (many-to-many) |

### Advanced Features

**View — `v_monster_roster`**
A read-only view that joins `monster`, `monster_type`, and `environment` to produce a single denormalized row per monster, including a `STRING_AGG`-aggregated list of all environments the monster appears in. Used by the web dashboard and Query 8.

**Trigger — `trg_spell_audit`**
An `AFTER INSERT OR UPDATE` trigger on the `spell` table. On every change it appends a row to `spell_audit_log`, recording the operation type (`INSERT`/`UPDATE`), the affected `spell_id`, the spell name, the timestamp, and the PostgreSQL role that performed the action.

---

## Setup Instructions

### Prerequisites

- PostgreSQL 14 or later
- Python 3.10 or later
- pip

### 1. Create the database

```bash
createdb -U postgres dungeon_codex_v1
```

### 2. Load the schema

```bash
psql -U postgres -d dungeon_codex_v1 -f final_project/db_proof/schema.sql
```

### 3. Load the sample data

```bash
psql -U postgres -d dungeon_codex_v1 -f final_project/db_proof/data.sql
```

### 4. Install Python dependencies

**Backend (CLI only):**
```bash
pip install -r final_project/backend/requirements.txt
```

**Frontend (web app):**
```bash
pip install -r final_project/frontend/requirements.txt
```

### 5. Run the CLI

```bash
python final_project/backend/main.py
```

### 6. Run the web app

```bash
cd final_project/frontend
flask run
```

Then open `http://localhost:5000` in a browser.

---

## Web App Routes

| Route | Description |
|---|---|
| `/` | Dashboard — environment cards + full monster roster |
| `/spells` | Browse all spells; add a new spell via the form |
| `/items` | Browse items; filter by rarity |
| `/monsters` | Search monsters by environment |
| `/environments` | Browse all environments with color-coded danger ratings |

---

## CLI Menu

```
--- Dungeon Codex ---
1) List spells
2) List items
3) Create a new spell
4) List monsters by environment
5) List all environments
6) Show monster roster
0) Exit
```

---

## File Structure

```
final_project/
├── README.md
├── backend/
│   ├── main.py            Python backend — DB functions + CLI menu
│   └── requirements.txt
├── frontend/
│   ├── app.py             Flask web application
│   ├── requirements.txt
│   ├── templates/
│   │   ├── base.html
│   │   ├── index.html
│   │   ├── spells.html
│   │   ├── items.html
│   │   ├── monsters.html
│   │   └── environments.html
│   └── static/css/
│       └── style.css
└── db_proof/
    ├── schema.sql          CREATE TABLE + VIEW + TRIGGER
    ├── data.sql            Sample data with NULLs and boundary values
    ├── constraints_test.sql  4 failing INSERT statements
    ├── queries.sql         10 SQL queries
    └── query_outputs.txt   Template for recording query results
```

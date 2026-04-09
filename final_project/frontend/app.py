import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from flask import Flask, render_template, request, redirect, url_for, flash
from backend.main import (
    list_spells, list_items, create_spell,
    list_monsters_by_env, list_environments, get_monster_roster,
)

app = Flask(__name__)
app.secret_key = "dungeon-codex-secret"


@app.route("/")
def index():
    try:
        environments = list_environments()
        roster = get_monster_roster()
    except Exception as e:
        flash(f"Database error: {e}", "error")
        environments, roster = [], []
    return render_template("index.html", environments=environments, roster=roster)


@app.route("/spells", methods=["GET", "POST"])
def spells():
    if request.method == "POST":
        name = request.form.get("name", "").strip()
        level = request.form.get("level", "0").strip()

        if not name:
            flash("Spell name cannot be empty.", "error")
            return redirect(url_for("spells"))

        try:
            level_int = int(level)
            if not (0 <= level_int <= 9):
                raise ValueError
        except ValueError:
            flash("Level must be a number between 0 and 9.", "error")
            return redirect(url_for("spells"))

        try:
            new_id = create_spell(name, level_int)
            flash(f"Spell '{name}' created (id={new_id}).", "success")
        except Exception as e:
            flash(f"Could not create spell: {e}", "error")

        return redirect(url_for("spells"))

    try:
        rows = list_spells()
    except Exception as e:
        flash(f"Database error: {e}", "error")
        rows = []
    return render_template("spells.html", spells=rows)


@app.route("/items")
def items():
    rarity = request.args.get("rarity", "").strip() or None
    try:
        rows = list_items(rarity_filter=rarity)
    except Exception as e:
        flash(f"Database error: {e}", "error")
        rows = []
    rarities = ["Common", "Uncommon", "Rare", "Very Rare", "Legendary"]
    return render_template("items.html", items=rows, rarities=rarities, selected_rarity=rarity)


@app.route("/monsters")
def monsters():
    env_name = request.args.get("environment", "").strip() or None
    rows = []
    try:
        environments = list_environments()
        if env_name:
            rows = list_monsters_by_env(env_name)
    except Exception as e:
        flash(f"Database error: {e}", "error")
        environments = []
    return render_template("monsters.html", monsters=rows,
                           environments=environments, selected_env=env_name)


@app.route("/environments")
def environments():
    try:
        rows = list_environments()
    except Exception as e:
        flash(f"Database error: {e}", "error")
        rows = []
    return render_template("environments.html", environments=rows)


if __name__ == "__main__":
    app.run(debug=True)

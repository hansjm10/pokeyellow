#!/usr/bin/env python3

"""
Generate navigation docs for high-traffic data tables.

The generated docs are meant to answer "where do I edit this?" without changing
the matching build. They intentionally link back to source tables instead of
duplicating every byte of data.
"""

from __future__ import annotations

import argparse
import re
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
CHECK_ONLY = False
STALE_DOCS: list[str] = []


ASM_SOURCE_DIRS = (
	"audio",
	"constants",
	"data",
	"engine",
	"gfx",
	"home",
	"macros",
	"ram",
	"scripts",
	"text",
	"vc",
)


def read_lines(relpath: str) -> list[str]:
	return (ROOT / relpath).read_text(encoding="utf-8").splitlines()


def write_doc(relpath: str, lines: list[str]) -> None:
	path = ROOT / relpath
	contents = "\n".join(lines) + "\n"
	if CHECK_ONLY:
		current = path.read_text(encoding="utf-8") if path.exists() else None
		if current != contents:
			STALE_DOCS.append(relpath)
		return
	path.write_text(contents, encoding="utf-8", newline="\n")


def repo_path(path: Path | str) -> str:
	path = Path(path)
	if path.is_absolute():
		path = path.relative_to(ROOT)
	return path.as_posix()


def path_sort_key(path: Path) -> str:
	return repo_path(path).lower()


def link(path: Path | str, label: str | None = None, line: int | None = None) -> str:
	rel = repo_path(path)
	target = f"/{rel}"
	if line:
		target += f"#L{line}"
	return f"[{label or rel}]({target})"


def code_link(path: Path | str, label: str | None = None, line: int | None = None) -> str:
	return link(path, f"`{label or repo_path(path)}`", line)


def clean_code(line: str) -> str:
	return line.split(";", 1)[0].strip()


def split_comment(line: str) -> tuple[str, str]:
	if ";" not in line:
		return line.rstrip(), ""
	code, comment = line.split(";", 1)
	return code.rstrip(), comment.strip()


def md_escape(value: object) -> str:
	text = str(value) if value is not None else ""
	text = text.replace("\\", "\\\\")
	text = text.replace("|", "\\|")
	text = text.replace("\n", "<br>")
	return text


def table(headers: list[str], rows: list[list[object]]) -> list[str]:
	out = [
		"| " + " | ".join(headers) + " |",
		"| " + " | ".join("---" for _ in headers) + " |",
	]
	for row in rows:
		out.append("| " + " | ".join(md_escape(cell) for cell in row) + " |")
	return out


def find_line(relpath: str, predicate) -> int | None:
	for lineno, line_text in enumerate(read_lines(relpath), 1):
		if predicate(line_text):
			return lineno
	return None


def find_label_line(relpath: str, label_name: str) -> int | None:
	pattern = re.compile(rf"^{re.escape(label_name)}::?$")
	return find_line(relpath, lambda line_text: bool(pattern.match(clean_code(line_text))))


def label_link(relpath: str, label_name: str) -> str:
	return code_link(relpath, label_name, find_label_line(relpath, label_name))


def parse_const_block(relpath: str, keywords: tuple[str, ...] = ("const",)) -> list[dict[str, object]]:
	value = 0
	items: list[dict[str, object]] = []
	for lineno, line_text in enumerate(read_lines(relpath), 1):
		code, comment = split_comment(line_text)
		parts = code.strip().split()
		if not parts:
			continue
		if parts[0] == "const_def":
			value = int(parts[1], 0) if len(parts) > 1 else 0
			continue
		if parts[0] == "const_next":
			value = int(parts[1].replace("$", "0x"), 0)
			continue
		if parts[0] == "const_skip":
			count = int(parts[1], 0) if len(parts) > 1 else 1
			value += count
			continue
		if parts[0] not in keywords:
			continue
		if len(parts) < 2:
			continue
		items.append({
			"name": parts[1],
			"value": value,
			"comment": comment,
			"line": lineno,
		})
		value += 1
	return items


def parse_string_list(relpath: str, macro: str) -> list[str]:
	values: list[str] = []
	for line_text in read_lines(relpath):
		code = clean_code(line_text)
		match = re.match(rf'{re.escape(macro)}\s+"([^"]*)"', code)
		if match:
			values.append(match.group(1))
	return values


def const_to_title(name: str) -> str:
	special = {
		"NIDORAN_M": "Nidoran M",
		"NIDORAN_F": "Nidoran F",
		"MR_MIME": "Mr Mime",
		"PSYCHIC_M": "Psychic",
		"PSYCHIC_TR": "Psychic",
		"LT_SURGE": "Lt Surge",
		"JR_TRAINER_M": "Jr Trainer M",
		"JR_TRAINER_F": "Jr Trainer F",
	}
	if name in special:
		return special[name]
	return " ".join(part.capitalize() for part in name.split("_"))


def pokemon_label_prefix(const_name: str) -> str:
	special = {
		"NIDORAN_M": "NidoranM",
		"NIDORAN_F": "NidoranF",
		"MR_MIME": "MrMime",
	}
	if const_name in special:
		return special[const_name]
	return "".join(part.capitalize() for part in const_name.split("_"))


def parse_pokemon_base_stats(relpath: str) -> dict[str, object]:
	lines = read_lines(relpath)
	dex_const = ""
	stats = ""
	types = ""
	catch_rate = ""
	base_exp = ""
	level_one = ""
	front_pic = ""
	back_pic = ""
	tmhm_count = 0
	in_tmhm = False
	tmhm_parts: list[str] = []

	for idx, line_text in enumerate(lines):
		code = clean_code(line_text)
		if not dex_const:
			match = re.match(r"db\s+(DEX_[A-Z0-9_]+)", code)
			if match:
				dex_const = match.group(1)
				continue
		if not stats:
			match = re.match(r"db\s+([0-9,\s]+)$", code)
			if match and idx + 1 < len(lines) and "hp  atk  def" in lines[idx + 1]:
				stats = " / ".join(part.strip() for part in match.group(1).split(","))
				continue
		if not types:
			match = re.match(r"db\s+([A-Z0-9_]+),\s*([A-Z0-9_]+)\s*;\s*type", line_text.strip())
			if match:
				types = f"{match.group(1)} / {match.group(2)}"
				continue
		if not catch_rate:
			match = re.match(r"db\s+([^;]+);\s*catch rate", line_text.strip())
			if match:
				catch_rate = match.group(1).strip()
				continue
		if not base_exp:
			match = re.match(r"db\s+([^;]+);\s*base exp", line_text.strip())
			if match:
				base_exp = match.group(1).strip()
				continue
		if not front_pic:
			match = re.search(r'INCBIN\s+"([^"]+)"', code)
			if match and "gfx/pokemon/front/" in match.group(1):
				front_pic = match.group(1).replace(".pic", ".png")
				continue
		if not back_pic:
			match = re.match(r"dw\s+([A-Za-z0-9_]+PicFront),\s*([A-Za-z0-9_]+PicBack)", code)
			if match:
				label = match.group(2)
				back_pic = parse_pic_paths().get(label, "").replace(".pic", ".png")
				continue
		if not level_one:
			match = re.match(r"db\s+(.+?)\s*;\s*level 1 learnset", line_text.strip())
			if match:
				level_one = ", ".join(part.strip() for part in match.group(1).split(","))
				continue
		if code.startswith("tmhm "):
			in_tmhm = True
		if in_tmhm:
			tmhm_parts.extend(re.findall(r"\b[A-Z][A-Z0-9_]*\b", code))
			if "; end" in line_text:
				in_tmhm = False

	tmhm_count = sum(1 for item in tmhm_parts if item != "tmhm")
	return {
		"dex_const": dex_const,
		"const": dex_const.removeprefix("DEX_"),
		"stats": stats,
		"types": types,
		"catch_rate": catch_rate,
		"base_exp": base_exp,
		"front_pic": front_pic,
		"back_pic": back_pic,
		"level_one": level_one,
		"tmhm_count": tmhm_count,
	}


_pic_paths_cache: dict[str, str] | None = None


def parse_pic_paths() -> dict[str, str]:
	global _pic_paths_cache
	if _pic_paths_cache is not None:
		return _pic_paths_cache
	paths: dict[str, str] = {}
	for line_text in read_lines("gfx/pics.asm"):
		match = re.match(r"([A-Za-z0-9_]+)::\s+INCBIN\s+\"([^\"]+)\"", clean_code(line_text))
		if match:
			paths[match.group(1)] = match.group(2)
	_pic_paths_cache = paths
	return paths


def parse_evos_moves_blocks() -> dict[str, dict[str, object]]:
	lines = read_lines("data/pokemon/evos_moves.asm")
	labels = [(idx, clean_code(line_text).rstrip(":")) for idx, line_text in enumerate(lines)
		if re.match(r"^[A-Za-z0-9_]+EvosMoves:$", clean_code(line_text))]
	blocks: dict[str, dict[str, object]] = {}
	for pos, (start_idx, label_name) in enumerate(labels):
		end_idx = labels[pos + 1][0] if pos + 1 < len(labels) else len(lines)
		evolutions: list[str] = []
		learn_moves: list[str] = []
		in_learnset = False
		for line_text in lines[start_idx + 1:end_idx]:
			code = clean_code(line_text)
			if not code:
				continue
			if code == "db 0":
				if not in_learnset:
					in_learnset = True
					continue
				break
			if not code.startswith("db "):
				continue
			values = [part.strip() for part in code[3:].split(",")]
			if not in_learnset:
				method = values[0]
				if method == "EVOLVE_LEVEL" and len(values) >= 3:
					evolutions.append(f"Lv {values[1]} -> {values[2]}")
				elif method == "EVOLVE_ITEM" and len(values) >= 4:
					evolutions.append(f"{values[1]} -> {values[3]}")
				elif method == "EVOLVE_TRADE" and len(values) >= 3:
					evolutions.append(f"Trade -> {values[2]}")
				else:
					evolutions.append(", ".join(values))
			else:
				if len(values) >= 2:
					learn_moves.append(f"Lv {values[0]} {values[1]}")
		blocks[label_name] = {
			"evolutions": evolutions,
			"learn_moves": learn_moves,
		}
	return blocks


def build_pokemon_index() -> None:
	dex_consts = parse_const_block("constants/pokedex_constants.asm")
	dex_by_const = {item["name"]: item["value"] for item in dex_consts}
	index_consts = parse_const_block("constants/pokemon_constants.asm")
	index_by_const = {item["name"]: item for item in index_consts}
	names = parse_string_list("data/pokemon/names.asm", "dname")
	names_by_const = {}
	for item in index_consts:
		value = int(item["value"])
		if item["name"] == "NO_MON" or value <= 0:
			continue
		name_index = value - 1
		if name_index < len(names):
			names_by_const[item["name"]] = names[name_index]

	cries: dict[str, dict[str, object]] = {}
	cry_lines = []
	for lineno, line_text in enumerate(read_lines("data/pokemon/cries.asm"), 1):
		match = re.match(r"\s*mon_cry\s+([^,]+),\s*([^,]+),\s*([^;]+)", line_text)
		if match:
			cry_lines.append((lineno, match.group(1).strip(), match.group(2).strip(), match.group(3).strip()))
	for item in index_consts:
		value = int(item["value"])
		if item["name"] == "NO_MON" or value <= 0:
			continue
		cry_index = value - 1
		if cry_index < len(cry_lines):
			lineno, sfx, pitch, length = cry_lines[cry_index]
			cries[str(item["name"])] = {
				"sfx": sfx,
				"pitch": pitch,
				"length": length,
				"line": lineno,
			}

	evos = parse_evos_moves_blocks()
	base_includes = []
	for lineno, line_text in enumerate(read_lines("data/pokemon/base_stats.asm"), 1):
		match = re.search(r'INCLUDE\s+"([^"]+)"', line_text)
		if match:
			base_includes.append((lineno, match.group(1)))

	rows = []
	for _include_line, base_path in base_includes:
		data = parse_pokemon_base_stats(base_path)
		const_name = str(data["const"])
		dex_const = str(data["dex_const"])
		prefix = pokemon_label_prefix(const_name)
		evo_label = f"{prefix}EvosMoves"
		dex_entry_label = f"{prefix}DexEntry"
		dex_text_label = f"_{prefix}DexEntry"
		evo_data = evos.get(evo_label, {})
		learn_moves = evo_data.get("learn_moves", [])
		evolutions = evo_data.get("evolutions", [])
		cry = cries.get(const_name, {})
		sprite_links = []
		if data["front_pic"]:
			sprite_links.append(link(str(data["front_pic"]), "front"))
		if data["back_pic"]:
			sprite_links.append(link(str(data["back_pic"]), "back"))
		dex_entry_line = find_label_line("data/pokemon/dex_entries.asm", dex_entry_label)
		dex_text_line = find_label_line("data/pokemon/dex_text.asm", dex_text_label)
		rows.append([
			f"{int(dex_by_const.get(dex_const, 0)):03d}",
			names_by_const.get(const_name, const_to_title(const_name)),
			f"`{const_name}`",
			code_link(base_path, base_path.rsplit("/", 1)[-1]),
			data["stats"],
			data["types"],
			" / ".join(sprite_links),
			f"{code_link('data/pokemon/cries.asm', str(cry.get('sfx', '-')), cry.get('line'))}<br>{cry.get('pitch', '-')}, {cry.get('length', '-')}",
			("<br>".join(evolutions) if evolutions else "None") + "<br>" + label_link("data/pokemon/evos_moves.asm", evo_label),
			f"{len(learn_moves)} level-up<br>Lv 1: `{data['level_one']}`<br>{data['tmhm_count']} TM/HM<br>{label_link('data/pokemon/evos_moves.asm', evo_label)}",
			f"{code_link('data/pokemon/dex_entries.asm', dex_entry_label, dex_entry_line)}<br>{code_link('data/pokemon/dex_text.asm', dex_text_label, dex_text_line)}",
		])

	lines = [
		"# Pokemon Data Index",
		"",
		"Generated by `tools/generate_navigation_docs.py`. Do not edit by hand.",
		"",
		"This index links each Pokedex-order Pokemon to its base stats, sprite sources, cry data, evolution and learnset block, and Pokedex text.",
		"",
		"## Source Tables",
		"",
		"- " + link("constants/pokedex_constants.asm"),
		"- " + link("constants/pokemon_constants.asm"),
		"- " + link("data/pokemon/base_stats.asm"),
		"- " + link("data/pokemon/cries.asm"),
		"- " + link("data/pokemon/evos_moves.asm"),
		"- " + link("data/pokemon/dex_entries.asm"),
		"- " + link("data/pokemon/dex_text.asm"),
		"- " + link("gfx/pics.asm"),
		"",
		"## Pokemon",
		"",
	]
	lines.extend(table([
		"Dex",
		"Name",
		"Constant",
		"Base Stats",
		"HP/Atk/Def/Spd/Spc",
		"Types",
		"Sprites",
		"Cry",
		"Evolutions",
		"Learnsets",
		"Pokedex Text",
	], rows))
	write_doc("docs/pokemon_index.md", lines)


def parse_move_constants() -> list[dict[str, object]]:
	items = parse_const_block("constants/move_constants.asm")
	out = []
	for item in items:
		if item["name"] == "NO_MOVE":
			continue
		if item["name"] == "SHOWPIC_ANIM":
			break
		out.append(item)
	return out


def parse_move_effect_constants() -> dict[str, int]:
	return {str(item["name"]): int(item["value"]) for item in parse_const_block("constants/move_effect_constants.asm")}


def parse_move_rows() -> list[dict[str, str]]:
	rows = []
	for lineno, line_text in enumerate(read_lines("data/moves/moves.asm"), 1):
		code = clean_code(line_text)
		match = re.match(r"move\s+(.+)", code)
		if not match:
			continue
		parts = [part.strip() for part in match.group(1).split(",")]
		if len(parts) != 6:
			continue
		rows.append({
			"line": str(lineno),
			"animation": parts[0],
			"effect": parts[1],
			"power": parts[2],
			"type": parts[3],
			"accuracy": parts[4],
			"pp": parts[5],
		})
	return rows


def parse_attack_animation_pointers() -> list[dict[str, object]]:
	pointers = []
	in_table = False
	for lineno, line_text in enumerate(read_lines("data/moves/animations.asm"), 1):
		code = clean_code(line_text)
		if code == "AttackAnimationPointers:":
			in_table = True
			continue
		if not in_table:
			continue
		if "assert_table_length NUM_ATTACKS" in code:
			break
		match = re.match(r"dw\s+([A-Za-z0-9_]+)", code)
		if match:
			pointers.append({"label": match.group(1), "line": lineno})
	return pointers


def parse_effect_pointers() -> dict[str, dict[str, object]]:
	pointers: dict[str, dict[str, object]] = {
		"NO_ADDITIONAL_EFFECT": {"label": "-", "line": None},
	}
	for lineno, line_text in enumerate(read_lines("data/moves/effects_pointers.asm"), 1):
		code, comment = split_comment(line_text)
		match = re.match(r"\s*dw\s+([A-Za-z0-9_]+)", code)
		if match and comment:
			effect_name = comment.split()[0]
			if "effect" in comment.lower() and effect_name == "unused":
				continue
			pointers[effect_name] = {"label": match.group(1), "line": lineno}
	return pointers


def parse_tmhm_items() -> dict[str, list[str]]:
	tmhm: dict[str, list[str]] = defaultdict(list)
	hm_number = 1
	tm_number = 1
	for lineno, line_text in enumerate(read_lines("constants/item_constants.asm"), 1):
		code = clean_code(line_text)
		match = re.match(r"add_hm\s+([A-Z0-9_]+)", code)
		if match:
			tmhm[match.group(1)].append(code_link("constants/item_constants.asm", f"HM{hm_number:02d}", lineno))
			hm_number += 1
			continue
		match = re.match(r"add_tm\s+([A-Z0-9_]+)", code)
		if match:
			tmhm[match.group(1)].append(code_link("constants/item_constants.asm", f"TM{tm_number:02d}", lineno))
			tm_number += 1
	return tmhm


def build_move_index() -> None:
	consts = parse_move_constants()
	names = parse_string_list("data/moves/names.asm", "li")
	move_rows = parse_move_rows()
	animations = parse_attack_animation_pointers()
	effect_pointers = parse_effect_pointers()
	tmhm = parse_tmhm_items()
	rows = []
	for idx, item in enumerate(consts):
		move_name = str(item["name"])
		move_data = move_rows[idx]
		anim = animations[idx]
		effect = move_data["effect"]
		effect_impl = effect_pointers.get(effect, {"label": "?", "line": None})
		rows.append([
			f"${int(item['value']):02X}",
			names[idx] if idx < len(names) else const_to_title(move_name),
			f"`{move_name}`",
			code_link("data/moves/moves.asm", "move", int(move_data["line"])),
			move_data["type"],
			move_data["power"],
			move_data["accuracy"],
			move_data["pp"],
			f"`{effect}`<br>{code_link('data/moves/effects_pointers.asm', str(effect_impl['label']), effect_impl.get('line')) if effect_impl['label'] != '-' else '-'}",
			code_link("data/moves/animations.asm", str(anim["label"]), int(anim["line"])),
			"<br>".join(tmhm.get(move_name, [])) or "-",
		])

	lines = [
		"# Move Index",
		"",
		"Generated by `tools/generate_navigation_docs.py`. Do not edit by hand.",
		"",
		"This index links each move constant to its name, battle data, animation pointer, effect handler, and TM/HM item mapping.",
		"",
		"## Source Tables",
		"",
		"- " + link("constants/move_constants.asm"),
		"- " + link("constants/move_effect_constants.asm"),
		"- " + link("constants/item_constants.asm"),
		"- " + link("data/moves/names.asm"),
		"- " + link("data/moves/moves.asm"),
		"- " + link("data/moves/animations.asm"),
		"- " + link("data/moves/effects_pointers.asm"),
		"- " + link("data/moves/tmhm_moves.asm"),
		"- " + link("data/moves/hm_moves.asm"),
		"",
		"## Moves",
		"",
	]
	lines.extend(table([
		"ID",
		"Name",
		"Constant",
		"Data",
		"Type",
		"Power",
		"Accuracy",
		"PP",
		"Effect",
		"Animation",
		"TM/HM",
	], rows))
	write_doc("docs/move_index.md", lines)


def parse_data_pointer_table(relpath: str, table_label: str) -> list[dict[str, object]]:
	pointers = []
	in_table = False
	for lineno, line_text in enumerate(read_lines(relpath), 1):
		code = clean_code(line_text)
		if code == f"{table_label}:":
			in_table = True
			continue
		if not in_table:
			continue
		if code.startswith("assert_table_length"):
			break
		match = re.match(r"dw\s+([A-Za-z0-9_.]+)", code)
		if match:
			pointers.append({"label": match.group(1), "line": lineno})
	return pointers


def parse_trainer_ai() -> list[dict[str, object]]:
	rows = []
	for lineno, line_text in enumerate(read_lines("data/trainers/ai_pointers.asm"), 1):
		code, comment = split_comment(line_text)
		match = re.match(r"\s*dbw\s+([^,]+),\s*([A-Za-z0-9_]+)", code)
		if match:
			rows.append({
				"uses": match.group(1).strip(),
				"label": match.group(2),
				"comment": comment,
				"line": lineno,
			})
	return rows


def parse_trainer_parties() -> dict[str, dict[str, object]]:
	lines = read_lines("data/trainers/parties.asm")
	labels = [(idx, clean_code(line_text).rstrip(":")) for idx, line_text in enumerate(lines)
		if re.match(r"^[A-Za-z0-9_]+Data:$", clean_code(line_text))]
	parties: dict[str, dict[str, object]] = {}
	for pos, (start_idx, label_name) in enumerate(labels):
		end_idx = labels[pos + 1][0] if pos + 1 < len(labels) else len(lines)
		entries = []
		current_location = ""
		for line_text in lines[start_idx + 1:end_idx]:
			code, comment = split_comment(line_text)
			stripped = code.strip()
			if line_text.strip().startswith(";"):
				current_location = line_text.strip()[1:].strip()
				continue
			if not stripped.startswith("db "):
				continue
			values = [part.strip() for part in stripped[3:].split(",")]
			if values == ["0"]:
				continue
			if values[0] == "$FF":
				mons = [values[i + 1] for i in range(1, len(values) - 1, 2) if i + 1 < len(values) and values[i + 1] != "0"]
				level = "mixed"
			else:
				level = values[0]
				mons = [value for value in values[1:] if value != "0"]
			entries.append({
				"location": current_location,
				"level": level,
				"mons": mons,
			})
		parties[label_name] = {"entries": entries}
	return parties


def summarize_locations(entries: list[dict[str, object]]) -> str:
	counts: dict[str, int] = defaultdict(int)
	for entry in entries:
		location = str(entry.get("location") or "Unlabeled")
		counts[location] += 1
	return "<br>".join(f"{name}: {count}" for name, count in counts.items()) or "None"


def parse_trainer_object_refs() -> dict[str, list[dict[str, object]]]:
	refs: dict[str, list[dict[str, object]]] = defaultdict(list)
	for path in sorted((ROOT / "data/maps/objects").glob("*.asm"), key=path_sort_key):
		rel = repo_path(path)
		map_name = path.stem
		for lineno, line_text in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
			code = clean_code(line_text)
			match = re.match(r"object_event\s+(.+)", code)
			if not match:
				continue
			args = [arg.strip() for arg in match.group(1).split(",")]
			if len(args) < 8:
				continue
			opp = next((arg for arg in args if arg.startswith("OPP_")), None)
			if not opp:
				continue
			trainer_id = args[args.index(opp) + 1] if args.index(opp) + 1 < len(args) else "?"
			refs[opp.removeprefix("OPP_")].append({
				"map": map_name,
				"id": trainer_id,
				"line": lineno,
				"path": rel,
			})
	return refs


def parse_direct_script_opp_refs() -> dict[str, list[dict[str, object]]]:
	refs: dict[str, list[dict[str, object]]] = defaultdict(list)
	for path in sorted((ROOT / "scripts").glob("*.asm"), key=path_sort_key):
		rel = repo_path(path)
		for lineno, line_text in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
			for opp in re.findall(r"\bOPP_([A-Z0-9_]+)\b", clean_code(line_text)):
				refs[opp].append({
					"script": path.stem,
					"line": lineno,
					"path": rel,
				})
	return refs


def build_trainer_index() -> None:
	consts = [item for item in parse_const_block("constants/trainer_constants.asm", ("trainer_const",)) if item["name"] != "NOBODY"]
	names = parse_string_list("data/trainers/names.asm", "li")
	party_pointers = parse_data_pointer_table("data/trainers/parties.asm", "TrainerDataPointers")
	parties = parse_trainer_parties()
	ai_rows = parse_trainer_ai()
	object_refs = parse_trainer_object_refs()
	direct_script_refs = parse_direct_script_opp_refs()

	rows = []
	for idx, item in enumerate(consts):
		const_name = str(item["name"])
		party_pointer = party_pointers[idx]
		party_entries = parties.get(str(party_pointer["label"]), {}).get("entries", [])
		ai = ai_rows[idx] if idx < len(ai_rows) else {"uses": "?", "label": "?", "line": None}
		map_refs = object_refs.get(const_name, [])
		script_refs = list(direct_script_refs.get(const_name, []))
		related_scripts = []
		seen_scripts = {ref["script"] for ref in script_refs}
		for ref in map_refs:
			script_path = ROOT / "scripts" / f"{ref['map']}.asm"
			if script_path.exists() and ref["map"] not in seen_scripts:
				related_scripts.append({
					"script": ref["map"],
					"line": 1,
					"path": repo_path(script_path),
				})
				seen_scripts.add(ref["map"])
		map_ref_text = "<br>".join(
			f"{code_link(ref['path'], str(ref['map']), int(ref['line']))} #{ref['id']}"
			for ref in map_refs
		) or "-"
		script_ref_text = "<br>".join(
			code_link(ref["path"], str(ref["script"]), int(ref["line"]))
			for ref in script_refs
		) or "-"
		related_script_text = "<br>".join(
			code_link(ref["path"], str(ref["script"]), int(ref["line"]))
			for ref in related_scripts
		) or "-"
		script_text = f"{len(script_refs)} direct refs<br>{script_ref_text}"
		if related_scripts:
			script_text += f"<br>Related map scripts:<br>{related_script_text}"
		rows.append([
			f"${int(item['value']):02X}",
			names[idx] if idx < len(names) else const_to_title(const_name),
			f"`{const_name}`",
			code_link("constants/trainer_constants.asm", const_name, int(item["line"])),
			f"{len(party_entries)} parties<br>{label_link('data/trainers/parties.asm', str(party_pointer['label']))}<br>{summarize_locations(party_entries)}",
			f"{ai['uses']} uses/Pokemon<br>{code_link('data/trainers/ai_pointers.asm', str(ai['label']), ai.get('line'))}",
			f"{len(map_refs)} refs<br>{map_ref_text}",
			script_text,
		])

	lines = [
		"# Trainer Index",
		"",
		"Generated by `tools/generate_navigation_docs.py`. Do not edit by hand.",
		"",
		"This index links each trainer class to class constants, party data, AI, map object references, direct script references, and related map scripts.",
		"",
		"## Source Tables",
		"",
		"- " + link("constants/trainer_constants.asm"),
		"- " + link("data/trainers/names.asm"),
		"- " + link("data/trainers/parties.asm"),
		"- " + link("data/trainers/ai_pointers.asm"),
		"- " + link("data/trainers/move_choices.asm"),
		"- " + link("data/trainers/special_moves.asm"),
		"- " + link("data/maps/objects"),
		"- " + link("scripts"),
		"",
		"## Trainer Classes",
		"",
	]
	lines.extend(table([
		"ID",
		"Name",
		"Constant",
		"Class Source",
		"Parties",
		"AI",
		"Map References",
		"Script References",
	], rows))
	write_doc("docs/trainer_index.md", lines)


@dataclass
class RamSymbol:
	name: str
	relpath: str
	line: int
	section: str
	storage: str
	comment: str


def compact_comment(lines: list[str], inline: str) -> str:
	parts = [line.strip()[1:].strip() for line in lines if line.strip().startswith(";")]
	if inline:
		parts.append(inline)
	text = " ".join(part for part in parts[-3:] if part)
	return text[:180] + ("..." if len(text) > 180 else "")


def parse_ram_symbols(relpath: str) -> list[RamSymbol]:
	lines = read_lines(relpath)
	symbols: list[RamSymbol] = []
	section = ""
	pending: list[tuple[str, int, list[str], str]] = []
	comment_buffer: list[str] = []
	label_pattern = re.compile(r"\b([A-Za-z_][A-Za-z0-9_{}:]*?)::")
	storage_prefixes = (
		"db",
		"dw",
		"ds",
		"flag_array",
		"box_struct",
		"party_struct",
		"battle_struct",
		"spritestatedata1",
		"spritestatedata2",
		"sprite_oam_struct",
		"map_connection_struct",
		"animated_object",
	)
	control_directives = {
		"UNION",
		"NEXTU",
		"ENDU",
		"FOR",
		"ENDR",
		"ASSERT",
	}

	def flush_pending(storage: str = "anchor") -> None:
		nonlocal pending
		for label_name, label_line, comments, label_inline in pending:
			symbols.append(RamSymbol(
				name=label_name,
				relpath=relpath,
				line=label_line,
				section=section,
				storage=storage,
				comment=compact_comment(comments, label_inline),
			))
		pending = []

	def is_storage(value: str) -> bool:
		return value.startswith(storage_prefixes)

	for lineno, line_text in enumerate(lines, 1):
		code, inline_comment = split_comment(line_text)
		stripped = code.strip()
		if stripped.startswith("SECTION "):
			if pending:
				flush_pending()
			section = stripped
			comment_buffer.clear()
			continue
		if line_text.strip().startswith(";"):
			comment_buffer.append(line_text)
			continue
		if not stripped:
			if pending:
				flush_pending()
			comment_buffer.clear()
			continue

		labels = label_pattern.findall(code)
		remainder = label_pattern.sub("", code).strip()
		if labels:
			if remainder and pending:
				flush_pending()
			for label_name in labels:
				pending.append((label_name, lineno, list(comment_buffer), inline_comment))
			comment_buffer.clear()
			if not remainder:
				continue
		elif not pending:
			comment_buffer.clear()
			continue

		first_word = stripped.split(maxsplit=1)[0]
		if first_word in control_directives:
			if pending:
				flush_pending()
			comment_buffer.clear()
			continue

		storage = ""
		if remainder and is_storage(remainder):
			storage = remainder
		elif is_storage(stripped):
			storage = stripped
		if not storage:
			if pending:
				flush_pending()
			comment_buffer.clear()
			continue
		flush_pending(storage)
		comment_buffer.clear()

	if pending:
		flush_pending()

	return symbols


def source_files() -> list[Path]:
	files: list[Path] = []
	for dirname in ASM_SOURCE_DIRS:
		root = ROOT / dirname
		if not root.exists():
			continue
		files.extend(sorted(root.rglob("*.asm"), key=path_sort_key))
		files.extend(sorted(root.rglob("*.inc"), key=path_sort_key))
	for rel in ("audio.asm", "home.asm", "includes.asm", "main.asm", "maps.asm", "ram.asm", "text.asm"):
		path = ROOT / rel
		if path.exists():
			files.append(path)
	return sorted(set(files), key=path_sort_key)


def build_symbol_references(symbols: list[RamSymbol]) -> dict[str, list[tuple[str, int]]]:
	names = {symbol.name for symbol in symbols if "{" not in symbol.name}
	refs: dict[str, list[tuple[str, int]]] = {name: [] for name in names}
	token_pattern = re.compile(r"\b[A-Za-z_][A-Za-z0-9_]*\b")
	for path in source_files():
		rel = repo_path(path)
		for lineno, line_text in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
			code = clean_code(line_text)
			tokens = set(token_pattern.findall(code))
			for token in tokens & names:
				if re.search(rf"\b{re.escape(token)}::", code):
					continue
				refs[token].append((rel, lineno))
	return refs


def format_refs(refs: list[tuple[str, int]], limit: int = 4) -> str:
	if not refs:
		return "-"
	links = [code_link(path, f"{Path(path).name}:{line_no}", line_no) for path, line_no in refs[:limit]]
	if len(refs) > limit:
		links.append(f"+{len(refs) - limit} more")
	return f"{len(refs)} refs<br>" + "<br>".join(links)


def build_ram_index() -> None:
	symbols = parse_ram_symbols("ram/wram.asm") + parse_ram_symbols("ram/hram.asm")
	refs = build_symbol_references(symbols)
	rows = []
	for symbol in symbols:
		rows.append([
			code_link(symbol.relpath, symbol.name, symbol.line),
			symbol.section.replace("|", "\\|"),
			f"`{symbol.storage}`",
			symbol.comment or "-",
			format_refs(refs.get(symbol.name, [])),
		])

	lines = [
		"# RAM and HRAM Index",
		"",
		"Generated by `tools/generate_navigation_docs.py`. Do not edit by hand.",
		"",
		"This index links WRAM and HRAM symbols to their storage declarations, nearby comments, and source references.",
		"",
		"Reference counts are based on direct symbol mentions in assembly sources. Macro-generated names with format placeholders are listed from the RAM source but are not expanded.",
		"",
		"## Source Tables",
		"",
		"- " + link("ram/wram.asm"),
		"- " + link("ram/hram.asm"),
		"- " + link("macros/ram.asm"),
		"",
		"## Symbols",
		"",
	]
	lines.extend(table([
		"Symbol",
		"Section",
		"Size / Storage",
		"Nearby Comments",
		"References",
	], rows))
	write_doc("docs/ram_index.md", lines)


def main() -> None:
	parser = argparse.ArgumentParser(description=__doc__)
	parser.add_argument("--check", action="store_true", help="fail if generated docs are stale")
	args = parser.parse_args()
	global CHECK_ONLY
	CHECK_ONLY = args.check

	DOCS.mkdir(exist_ok=True)
	build_pokemon_index()
	build_move_index()
	build_trainer_index()
	build_ram_index()
	if STALE_DOCS:
		for relpath in STALE_DOCS:
			print(f"{relpath} is stale; run tools/generate_navigation_docs.py")
		raise SystemExit(1)
	if CHECK_ONLY:
		print("Generated navigation docs are up to date.")


if __name__ == "__main__":
	main()

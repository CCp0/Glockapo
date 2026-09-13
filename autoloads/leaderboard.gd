extends Node

const SAVE_PATH := "user://leaderboard.json"
const MAX_ENTRIES := 10

var entries: Array = []


func _ready() -> void:
	_load()


func record_run(birds_downed: int, nests_destroyed: int) -> Dictionary:
	var entry := {"birds_downed": birds_downed, "nests_destroyed": nests_destroyed}
	entries.append(entry)
	entries.sort_custom(_is_better)
	var rank: int = entries.find(entry) + 1
	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)
	_save()
	return {"entry": entry, "rank": rank, "made_the_list": rank <= MAX_ENTRIES}


func _is_better(a: Dictionary, b: Dictionary) -> bool:
	if a["nests_destroyed"] != b["nests_destroyed"]:
		return a["nests_destroyed"] > b["nests_destroyed"]
	return a["birds_downed"] > b["birds_downed"]


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(entries))


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		entries = parsed

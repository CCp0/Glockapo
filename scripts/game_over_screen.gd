extends CanvasLayer

@onready var restart_button: Button = $RestartButton
@onready var run_stats_label: Label = $RunStatsLabel
@onready var leaderboard_list: RichTextLabel = $LeaderboardList


func _ready() -> void:
	visible = false
	GameState.died.connect(_on_died)
	restart_button.pressed.connect(_on_restart_pressed)


func _on_died() -> void:
	visible = true

	var birds: int = GameState.total_birds_downed_this_run
	var nests: int = GameState.nests_destroyed_this_run
	run_stats_label.text = "Birds downed: %d    Nests destroyed: %d" % [birds, nests]

	var result: Dictionary = Leaderboard.record_run(birds, nests)
	_populate_leaderboard(result)


func _populate_leaderboard(result: Dictionary) -> void:
	var lines: Array[String] = ["[center][b]LEADERBOARD[/b][/center]"]
	for i in Leaderboard.entries.size():
		var entry: Dictionary = Leaderboard.entries[i]
		var line: String = "%d. %d birds, %d nests" % [i + 1, entry["birds_downed"], entry["nests_destroyed"]]
		if result["made_the_list"] and i + 1 == result["rank"]:
			line = "[color=#ffcc44]%s  <- this run[/color]" % line
		lines.append(line)
	if not result["made_the_list"]:
		lines.append("")
		lines.append("(this run didn't crack the top %d)" % Leaderboard.MAX_ENTRIES)
	leaderboard_list.text = "\n".join(lines)


func _on_restart_pressed() -> void:
	GameState.reset()
	# In case death happened mid-flight (tree paused for the ascent
	# sequence), make sure restarting doesn't leave the world frozen.
	get_tree().paused = false
	get_tree().reload_current_scene()

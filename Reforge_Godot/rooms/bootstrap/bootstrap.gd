extends Node2D


func _ready() -> void:
	print("%s bootstrap ready. Energy: %d/%d" % [tr("GAME_TITLE"), RunData.energy, RunData.max_energy])

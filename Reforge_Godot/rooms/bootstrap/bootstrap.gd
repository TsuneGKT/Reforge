extends Node2D

@onready var altar: Node = $Altar

var living_enemies: Array[Node] = []
var room_rewards_unlocked := false


func _ready() -> void:
	RunData.reset_run()
	EventBus.enemy_died.connect(_on_enemy_died)
	_collect_living_enemies()
	altar.disable()
	print("%s bootstrap ready. Energy: %d/%d" % [tr("GAME_TITLE"), RunData.energy, RunData.max_energy])


func _collect_living_enemies() -> void:
	living_enemies.clear()

	for child in get_children():
		if child is RustHound and not child.is_dead:
			living_enemies.append(child)


func _on_enemy_died(enemy: Node) -> void:
	if room_rewards_unlocked:
		return
	if enemy in living_enemies:
		living_enemies.erase(enemy)

	if living_enemies.is_empty():
		_unlock_room_rewards()


func _unlock_room_rewards() -> void:
	room_rewards_unlocked = true
	EventBus.emit_all_enemies_cleared()
	altar.enable()
	print("Room cleared. Crystallization point and altar available.")

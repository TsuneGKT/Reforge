extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")

var player: Player
var elapsed_time: float = 0.0
var step := 0
var attack_started_count := 0
var dodge_started_count := 0
var parry_started_count := 0
var parry_failed_count := 0


func _ready() -> void:
	EventBus.attack_started.connect(_on_attack_started)
	EventBus.dodge_started.connect(_on_dodge_started)
	EventBus.parry_started.connect(_on_parry_started)
	EventBus.parry_failed.connect(_on_parry_failed)

	player = PLAYER_SCENE.instantiate()
	add_child(player)


func _physics_process(delta: float) -> void:
	elapsed_time += delta

	if step == 0:
		step = 1
		player.state_machine.change_state(player.attack_state)
		return

	if step == 1 and elapsed_time > 0.03:
		_assert_equal("attack_started", 1, attack_started_count)
		step = 2
		player.state_machine.change_state(player.dodge_state)
		return

	if step == 2 and elapsed_time > 0.06:
		_assert_equal("dodge_started", 1, dodge_started_count)
		step = 3
		player.state_machine.change_state(player.parry_state)
		return

	if step == 3 and elapsed_time > player.stats.parry_window_duration + 0.12:
		_assert_equal("parry_started", 1, parry_started_count)
		_assert_equal("parry_failed", 1, parry_failed_count)
		print("TEST player feedback events ok")
		get_tree().quit()


func _on_attack_started() -> void:
	attack_started_count += 1


func _on_dodge_started() -> void:
	dodge_started_count += 1


func _on_parry_started() -> void:
	parry_started_count += 1


func _on_parry_failed() -> void:
	parry_failed_count += 1


func _assert_equal(label: String, expected: int, actual: int) -> void:
	if actual != expected:
		push_error("TEST feedback event failed. %s expected=%s actual=%s" % [label, expected, actual])
		get_tree().quit(1)

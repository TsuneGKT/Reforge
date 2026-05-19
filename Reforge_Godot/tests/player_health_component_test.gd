extends Node2D

var player: Player
var hit_events: Array[int] = []
var died_events := 0
var event_order: Array[String] = []


func _ready() -> void:
	EventBus.player_hit.connect(_on_player_hit)
	EventBus.player_died.connect(_on_player_died)

	player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame

	_test_damage()
	_test_invincible_blocks_damage()
	_test_death()
	get_tree().quit()


func _test_damage() -> void:
	if not player.receive_damage(25):
		_fail("Player should receive damage.")
		return
	if player.health_component.current_health != 75:
		_fail("Expected HP 75, got %d." % player.health_component.current_health)
		return
	if hit_events != [25]:
		_fail("Expected one player_hit event, got %s." % hit_events)
		return
	print("TEST player damage ok")


func _test_invincible_blocks_damage() -> void:
	player.set_invincible(true)
	if player.receive_damage(25):
		_fail("Player should not receive damage while invincible.")
		return
	player.set_invincible(false)
	if player.health_component.current_health != 75:
		_fail("Expected HP to stay 75, got %d." % player.health_component.current_health)
		return
	print("TEST player invincible damage block ok")


func _test_death() -> void:
	if not player.receive_damage(75):
		_fail("Player should receive lethal damage.")
		return
	if player.health_component.current_health != 0:
		_fail("Expected HP 0, got %d." % player.health_component.current_health)
		return
	if died_events != 1:
		_fail("Expected one player_died event, got %d." % died_events)
		return
	if event_order.slice(event_order.size() - 2) != ["hit", "died"]:
		_fail("Expected hit before died, got order %s." % event_order)
		return
	print("TEST player death event ok")


func _fail(message: String) -> void:
	push_error("TEST player health failed. %s" % message)
	get_tree().quit(1)


func _on_player_hit(damage: int) -> void:
	hit_events.append(damage)
	event_order.append("hit")


func _on_player_died() -> void:
	died_events += 1
	event_order.append("died")

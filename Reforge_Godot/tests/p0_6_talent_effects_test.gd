extends Node

class TestTarget:
	extends Node

	var damage_taken := 0


	func take_damage(amount: int) -> void:
		damage_taken += amount


const TALENT_SYSTEM_SCRIPT: Script = preload("res://systems/talent_system.gd")
const OVERCLOCK_SYSTEM_SCRIPT: Script = preload("res://systems/overclock_system.gd")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const CRACK_SLASH: Resource = preload("res://data/talents/crack_slash.tres")
const GUARD_MOMENTUM: Resource = preload("res://data/talents/guard_momentum.tres")
const RESIDUAL_BACKFLOW: Resource = preload("res://data/talents/residual_backflow.tres")

var talent_system: Node
var overclock_system: Node


func _ready() -> void:
	talent_system = Node.new()
	talent_system.name = "TalentSystem"
	talent_system.set_script(TALENT_SYSTEM_SCRIPT)
	add_child(talent_system)

	overclock_system = Node.new()
	overclock_system.name = "OverclockSystem"
	overclock_system.set_script(OVERCLOCK_SYSTEM_SCRIPT)
	add_child(overclock_system)
	await get_tree().process_frame

	_test_crack_slash()
	_test_guard_momentum()
	await _test_guard_momentum_with_player_damage()
	_test_residual_backflow()

	print("TEST P0-6 talent effects ok")
	get_tree().quit()


func _test_crack_slash() -> void:
	RunData.reset_run()
	RunData.add_talent(CRACK_SLASH)

	var target := TestTarget.new()
	add_child(target)

	EventBus.emit_attack_hit_target(target, 10)
	if talent_system.get_crack_stacks(target) != 1 or target.damage_taken != 0:
		_fail("Expected first Crack Slash hit to add 1 stack only.")
		return

	EventBus.emit_attack_hit_target(target, 10)
	if talent_system.get_crack_stacks(target) != 2 or target.damage_taken != 0:
		_fail("Expected second Crack Slash hit to add 2 stacks only.")
		return

	EventBus.emit_attack_hit_target(target, 10)
	if talent_system.get_crack_stacks(target) != 0:
		_fail("Expected Crack Slash burst to clear stacks.")
		return
	if target.damage_taken != 10:
		_fail("Expected Crack Slash burst to deal 10 extra damage, got %d." % target.damage_taken)
		return

	target.queue_free()


func _test_guard_momentum() -> void:
	RunData.reset_run()
	RunData.add_talent(GUARD_MOMENTUM)

	EventBus.emit_parry_succeeded(false)
	if talent_system.get_guard_momentum_stacks() != 0:
		_fail("Expected normal parry not to grant Guard Momentum.")
		return

	EventBus.emit_parry_succeeded(true)
	if talent_system.get_guard_momentum_stacks() != 1:
		_fail("Expected perfect parry to grant 1 Guard Momentum.")
		return

	var damage_context := {"amount": 8}
	EventBus.emit_player_damage_incoming(damage_context)
	if damage_context["amount"] != 5:
		_fail("Expected Guard Momentum to reduce 8 damage to 5, got %s." % damage_context["amount"])
		return
	if talent_system.get_guard_momentum_stacks() != 0:
		_fail("Expected Guard Momentum to be consumed after reducing damage.")
		return

	damage_context = {"amount": 8}
	EventBus.emit_player_damage_incoming(damage_context)
	if damage_context["amount"] != 8:
		_fail("Expected no Guard Momentum reduction after stack is consumed.")
		return


func _test_guard_momentum_with_player_damage() -> void:
	RunData.reset_run()
	RunData.add_talent(GUARD_MOMENTUM)

	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	await get_tree().process_frame

	EventBus.emit_parry_succeeded(true)
	if talent_system.get_guard_momentum_stacks() != 1:
		_fail("Expected perfect parry to grant Guard Momentum before player damage test.")
		return

	if not player.receive_damage(8):
		_fail("Expected player to receive reduced damage.")
		return
	if player.health_component.current_health != 95:
		_fail("Expected Guard Momentum to reduce player HP loss to 5, got HP %d." % player.health_component.current_health)
		return

	player.queue_free()
	await get_tree().process_frame


func _test_residual_backflow() -> void:
	RunData.reset_run()
	RunData.add_talent(RESIDUAL_BACKFLOW)
	RunData.add_energy(10)

	EventBus.emit_overclock_action_triggered(&"dodge", 8)
	if RunData.energy != 10:
		_fail("Expected Residual Backflow not to trigger on dodge.")
		return

	EventBus.emit_overclock_action_requested(&"attack")
	EventBus.emit_attack_landed(10)
	if RunData.energy != 8:
		_fail("Expected overclock attack to consume 3 then refund 1, got %d." % RunData.energy)
		return

	RunData.reset_run()
	RunData.add_energy(10)
	EventBus.emit_overclock_action_requested(&"attack")
	EventBus.emit_attack_landed(10)
	if RunData.energy != 7:
		_fail("Expected no Residual Backflow when talent is not acquired.")
		return


func _fail(message: String) -> void:
	push_error("TEST P0-6 talent effects failed. %s" % message)
	get_tree().quit(1)

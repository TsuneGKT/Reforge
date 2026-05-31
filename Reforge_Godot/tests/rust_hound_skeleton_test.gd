extends Node2D


func _ready() -> void:
	var rust_hound: Node = preload("res://entities/enemies/rust_hound/rust_hound.tscn").instantiate()
	add_child(rust_hound)
	await get_tree().process_frame

	if rust_hound.data.max_health != 40:
		_fail("Expected rust hound max health 40.")
		return
	if rust_hound.data.attack_damage != 8:
		_fail("Expected rust hound attack damage 8.")
		return
	if not is_equal_approx(rust_hound.data.parry_window_duration, 0.27):
		_fail("Expected rust hound parry window duration 0.27.")
		return

	if rust_hound.collision_layer != 4:
		_fail("Expected rust hound body on EnemyBodyHurtbox layer 4, got %d." % rust_hound.collision_layer)
		return
	if rust_hound.attack_hitbox.collision_layer != 16:
		_fail("Expected attack hitbox on EnemyHitbox layer 16, got %d." % rust_hound.attack_hitbox.collision_layer)
		return
	if rust_hound.attack_hitbox.collision_mask != 2:
		_fail("Expected attack hitbox mask PlayerBody layer 2, got %d." % rust_hound.attack_hitbox.collision_mask)
		return
	if not rust_hound.attack_hitbox.is_in_group("parryable_hitbox"):
		_fail("Expected attack hitbox in parryable_hitbox group.")
		return

	if rust_hound.health_component.current_health != 40:
		_fail("Expected rust hound current health 40, got %d." % rust_hound.health_component.current_health)
		return
	rust_hound.take_damage(10)
	if rust_hound.health_component.current_health != 30:
		_fail("Expected rust hound health 30 after damage, got %d." % rust_hound.health_component.current_health)
		return

	if rust_hound.attack_hitbox.monitoring:
		_fail("Expected attack hitbox disabled by default.")
		return
	if rust_hound.state_machine.current_state.name != "IdleState":
		_fail("Expected initial state IdleState, got %s." % rust_hound.state_machine.current_state.name)
		return

	rust_hound.set_attack_hitbox_enabled(true)
	if not rust_hound.attack_hitbox.monitoring or rust_hound.attack_collision_shape.disabled:
		_fail("Expected attack hitbox enabled.")
		return
	rust_hound.on_parried(true)
	if rust_hound.attack_hitbox.monitoring or not rust_hound.attack_collision_shape.disabled:
		_fail("Expected parry hook to disable attack hitbox.")
		return
	if rust_hound.state_machine.current_state.name != "ParriedStunState":
		_fail("Expected parry hook to enter ParriedStunState, got %s." % rust_hound.state_machine.current_state.name)
		return

	print("TEST rust hound skeleton ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST rust hound skeleton failed. %s" % message)
	get_tree().quit(1)

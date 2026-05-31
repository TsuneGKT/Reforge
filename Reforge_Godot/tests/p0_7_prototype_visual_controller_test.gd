extends Node2D

const VISUAL_CONTROLLER_SCRIPT: Script = preload("res://components/prototype_visual/prototype_visual_controller.gd")


func _ready() -> void:
	var visual := Node2D.new()
	visual.name = "PrototypeVisualController"
	visual.set_script(VISUAL_CONTROLLER_SCRIPT)
	add_child(visual)
	await get_tree().process_frame

	_assert_node(visual, "BodyRoot/HeadShape")
	_assert_node(visual, "BodyRoot/TorsoLine")
	_assert_node(visual, "BodyRoot/LeftArmLine")
	_assert_node(visual, "BodyRoot/RightArmLine")
	_assert_node(visual, "BodyRoot/LeftLegLine")
	_assert_node(visual, "BodyRoot/RightLegLine")
	_assert_node(visual, "WeaponPivot/WeaponLine")
	_assert_node(visual, "WeaponPivot/AttackArc")
	_assert_node(visual, "WeaponPivot/ParryArc")
	_assert_node(visual, "EffectRoot/FlashOverlay")

	visual.play_attack_start(Vector2.RIGHT)
	if not is_equal_approx(visual.facing_direction.x, 1.0):
		_fail("Expected visual to face right after attack start.")

	visual.show_attack_arc(Vector2.RIGHT)
	if not visual.get_node("WeaponPivot/AttackArc").visible:
		_fail("Expected AttackArc visible during attack active pose.")

	visual.hide_attack_arc()
	if visual.get_node("WeaponPivot/AttackArc").visible:
		_fail("Expected AttackArc hidden after hide_attack_arc().")

	visual.show_parry_arc(Vector2.DOWN)
	if not visual.get_node("WeaponPivot/ParryArc").visible:
		_fail("Expected ParryArc visible during parry pose.")

	visual.play_hurt_flash()
	if not visual.get_node("EffectRoot/FlashOverlay").visible:
		_fail("Expected FlashOverlay visible during hurt flash.")

	await get_tree().create_timer(0.2).timeout
	if visual.get_node("EffectRoot/FlashOverlay").visible:
		_fail("Expected FlashOverlay hidden after flash tween.")

	print("TEST P0-7 prototype visual controller ok")
	get_tree().quit()


func _assert_node(root: Node, node_path: String) -> void:
	if root.get_node_or_null(node_path) == null:
		_fail("Expected node %s." % node_path)


func _fail(message: String) -> void:
	push_error("TEST P0-7 prototype visual controller failed. %s" % message)
	get_tree().quit(1)

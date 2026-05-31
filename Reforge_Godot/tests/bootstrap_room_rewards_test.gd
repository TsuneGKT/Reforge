extends Node

const BOOTSTRAP_SCENE: PackedScene = preload("res://rooms/bootstrap/bootstrap.tscn")

const ALTAR_STATE_AVAILABLE := &"available"
const ALTAR_STATE_DISABLED := &"disabled"
const POINT_STATE_AVAILABLE := &"available"
const POINT_STATE_DISABLED := &"disabled"


func _ready() -> void:
	var room: Node = BOOTSTRAP_SCENE.instantiate()
	add_child(room)
	await get_tree().process_frame

	var rust_hound: Node = room.get_node("RustHound")
	var crystallization_point: Node = room.get_node("CrystallizationPoint")
	var altar: Node = room.get_node("Altar")

	if crystallization_point.state != POINT_STATE_DISABLED or crystallization_point.visible:
		_fail("Expected crystallization point to start hidden and disabled.")
		return
	if altar.state != ALTAR_STATE_DISABLED or altar.visible:
		_fail("Expected altar to start hidden and disabled in bootstrap room.")
		return

	rust_hound.take_damage(999)
	await get_tree().process_frame

	if crystallization_point.state != POINT_STATE_AVAILABLE or not crystallization_point.visible:
		_fail("Expected crystallization point to appear after all enemies cleared.")
		return
	if altar.state != ALTAR_STATE_AVAILABLE or not altar.visible:
		_fail("Expected altar to appear after all enemies cleared.")
		return

	print("TEST bootstrap room rewards ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST bootstrap room rewards failed. %s" % message)
	get_tree().quit(1)

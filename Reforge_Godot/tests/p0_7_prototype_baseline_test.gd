extends Node

const BOOTSTRAP_SCENE: PackedScene = preload("res://rooms/bootstrap/bootstrap.tscn")


func _ready() -> void:
	await _test_project_viewport_baseline()
	await _test_bootstrap_prototype_baseline()

	print("TEST P0-7 prototype baseline ok")
	get_tree().quit()


func _test_project_viewport_baseline() -> void:
	var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

	if viewport_width != 640 or viewport_height != 360:
		_fail("Expected 640x360 viewport, got %dx%d." % [viewport_width, viewport_height])


func _test_bootstrap_prototype_baseline() -> void:
	var bootstrap := BOOTSTRAP_SCENE.instantiate()

	if not bootstrap.y_sort_enabled:
		_fail("Expected Bootstrap root to enable Y sorting.")

	var floor: Polygon2D = bootstrap.get_node("PrototypeFloor")
	if floor.position != Vector2(320, 180):
		_fail("Expected PrototypeFloor centered at 320,180.")
	if _get_polygon_size(floor.polygon) != Vector2(704, 416):
		_fail("Expected PrototypeFloor to be 44x26 tiles, got %s." % [_get_polygon_size(floor.polygon)])

	var player: Node2D = bootstrap.get_node("Player")
	var rust_hound: Node2D = bootstrap.get_node("RustHound")
	var crystallization_point: Node2D = bootstrap.get_node("CrystallizationPoint")
	var altar: Node2D = bootstrap.get_node("Altar")

	if player.position != Vector2(320, 180):
		_fail("Expected Player at room center.")
	if rust_hound.position != Vector2(320, 260):
		_fail("Expected RustHound below Player for first combat check.")
	if crystallization_point.position != Vector2(240, 180):
		_fail("Expected CrystallizationPoint left of Player.")
	if altar.position != Vector2(400, 180):
		_fail("Expected Altar right of Player.")

	add_child(bootstrap)
	await get_tree().process_frame

	var camera: Camera2D = bootstrap.get_node("Camera2D")
	if camera.position != Vector2(320, 180) or not camera.is_current():
		_fail("Expected Camera2D centered and current.")
	if bootstrap.get_node_or_null("FeedbackSystem") == null:
		_fail("Expected FeedbackSystem in Bootstrap.")
	if bootstrap.get_node_or_null("HitStopController") == null:
		_fail("Expected HitStopController in Bootstrap.")
	if bootstrap.get_node_or_null("ScreenShakeController") == null:
		_fail("Expected ScreenShakeController in Bootstrap.")

	bootstrap.queue_free()
	await get_tree().process_frame


func _get_polygon_size(points: PackedVector2Array) -> Vector2:
	var min_point := Vector2(INF, INF)
	var max_point := Vector2(-INF, -INF)
	for point in points:
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)

	return max_point - min_point


func _fail(message: String) -> void:
	push_error("TEST P0-7 prototype baseline failed. %s" % message)
	get_tree().quit(1)

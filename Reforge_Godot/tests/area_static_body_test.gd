extends Node2D


func _ready() -> void:
	var area := Area2D.new()
	var area_shape := CollisionShape2D.new()
	var area_rect := RectangleShape2D.new()
	area_rect.size = Vector2(40, 40)
	area_shape.shape = area_rect
	area.collision_layer = 8
	area.collision_mask = 4
	area.add_child(area_shape)
	add_child(area)

	var body := StaticBody2D.new()
	var body_shape := CollisionShape2D.new()
	var body_rect := RectangleShape2D.new()
	body_rect.size = Vector2(32, 32)
	body_shape.shape = body_rect
	body.collision_layer = 4
	body.collision_mask = 0
	body.add_child(body_shape)
	add_child(body)

	area.global_position = Vector2(100, 100)
	body.global_position = Vector2(100, 100)

	await get_tree().physics_frame
	await get_tree().physics_frame
	print("MINI overlaps count=", area.get_overlapping_bodies().size(), " names=", area.get_overlapping_bodies())
	get_tree().quit()

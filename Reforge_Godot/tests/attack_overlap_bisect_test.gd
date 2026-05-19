extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const TARGET_DUMMY_SCENE: PackedScene = preload("res://entities/enemies/target_dummy.tscn")


func _ready() -> void:
	await _test_actual_player_manual_body()
	await _test_manual_area_actual_dummy()
	get_tree().quit()


func _test_actual_player_manual_body() -> void:
	var player: Node = PLAYER_SCENE.instantiate()
	var body := StaticBody2D.new()
	var body_shape := CollisionShape2D.new()
	var body_rect := RectangleShape2D.new()
	body_rect.size = Vector2(32, 32)
	body_shape.shape = body_rect
	body.collision_layer = 4
	body.add_child(body_shape)

	add_child(player)
	add_child(body)
	player.global_position = Vector2(100, 100)
	body.global_position = Vector2(100, 128)

	await get_tree().physics_frame
	await get_tree().physics_frame
	print("BISECT actual_player/manual_body overlaps=", player.attack_area.get_overlapping_bodies().size(), " bodies=", player.attack_area.get_overlapping_bodies())

	player.queue_free()
	body.queue_free()
	await get_tree().physics_frame


func _test_manual_area_actual_dummy() -> void:
	var area := Area2D.new()
	var area_shape := CollisionShape2D.new()
	var area_rect := RectangleShape2D.new()
	area_rect.size = Vector2(36, 28)
	area_shape.shape = area_rect
	area.collision_layer = 8
	area.collision_mask = 4
	area.add_child(area_shape)

	var dummy: Node = TARGET_DUMMY_SCENE.instantiate()
	add_child(area)
	add_child(dummy)
	area.global_position = Vector2(100, 128)
	dummy.global_position = Vector2(100, 128)

	await get_tree().physics_frame
	await get_tree().physics_frame
	print("BISECT manual_area/actual_dummy overlaps=", area.get_overlapping_bodies().size(), " bodies=", area.get_overlapping_bodies())

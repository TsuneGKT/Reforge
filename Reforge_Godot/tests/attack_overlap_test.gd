extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const TARGET_DUMMY_SCENE: PackedScene = preload("res://entities/enemies/target_dummy.tscn")

var player: Node
var target_dummy: Node


func _ready() -> void:
	player = PLAYER_SCENE.instantiate()
	target_dummy = TARGET_DUMMY_SCENE.instantiate()
	add_child(player)
	add_child(target_dummy)

	player.global_position = Vector2(100, 100)
	target_dummy.global_position = Vector2(100, 128)

	await get_tree().physics_frame
	await get_tree().physics_frame

	print("TEST player script=", player.get_script())
	print("TEST dummy script=", target_dummy.get_script(), " has_take_damage=", target_dummy.has_method("take_damage"))
	print("TEST attack_area global=", player.attack_area.global_position, " dummy=", target_dummy.global_position)
	print("TEST attack_area layer=", player.attack_area.collision_layer, " mask=", player.attack_area.collision_mask)
	print("TEST dummy layer=", target_dummy.collision_layer)
	print("TEST attack shape disabled=", player.attack_collision_shape.disabled, " shape=", player.attack_collision_shape.shape, " global=", player.attack_collision_shape.global_position)
	print("TEST dummy shape disabled=", target_dummy.get_node("CollisionShape2D").disabled, " shape=", target_dummy.get_node("CollisionShape2D").shape, " global=", target_dummy.get_node("CollisionShape2D").global_position)

	player.set_attack_area_enabled(true)
	await get_tree().physics_frame
	await get_tree().physics_frame

	var bodies: Array[Node2D] = player.attack_area.get_overlapping_bodies()
	print("TEST overlaps count=", bodies.size(), " names=", bodies.map(func(body: Node) -> String: return body.name))

	player.resolve_attack_overlaps()
	await get_tree().physics_frame

	var health_component: Node = target_dummy.get_node("HealthComponent")
	print("TEST dummy health=", health_component.current_health)
	get_tree().quit()

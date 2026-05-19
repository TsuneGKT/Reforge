class_name TestParryableHitbox
extends Area2D

var is_parryable := true
var was_parried := false
var last_is_perfect := false


func _ready() -> void:
	collision_layer = 16
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32, 32)
	shape.shape = rect
	add_child(shape)


func on_parried(is_perfect: bool) -> void:
	was_parried = true
	last_is_perfect = is_perfect

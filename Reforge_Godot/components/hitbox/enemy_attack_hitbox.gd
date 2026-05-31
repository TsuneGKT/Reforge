class_name EnemyAttackHitbox
extends Area2D

@export var damage: int = 1
@export var is_parryable := true

var owner_enemy: Node


func _ready() -> void:
	if owner_enemy == null:
		owner_enemy = get_parent()
	add_to_group("parryable_hitbox")


func on_parried(is_perfect: bool) -> void:
	if owner_enemy != null and owner_enemy.has_method("on_parried"):
		owner_enemy.on_parried(is_perfect)

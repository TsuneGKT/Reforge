class_name TargetDummy
extends StaticBody2D

@onready var health_component: Node = $HealthComponent
@onready var body_sprite: ColorRect = $BodySprite


func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)


func take_damage(amount: int) -> void:
	health_component.take_damage(amount)


func _on_health_changed(current_health: int, max_health: int) -> void:
	var health_ratio := float(current_health) / float(max_health)
	body_sprite.color = Color(1.0, 0.25 + health_ratio * 0.45, 0.25, 1.0)


func _on_died() -> void:
	queue_free()

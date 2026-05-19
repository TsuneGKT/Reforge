class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 1

var current_health: int


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func initialize(new_max_health: int) -> void:
	max_health = new_max_health
	current_health = max_health
	health_changed.emit(current_health, max_health)


func take_damage(amount: int) -> bool:
	if amount <= 0 or current_health <= 0:
		return false

	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)

	if current_health == 0:
		died.emit()

	return true

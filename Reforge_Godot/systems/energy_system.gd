class_name EnergySystem
extends Node

@export var balance: BalanceData = preload("res://data/balance/default_balance.tres")


func _ready() -> void:
	EventBus.parry_succeeded.connect(_on_parry_succeeded)


func _on_parry_succeeded(is_perfect: bool) -> void:
	var amount := balance.perfect_parry_energy if is_perfect else balance.normal_parry_energy
	RunData.add_energy(amount)

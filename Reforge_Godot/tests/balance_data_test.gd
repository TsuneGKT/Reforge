extends Node


func _ready() -> void:
	var balance: Resource = preload("res://data/balance/default_balance.tres")
	if balance.perfect_parry_energy != 12:
		_fail("Expected perfect parry energy 12.")
		return
	if balance.normal_parry_energy != 6:
		_fail("Expected normal parry energy 6.")
		return
	if balance.overclock_attack_cost != 3:
		_fail("Expected overclock attack cost 3.")
		return
	if balance.overclock_dodge_cost != 8:
		_fail("Expected overclock dodge cost 8.")
		return
	if balance.overclock_parry_cost != 15:
		_fail("Expected overclock parry cost 15.")
		return
	if balance.light_core_energy_ratio != 100.0:
		_fail("Expected light core energy ratio 100.")
		return

	print("TEST BalanceData defaults ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST BalanceData failed. %s" % message)
	get_tree().quit(1)

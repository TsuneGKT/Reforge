extends Node

const CRACK_SLASH: Resource = preload("res://data/talents/crack_slash.tres")
const GUARD_MOMENTUM: Resource = preload("res://data/talents/guard_momentum.tres")
const RESIDUAL_BACKFLOW: Resource = preload("res://data/talents/residual_backflow.tres")


func _ready() -> void:
	_assert_talent(
		CRACK_SLASH,
		&"talent_crack_slash",
		&"TALENT_CRACK_SLASH_NAME",
		&"attack",
		&"crack_on_attack",
		3.0,
		10.0,
		[&"crack"]
	)
	_assert_talent(
		GUARD_MOMENTUM,
		&"talent_guard_momentum",
		&"TALENT_GUARD_MOMENTUM_NAME",
		&"parry",
		&"guard_on_perfect_parry",
		1.0,
		3.0,
		[&"guard_momentum"]
	)
	_assert_talent(
		RESIDUAL_BACKFLOW,
		&"talent_residual_backflow",
		&"TALENT_RESIDUAL_BACKFLOW_NAME",
		&"overclock",
		&"backflow_on_overclock_attack_hit",
		1.0,
		0.0,
		[&"backflow"]
	)

	RunData.reset_run()
	RunData.add_talent(CRACK_SLASH)
	if RunData.acquired_talents != [CRACK_SLASH]:
		_fail("Expected RunData to record acquired talent.")
		return
	RunData.reset_run()
	if not RunData.acquired_talents.is_empty():
		_fail("Expected RunData.reset_run to clear acquired talents.")
		return

	print("TEST P0-6 TalentData resources ok")
	get_tree().quit()


func _assert_talent(
	talent: Resource,
	expected_id: StringName,
	expected_name_key: StringName,
	expected_primary_archetype: StringName,
	expected_effect_type: StringName,
	expected_effect_value: float,
	expected_effect_extra_value: float,
	expected_keywords: Array[StringName]
) -> void:
	if talent == null:
		_fail("Expected TalentData resource to load.")
		return
	if talent.id != expected_id:
		_fail("Expected id %s, got %s." % [expected_id, talent.id])
		return
	if talent.name_key != expected_name_key or talent.description_key == &"":
		_fail("Expected localization keys for %s." % expected_id)
		return
	if talent.tier != 1:
		_fail("Expected tier 1 for %s." % expected_id)
		return
	if talent.primary_archetype != expected_primary_archetype:
		_fail("Expected primary archetype %s for %s." % [expected_primary_archetype, expected_id])
		return
	if talent.effect_type != expected_effect_type:
		_fail("Expected effect type %s for %s." % [expected_effect_type, expected_id])
		return
	if not is_equal_approx(talent.effect_value, expected_effect_value):
		_fail("Expected effect value %s for %s." % [expected_effect_value, expected_id])
		return
	if not is_equal_approx(talent.effect_extra_value, expected_effect_extra_value):
		_fail("Expected effect extra value %s for %s." % [expected_effect_extra_value, expected_id])
		return
	if talent.keywords != expected_keywords:
		_fail("Expected keywords %s for %s, got %s." % [expected_keywords, expected_id, talent.keywords])
		return


func _fail(message: String) -> void:
	push_error("TEST P0-6 TalentData resources failed. %s" % message)
	get_tree().quit(1)

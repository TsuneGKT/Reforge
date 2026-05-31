class_name TalentData
extends Resource

@export var id: StringName = &""
@export var name_key: StringName = &""
@export var description_key: StringName = &""
@export var tier: int = 1
@export var primary_archetype: StringName = &""
@export var secondary_archetype: StringName = &""
@export var keywords: Array[StringName] = []
@export var effect_type: StringName = &""
@export var effect_value: float = 0.0
@export var effect_extra_value: float = 0.0
@export var icon: Texture2D

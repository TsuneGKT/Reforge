class_name LightCoreHUD
extends CanvasLayer

@onready var light_core_bar: ProgressBar = $Panel/LightCoreBar
@onready var light_core_label: Label = $Panel/LightCoreLabel


func _ready() -> void:
	EventBus.light_core_changed.connect(_on_light_core_changed)
	_on_light_core_changed(RunData.light_core_progress + float(RunData.light_cores), float(RunData.max_light_cores))


func _on_light_core_changed(current: float, max_cores: float) -> void:
	light_core_bar.max_value = max_cores
	light_core_bar.value = current

	if current >= max_cores and max_cores > 0.0:
		light_core_label.text = "Light Core %.0f/%.0f Full" % [current, max_cores]
	else:
		light_core_label.text = "Light Core %.2f/%.0f" % [current, max_cores]

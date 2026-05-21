class_name EnergyHUD
extends CanvasLayer

@export var player_path: NodePath = NodePath("../Player")

@onready var health_bar: ProgressBar = $Panel/HealthBar
@onready var health_label: Label = $Panel/HealthLabel
@onready var energy_bar: ProgressBar = $Panel/EnergyBar
@onready var energy_label: Label = $Panel/EnergyLabel


func _ready() -> void:
	_bind_player_health()
	EventBus.energy_changed.connect(_on_energy_changed)
	_on_energy_changed(RunData.energy, RunData.max_energy)


func _bind_player_health() -> void:
	var player := get_node_or_null(player_path)
	if player == null:
		_on_health_changed(0, 0)
		return

	var health_component: HealthComponent = player.get_node_or_null("HealthComponent")
	if health_component == null:
		_on_health_changed(0, 0)
		return

	health_component.health_changed.connect(_on_health_changed)
	_on_health_changed(health_component.current_health, health_component.max_health)


func _on_health_changed(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current
	health_label.text = "Health %d/%d" % [current, max_health]


func _on_energy_changed(current: int, max_energy: int) -> void:
	energy_bar.max_value = max_energy
	energy_bar.value = current
	energy_label.text = "Energy %d/%d" % [current, max_energy]

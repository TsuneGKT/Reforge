class_name Altar
extends Area2D

const STATE_AVAILABLE := &"available"
const STATE_USED := &"used"
const STATE_BLOCKED := &"blocked"
const STATE_DISABLED := &"disabled"

@onready var body_sprite: ColorRect = $BodySprite
@onready var prompt_label: Label = $PromptLabel
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var state: StringName = STATE_AVAILABLE
var player_in_range := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_state(STATE_AVAILABLE)


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()


func interact() -> bool:
	if not _can_interact():
		return false

	if RunData.spend_light_core():
		EventBus.emit_altar_activated()
		EventBus.emit_talent_selection_requested()
		set_state(STATE_USED)
		return true

	EventBus.emit_altar_failed(&"not_enough_light_core")
	set_state(STATE_BLOCKED)
	return false


func enable() -> void:
	if state == STATE_USED:
		return

	set_state(STATE_AVAILABLE)


func disable() -> void:
	if state == STATE_USED:
		return

	set_state(STATE_DISABLED)


func set_state(next_state: StringName) -> void:
	state = next_state
	match state:
		STATE_DISABLED:
			visible = false
			monitoring = false
			collision_shape.disabled = true
			body_sprite.color = Color(0.2, 0.2, 0.2, 0.5)
		STATE_AVAILABLE:
			visible = true
			monitoring = true
			collision_shape.disabled = false
			body_sprite.color = Color(0.95, 0.8, 0.35, 0.85)
		STATE_USED:
			visible = true
			monitoring = false
			collision_shape.disabled = true
			player_in_range = false
			body_sprite.color = Color(0.45, 0.4, 0.35, 0.55)
		STATE_BLOCKED:
			visible = true
			monitoring = true
			collision_shape.disabled = false
			body_sprite.color = Color(1.0, 0.35, 0.25, 0.85)

	_update_prompt()


func _can_interact() -> bool:
	return player_in_range and (state == STATE_AVAILABLE or state == STATE_BLOCKED)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_in_range = true
		_update_prompt()


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_in_range = false
		_update_prompt()


func _update_prompt() -> void:
	prompt_label.visible = _can_interact()
	prompt_label.text = "%s / %s" % [tr("UI_INTERACT"), tr("UI_ALTAR")]

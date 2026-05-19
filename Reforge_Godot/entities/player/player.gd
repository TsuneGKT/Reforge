class_name Player
extends CharacterBody2D

@export var stats: PlayerStats = preload("res://data/player/default_player_stats.tres")

@onready var direction_marker: Polygon2D = $DirectionMarker
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_preview: Polygon2D = $AttackArea/AttackPreview
@onready var parry_area: Area2D = $ParryArea
@onready var parry_collision_shape: CollisionShape2D = $ParryArea/CollisionShape2D
@onready var parry_preview: Polygon2D = $ParryArea/ParryPreview
@onready var state_machine: StateMachine = $StateMachine
@onready var idle_state: Node = $StateMachine/IdleState
@onready var move_state: Node = $StateMachine/MoveState
@onready var attack_state: Node = $StateMachine/AttackState
@onready var parry_state: Node = $StateMachine/ParryState
@onready var dodge_state: Node = $StateMachine/DodgeState
@onready var stun_state: Node = $StateMachine/StunState
@onready var dead_state: Node = $StateMachine/DeadState
@onready var health_component: HealthComponent = $HealthComponent

var last_facing_direction: Vector2 = Vector2.DOWN
var hit_targets: Array[Node] = []
var parried_targets: Array[Node] = []
var is_attack_area_active := false
var is_parry_area_active := false
var is_invincible := false
var is_dodge_visual_active := false
var is_overclock_active := false


func _ready() -> void:
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	health_component.initialize(stats.max_health)
	set_attack_area_enabled(false)
	set_parry_area_enabled(false)
	_update_direction_marker()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("overclock"):
		toggle_overclock()


func get_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func move_in_direction(input_direction: Vector2) -> void:
	if input_direction != Vector2.ZERO:
		set_facing_direction(input_direction)

	velocity = input_direction * stats.move_speed
	move_and_slide()


func set_facing_direction(input_direction: Vector2) -> void:
	if input_direction == Vector2.ZERO:
		return

	last_facing_direction = input_direction.normalized()
	_update_direction_marker()


func _update_direction_marker() -> void:
	direction_marker.rotation = last_facing_direction.angle() + PI / 2.0
	attack_area.position = last_facing_direction * 28.0
	attack_area.rotation = last_facing_direction.angle() + PI / 2.0
	parry_area.position = last_facing_direction * 28.0
	parry_area.rotation = last_facing_direction.angle() + PI / 2.0


func set_attack_area_enabled(is_enabled: bool) -> void:
	if is_enabled:
		hit_targets.clear()
	is_attack_area_active = is_enabled
	attack_preview.visible = is_enabled


func set_parry_area_enabled(is_enabled: bool) -> void:
	if is_enabled:
		parried_targets.clear()
	is_parry_area_active = is_enabled
	parry_preview.visible = is_enabled


func set_dodge_visual_enabled(is_enabled: bool) -> void:
	is_dodge_visual_active = is_enabled
	_update_player_state_marker_color()


func set_invincible(is_enabled: bool) -> void:
	is_invincible = is_enabled
	_update_player_state_marker_color()


func can_receive_damage() -> bool:
	return not is_invincible and health_component.current_health > 0


func receive_damage(amount: int) -> bool:
	if not can_receive_damage():
		return false

	if not health_component.take_damage(amount):
		return false

	EventBus.emit_player_hit(amount)
	print("Player received damage: %d. HP: %d/%d" % [amount, health_component.current_health, health_component.max_health])
	if health_component.current_health <= 0:
		_enter_dead_state()
	else:
		state_machine.change_state(stun_state)
	return true


func toggle_overclock() -> bool:
	if not can_toggle_overclock():
		return false

	set_overclock_active(not is_overclock_active)
	return true


func set_overclock_active(is_active: bool) -> void:
	if is_overclock_active == is_active:
		return

	is_overclock_active = is_active
	EventBus.emit_overclock_toggled(is_overclock_active)
	print("Player overclock toggled: %s" % is_overclock_active)


func can_toggle_overclock() -> bool:
	if health_component.current_health <= 0:
		return false
	if state_machine.current_state == stun_state or state_machine.current_state == dead_state:
		return false

	return true


func resolve_parry_overlaps(is_perfect: bool) -> bool:
	if not is_parry_area_active:
		return false

	var did_parry := false
	for area in parry_area.get_overlapping_areas():
		if _try_parry_area(area, is_perfect):
			did_parry = true

	return did_parry


func _on_attack_area_body_entered(body: Node) -> void:
	_try_hit_body(body)


func resolve_attack_overlaps() -> void:
	if not is_attack_area_active:
		return

	var overlapping_bodies := attack_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		_try_hit_body(body)


func _try_hit_body(body: Node) -> void:
	if not is_attack_area_active:
		return
	if body in hit_targets:
		return
	if not body.has_method("take_damage"):
		return

	hit_targets.append(body)
	body.take_damage(stats.attack_damage)
	EventBus.emit_attack_landed(stats.attack_damage)
	print("Player attack landed: %d" % stats.attack_damage)


func _try_parry_area(area: Area2D, is_perfect: bool) -> bool:
	if not is_parry_area_active:
		return false
	if area in parried_targets:
		return false
	if not _is_parryable_hitbox(area):
		return false

	parried_targets.append(area)
	if area.has_method("on_parried"):
		area.on_parried(is_perfect)

	EventBus.emit_parry_succeeded(is_perfect)
	print("Player parry succeeded: perfect=%s" % is_perfect)
	return true


func _is_parryable_hitbox(area: Area2D) -> bool:
	if area.is_in_group("parryable_hitbox"):
		return true

	return area.get("is_parryable") == true


func _enter_dead_state() -> void:
	set_overclock_active(false)
	set_attack_area_enabled(false)
	set_parry_area_enabled(false)
	set_invincible(false)
	state_machine.change_state(dead_state)
	EventBus.emit_player_died()
	print("Player died")


func _update_player_state_marker_color() -> void:
	if is_invincible:
		direction_marker.color = Color(0.45, 1.0, 0.55, 1.0)
	elif is_dodge_visual_active:
		direction_marker.color = Color(0.35, 0.9, 0.9, 1.0)
	else:
		direction_marker.color = Color(0.25, 0.65, 1.0, 1.0)

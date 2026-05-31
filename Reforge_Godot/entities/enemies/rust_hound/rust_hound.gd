class_name RustHound
extends CharacterBody2D

@export var data: EnemyData = preload("res://data/enemies/rust_hound.tres")
@export var target_path: NodePath

@onready var body_sprite: ColorRect = $BodySprite
@onready var snout_marker: Polygon2D = $SnoutMarker
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_collision_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var attack_preview: ColorRect = $AttackHitbox/AttackPreview
@onready var state_machine: StateMachine = $StateMachine
@onready var idle_state: Node = $StateMachine/IdleState
@onready var chase_state: Node = $StateMachine/ChaseState
@onready var charge_state: Node = $StateMachine/ChargeState
@onready var lunge_state: Node = $StateMachine/LungeState
@onready var recovery_state: Node = $StateMachine/RecoveryState
@onready var parried_stun_state: Node = $StateMachine/ParriedStunState
@onready var dead_state: Node = $StateMachine/DeadState

var last_facing_direction: Vector2 = Vector2.DOWN
var locked_attack_direction: Vector2 = Vector2.DOWN
var parried_knockback_direction: Vector2 = Vector2.UP
var attack_cooldown_remaining: float = 0.0
var attack_hit_targets: Array[Node] = []
var target: Node2D
var is_dead := false
var feedback_tween: Tween


func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	attack_hitbox.owner_enemy = self
	attack_hitbox.damage = data.attack_damage
	health_component.initialize(data.max_health)
	set_attack_hitbox_enabled(false)
	_update_body_color(health_component.current_health, health_component.max_health)


func set_target(new_target: Node2D) -> void:
	target = new_target


func get_target() -> Node2D:
	if target != null and is_instance_valid(target):
		return target

	if not target_path.is_empty():
		target = get_node_or_null(target_path)
		if target != null:
			return target

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is Node2D:
		target = players[0]
		return target

	return null


func get_distance_to_target() -> float:
	var current_target := get_target()
	if current_target == null:
		return INF

	return global_position.distance_to(current_target.global_position)


func is_target_in_detection_range() -> bool:
	return get_distance_to_target() <= data.detection_range


func is_target_outside_disengage_range() -> bool:
	return get_distance_to_target() > data.disengage_range


func is_target_in_attack_range() -> bool:
	return get_distance_to_target() <= data.attack_range


func can_start_attack() -> bool:
	return attack_cooldown_remaining <= 0.0 and is_target_in_attack_range()


func tick_attack_cooldown(delta: float) -> void:
	if attack_cooldown_remaining > 0.0:
		attack_cooldown_remaining = maxf(attack_cooldown_remaining - delta, 0.0)


func reset_attack_cooldown() -> void:
	attack_cooldown_remaining = data.attack_interval


func get_direction_to_target() -> Vector2:
	var current_target := get_target()
	if current_target == null:
		return Vector2.ZERO

	return global_position.direction_to(current_target.global_position)


func lock_attack_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		direction = last_facing_direction

	locked_attack_direction = direction.normalized()
	set_facing_direction(locked_attack_direction)


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health_component.take_damage(amount)
	if not is_dead:
		play_hurt_feedback()


func set_attack_hitbox_enabled(is_enabled: bool) -> void:
	if is_enabled:
		attack_hit_targets.clear()

	var hitbox: Area2D = attack_hitbox if attack_hitbox != null else get_node_or_null("AttackHitbox")
	var hitbox_shape: CollisionShape2D = attack_collision_shape if attack_collision_shape != null else get_node_or_null("AttackHitbox/CollisionShape2D")
	var preview: ColorRect = attack_preview if attack_preview != null else get_node_or_null("AttackHitbox/AttackPreview")

	if hitbox != null:
		hitbox.monitoring = is_enabled
	if hitbox_shape != null:
		hitbox_shape.disabled = not is_enabled
	if preview != null:
		preview.visible = is_enabled


func resolve_attack_overlaps() -> void:
	if attack_hitbox == null or not attack_hitbox.monitoring:
		return

	for body in attack_hitbox.get_overlapping_bodies():
		_try_hit_body(body)


func _try_hit_body(body: Node) -> void:
	if body in attack_hit_targets:
		return
	if not body.has_method("receive_damage"):
		return

	attack_hit_targets.append(body)
	var did_hit: bool = body.receive_damage(data.attack_damage)
	if did_hit:
		print("RustHound hit player: %d" % data.attack_damage)


func set_facing_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	last_facing_direction = direction.normalized()
	attack_hitbox.position = last_facing_direction * 24.0
	attack_hitbox.rotation = last_facing_direction.angle() + PI / 2.0


func on_parried(_is_perfect: bool) -> void:
	if is_dead:
		return

	set_attack_hitbox_enabled(false)
	parried_knockback_direction = -locked_attack_direction
	if parried_knockback_direction == Vector2.ZERO:
		parried_knockback_direction = -last_facing_direction
	state_machine.change_state(parried_stun_state)


func _on_health_changed(current_health: int, max_health: int) -> void:
	_update_body_color(current_health, max_health)


func _on_died() -> void:
	if is_dead:
		return

	is_dead = true
	state_machine.change_state(dead_state)
	EventBus.emit_enemy_died(self)
	print("RustHound died")


func disable_combat_collisions() -> void:
	set_attack_hitbox_enabled(false)
	collision_layer = 0
	collision_mask = 0
	collision_shape.disabled = true


func play_hurt_feedback() -> void:
	_restart_feedback_tween()
	body_sprite.color = Color(1.0, 0.95, 0.75, 1.0)
	feedback_tween = create_tween()
	feedback_tween.tween_property(body_sprite, "color", _get_health_body_color(health_component.current_health, health_component.max_health), 0.12)


func play_parried_feedback() -> void:
	_restart_feedback_tween()
	body_sprite.color = Color(0.35, 0.8, 1.0, 1.0)


func play_death_feedback() -> void:
	_restart_feedback_tween()
	modulate = Color.WHITE
	body_sprite.color = Color(0.18, 0.18, 0.18, 1.0)
	feedback_tween = create_tween()
	feedback_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.18), 0.35)


func _restart_feedback_tween() -> void:
	if feedback_tween != null and feedback_tween.is_valid():
		feedback_tween.kill()
	feedback_tween = null


func _update_body_color(current_health: int, max_health: int) -> void:
	body_sprite.color = _get_health_body_color(current_health, max_health)


func _get_health_body_color(current_health: int, max_health: int) -> Color:
	var health_ratio := 0.0
	if max_health > 0:
		health_ratio = float(current_health) / float(max_health)
	return Color(0.45 + 0.25 * health_ratio, 0.25, 0.12, 1.0)

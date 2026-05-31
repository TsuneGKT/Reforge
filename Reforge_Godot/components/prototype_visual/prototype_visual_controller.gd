class_name PrototypeVisualController
extends Node2D

@export var base_color := Color(0.25, 0.65, 1.0, 1.0)
@export var accent_color := Color(1.0, 0.85, 0.18, 1.0)
@export var hurt_color := Color(1.0, 0.22, 0.18, 1.0)
@export var line_width := 3.0

var facing_direction := Vector2.DOWN
var flash_tween: Tween
var pulse_tween: Tween

var body_root: Node2D
var weapon_pivot: Node2D
var effect_root: Node2D
var torso_line: Line2D
var left_arm_line: Line2D
var right_arm_line: Line2D
var left_leg_line: Line2D
var right_leg_line: Line2D
var weapon_line: Line2D
var attack_arc: Line2D
var parry_arc: Line2D
var head_shape: Polygon2D
var flash_overlay: Polygon2D


func _ready() -> void:
	_ensure_structure()
	play_idle(facing_direction)


func play_idle(direction: Vector2 = facing_direction) -> void:
	set_facing_direction(direction)
	_set_default_pose()
	hide_attack_arc()
	hide_parry_arc()


func play_move(direction: Vector2) -> void:
	set_facing_direction(direction)
	_set_default_pose()
	left_leg_line.points = PackedVector2Array([Vector2(-4, 8), Vector2(-9, 18)])
	right_leg_line.points = PackedVector2Array([Vector2(4, 8), Vector2(9, 15)])


func play_attack_start(direction: Vector2 = facing_direction) -> void:
	set_facing_direction(direction)
	_set_default_pose()
	weapon_line.points = PackedVector2Array([Vector2(0, 2), Vector2(-18, 18)])


func show_attack_arc(direction: Vector2 = facing_direction) -> void:
	set_facing_direction(direction)
	attack_arc.visible = true
	attack_arc.default_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.9)
	attack_arc.points = _make_arc_points(28.0, 65.0, 8)
	weapon_line.points = PackedVector2Array([Vector2(0, 0), Vector2(0, 26)])


func hide_attack_arc() -> void:
	attack_arc.visible = false


func show_parry_arc(direction: Vector2 = facing_direction) -> void:
	set_facing_direction(direction)
	parry_arc.visible = true
	parry_arc.default_color = Color(0.35, 0.9, 1.0, 0.9)
	parry_arc.points = _make_arc_points(24.0, 100.0, 10)
	weapon_line.points = PackedVector2Array([Vector2(-14, 12), Vector2(14, 12)])


func hide_parry_arc() -> void:
	parry_arc.visible = false


func flash(color: Color, duration := 0.12) -> void:
	if flash_tween != null and flash_tween.is_valid():
		flash_tween.kill()

	flash_overlay.visible = true
	flash_overlay.color = color
	flash_tween = create_tween()
	flash_tween.tween_property(flash_overlay, "color:a", 0.0, duration)
	flash_tween.tween_callback(func() -> void: flash_overlay.visible = false)


func play_overclock_pulse(duration := 0.16) -> void:
	if pulse_tween != null and pulse_tween.is_valid():
		pulse_tween.kill()

	modulate = Color(1.0, 0.88, 0.35, 1.0)
	pulse_tween = create_tween()
	pulse_tween.tween_property(self, "modulate", Color.WHITE, duration)


func play_hurt_flash() -> void:
	flash(hurt_color, 0.14)


func set_facing_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	facing_direction = direction.normalized()
	rotation = facing_direction.angle() - Vector2.DOWN.angle()


func _ensure_structure() -> void:
	body_root = _get_or_create_node_2d(self, "BodyRoot")
	weapon_pivot = _get_or_create_node_2d(self, "WeaponPivot")
	effect_root = _get_or_create_node_2d(self, "EffectRoot")

	head_shape = _get_or_create_polygon(body_root, "HeadShape")
	torso_line = _get_or_create_line(body_root, "TorsoLine")
	left_arm_line = _get_or_create_line(body_root, "LeftArmLine")
	right_arm_line = _get_or_create_line(body_root, "RightArmLine")
	left_leg_line = _get_or_create_line(body_root, "LeftLegLine")
	right_leg_line = _get_or_create_line(body_root, "RightLegLine")
	weapon_line = _get_or_create_line(weapon_pivot, "WeaponLine")
	attack_arc = _get_or_create_line(weapon_pivot, "AttackArc")
	parry_arc = _get_or_create_line(weapon_pivot, "ParryArc")
	flash_overlay = _get_or_create_polygon(effect_root, "FlashOverlay")

	head_shape.color = base_color
	head_shape.polygon = PackedVector2Array([Vector2(0, -24), Vector2(8, -17), Vector2(0, -10), Vector2(-8, -17)])
	flash_overlay.visible = false
	flash_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	flash_overlay.polygon = PackedVector2Array([Vector2(-18, -28), Vector2(18, -28), Vector2(18, 22), Vector2(-18, 22)])

	for line in [torso_line, left_arm_line, right_arm_line, left_leg_line, right_leg_line, weapon_line, attack_arc, parry_arc]:
		line.width = line_width
		line.default_color = base_color
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND

	attack_arc.default_color = accent_color
	parry_arc.default_color = Color(0.35, 0.9, 1.0, 1.0)


func _set_default_pose() -> void:
	torso_line.points = PackedVector2Array([Vector2(0, -9), Vector2(0, 8)])
	left_arm_line.points = PackedVector2Array([Vector2(0, -3), Vector2(-10, 8)])
	right_arm_line.points = PackedVector2Array([Vector2(0, -3), Vector2(10, 8)])
	left_leg_line.points = PackedVector2Array([Vector2(-3, 8), Vector2(-7, 18)])
	right_leg_line.points = PackedVector2Array([Vector2(3, 8), Vector2(7, 18)])
	weapon_line.points = PackedVector2Array([Vector2(5, 0), Vector2(10, 20)])


func _make_arc_points(radius: float, spread_degrees: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var start_angle := deg_to_rad(90.0 - spread_degrees * 0.5)
	var step := deg_to_rad(spread_degrees / float(segments))
	for index in range(segments + 1):
		var angle := start_angle + step * float(index)
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	return points


func _get_or_create_node_2d(parent: Node, node_name: String) -> Node2D:
	var existing := parent.get_node_or_null(node_name)
	if existing is Node2D:
		return existing

	var node := Node2D.new()
	node.name = node_name
	parent.add_child(node)
	return node


func _get_or_create_line(parent: Node, node_name: String) -> Line2D:
	var existing := parent.get_node_or_null(node_name)
	if existing is Line2D:
		return existing

	var line := Line2D.new()
	line.name = node_name
	parent.add_child(line)
	return line


func _get_or_create_polygon(parent: Node, node_name: String) -> Polygon2D:
	var existing := parent.get_node_or_null(node_name)
	if existing is Polygon2D:
		return existing

	var polygon := Polygon2D.new()
	polygon.name = node_name
	parent.add_child(polygon)
	return polygon

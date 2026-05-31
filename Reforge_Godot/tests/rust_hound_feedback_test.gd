extends Node2D

const RUST_HOUND_SCENE: PackedScene = preload("res://entities/enemies/rust_hound/rust_hound.tscn")


func _ready() -> void:
	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	add_child(rust_hound)
	await get_tree().process_frame

	rust_hound.take_damage(10)
	if not _is_color_close(rust_hound.body_sprite.color, Color(1.0, 0.95, 0.75, 1.0)):
		_fail("Expected rust hound to flash when hurt, got %s." % rust_hound.body_sprite.color)
		return

	await get_tree().create_timer(0.2).timeout
	var expected_hurt_color: Color = rust_hound._get_health_body_color(30, 40)
	if not _is_color_close(rust_hound.body_sprite.color, expected_hurt_color):
		_fail("Expected rust hound to return to health color after hurt flash, got %s." % rust_hound.body_sprite.color)
		return

	rust_hound.take_damage(30)
	await get_tree().create_timer(0.4).timeout
	if rust_hound.modulate.a >= 0.5:
		_fail("Expected rust hound to fade after death, got alpha=%s." % rust_hound.modulate.a)
		return

	print("TEST rust hound feedback ok")
	get_tree().quit()


func _is_color_close(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.02 and absf(a.g - b.g) < 0.02 and absf(a.b - b.b) < 0.02 and absf(a.a - b.a) < 0.02


func _fail(message: String) -> void:
	push_error("TEST rust hound feedback failed. %s" % message)
	get_tree().quit(1)

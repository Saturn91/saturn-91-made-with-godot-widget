extends Control

@onready var font: Font = load("res://addons/made_with_godot/resources/Play-Bold.ttf")

var text = "Check out another game!"

func _draw() -> void:
	# Save current transform
	var current_transform = get_canvas_transform()

	var parent_height = get_parent().get_size().y
	var parent_width = get_parent().get_size().x
	
	# calc rotation point and apply rotation
	var size = font.get_string_size(text)
	var rotation_point = Vector2(24, parent_height - (parent_height - size.x) / 2.0)

	draw_set_transform(rotation_point, 3 * PI / 2, Vector2.ONE)
	
	draw_string(font, Vector2.ZERO, text)
	
	# Restore original transform
	draw_set_transform_matrix(current_transform)

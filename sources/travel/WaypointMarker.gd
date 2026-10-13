extends Node2D
var title : String

func _ready():
	var label := Label.new()
	label.text = title
	label.theme = preload("res://data/themes/DefaultTheme.tres")
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_outline_color", Color("10202c"))
	label.add_theme_constant_override("outline_size", 5)
	label.position = Vector2(-145, -57)
	label.size.x = 290
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)

func _draw():
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.5))
	draw_circle(Vector2.ZERO, 32, Color(0.1, 0.8, 1, 0.14))
	draw_arc(Vector2.ZERO, 31, 0, TAU, 48, Color("66dce8"), 3, true)
	draw_arc(Vector2.ZERO, 24, 0, TAU, 6, Color("d9bc72"), 2, true)
	draw_set_transform(Vector2.ZERO)

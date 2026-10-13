extends RefCounted
class_name RPGTheme

static func Box(color : Color, border : Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(2)
	box.set_corner_radius_all(8)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box

static func Create() -> Theme:
	var result : Theme = preload("res://data/themes/DefaultTheme.tres").duplicate()
	result.default_font_size = 16
	result.set_stylebox("panel", "PanelContainer", Box(Color("f3f1e9"), Color("829bb2")))
	for kind in ["Label", "Button", "LineEdit"]:
		for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			result.set_color(key, kind, Color("233e55"))
		result.set_color("font_disabled_color", kind, Color("7c8991"))
		result.set_color("font_shadow_color", kind, Color.TRANSPARENT)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		result.set_stylebox(state, "Button", Box(Color("d7e8f3") if state in ["hover", "pressed"] else Color("fafaf5"), Color("9bb5ca")))
	result.set_stylebox("normal", "LineEdit", Box(Color.WHITE, Color("9bb5ca")))
	return result

static func Text(value : String, font_size : int = 16) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

static func Icon(texture : Texture2D, edge : float = 48) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(edge, edge)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon

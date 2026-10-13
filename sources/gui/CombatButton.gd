extends Control
## Circular touch target with independent finger capture (move + skill together).
signal pressed
signal released

var caption : String = ""
var icon : Texture2D
var accent : Color = Color("d8b36b")
var active : bool = false
var unavailable : bool = false
var cooldown : float = 0.0
var cooldownMax : float = 1.0
var finger : int = -1
var held : bool = false
var label : Label
var counter : Label

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	label = Label.new()
	label.text = caption
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)
	counter = Label.new()
	counter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	counter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	counter.add_theme_font_size_override("font_size", 20)
	add_child(counter)

func Refresh():
	if label:
		label.text = caption
	if counter:
		counter.text = str(ceili(cooldown)) if cooldown > 0.0 else ""
	queue_redraw()

func Contains(point : Vector2) -> bool:
	var local : Vector2 = get_global_transform_with_canvas().affine_inverse() * point
	return local.distance_to(size * 0.5) <= size.x * 0.5

func Press():
	if unavailable or not is_visible_in_tree():
		return
	held = true
	queue_redraw()
	pressed.emit()

func Release():
	finger = -1
	if held:
		held = false
		released.emit()
	queue_redraw()

func _input(event : InputEvent):
	if event is InputEventScreenTouch:
		if not event.pressed and event.index == finger:
			Release()
		elif event.pressed and finger < 0 and is_visible_in_tree() and Contains(event.position):
			finger = event.index
			Press()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == finger:
		if not Contains(event.position):
			Release()

func _gui_input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.device != -1:
		if event.pressed:
			Press()
		else:
			Release()
		accept_event()

func _notification(what : int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or (what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree()):
		Release()

func _draw():
	var center : Vector2 = size * 0.5
	var radius : float = size.x * 0.5 - 3.0
	draw_circle(center + Vector2(0, 3), radius + 2, Color(0, 0, 0, 0.45))
	draw_circle(center, radius, Color("19354b") if not held else Color("39677d"))
	draw_circle(center, radius - 5, Color("102333") if not active else Color("245d57"))
	draw_arc(center, radius, 0, TAU, 64, accent if not unavailable else Color("65717c"), 2.5, true)
	draw_arc(center, radius - 4, 0, TAU, 64, Color(0.6, 0.8, 1, 0.2), 1, true)
	if icon:
		var edge : float = size.x * 0.48
		draw_texture_rect(icon, Rect2(center - Vector2(edge, edge) * 0.5 - Vector2(0, 6), Vector2(edge, edge)), false, Color.WHITE if not unavailable else Color(0.4, 0.4, 0.4))
	if cooldown > 0:
		draw_circle(center, radius - 3, Color(0, 0, 0, 0.55))
		draw_arc(center, radius - 2, -PI / 2, -PI / 2 + TAU * clampf(cooldown / maxf(cooldownMax, 0.01), 0, 1), 48, Color("76d9f1"), 3, true)

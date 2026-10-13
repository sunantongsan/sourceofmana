extends Node
## One gesture owner per finger; swipe over a row without buying/warping it.
var scrolls : Array[Control] = []
var activeScroll : Control
var finger := -1
var origin := Vector2.ZERO
var previous := Vector2.ZERO
var previousTime := 0
var dragging := false
var velocity := 0.0
var remainder := 0.0
var suppressMouseUntil := 0
var pressedButtons : Array[BaseButton] = []

func _ready():
	name = "TouchMenus"
	Scan(get_parent())
	get_tree().node_added.connect(Added)

func Added(node : Node):
	if node is ScrollContainer or (node is RichTextLabel and node.scroll_active):
		Register.call_deferred(node)

func Scan(node : Node):
	if node is ScrollContainer or (node is RichTextLabel and node.scroll_active):
		Register(node)
	for child in node.get_children():
		Scan(child)

func Register(scroll : Control):
	if not is_instance_valid(scroll) or not get_parent().is_ancestor_of(scroll) or scrolls.has(scroll):
		return
	# The minimap owns two-dimensional dragging and zoom.
	var ancestor : Node = scroll
	while ancestor != get_parent():
		if "minimap" in String(ancestor.name).to_lower():
			return
		ancestor = ancestor.get_parent()
	if scroll is ScrollContainer:
		scroll.scroll_deadzone = 6
	scroll.get_v_scroll_bar().custom_minimum_size.x = 22
	scroll.get_v_scroll_bar().step = 1
	scrolls.append(scroll)
	scroll.visibility_changed.connect(func():
		if activeScroll == scroll and not scroll.is_visible_in_tree():
			Reset()
	)

func FindScroll(point : Vector2) -> Control:
	for index in range(scrolls.size() - 1, -1, -1):
		var scroll : Control = scrolls[index]
		if not is_instance_valid(scroll) or not scroll.is_visible_in_tree():
			continue
		var bar : VScrollBar = scroll.get_v_scroll_bar()
		if scroll.get_global_rect().has_point(point) and bar.max_value > bar.page:
			if bar.is_visible_in_tree() and bar.get_global_rect().has_point(point):
				return null
			return scroll
	return null

func CollectButtons(node : Node, point : Vector2):
	if node is BaseButton and node.is_visible_in_tree() and node.get_global_rect().has_point(point):
		pressedButtons.append(node)
	for child in node.get_children():
		CollectButtons(child, point)

func CancelPresses():
	for button in pressedButtons:
		if is_instance_valid(button):
			var was_disabled : bool = button.disabled
			button.disabled = true
			button.set_pressed_no_signal(false)
			button.disabled = was_disabled
	pressedButtons.clear()

func _input(event : InputEvent):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.device == -1 and (dragging or Time.get_ticks_msec() < suppressMouseUntil):
			get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		if event.pressed and finger < 0:
			activeScroll = FindScroll(event.position)
			velocity = 0
			remainder = 0
			if activeScroll:
				finger = event.index
				origin = event.position
				previous = origin
				previousTime = Time.get_ticks_msec()
				dragging = false
				pressedButtons.clear()
				CollectButtons(activeScroll, origin)
		elif not event.pressed and event.index == finger:
			if dragging:
				CancelPresses()
				suppressMouseUntil = Time.get_ticks_msec() + 120
				if is_instance_valid(activeScroll):
					activeScroll.propagate_notification(Control.NOTIFICATION_SCROLL_END)
				get_viewport().set_input_as_handled()
			finger = -1
			dragging = false
			pressedButtons.clear()
	elif event is InputEventScreenDrag and event.index == finger and is_instance_valid(activeScroll):
		if not activeScroll.is_visible_in_tree():
			Reset()
			return
		if not dragging and event.position.distance_to(origin) >= 8:
			dragging = true
			activeScroll.propagate_notification(Control.NOTIFICATION_SCROLL_BEGIN)
			CancelPresses()
		if dragging:
			var now : int = Time.get_ticks_msec()
			var elapsed : float = maxf(0.016, (now - previousTime) / 1000.0)
			var movement : float = previous.y - event.position.y
			MoveScroll(movement)
			velocity = clampf(movement / elapsed, -1400, 1400)
			previous = event.position
			previousTime = now
			get_viewport().set_input_as_handled()

func MoveScroll(amount : float):
	if not is_instance_valid(activeScroll):
		return
	remainder += amount
	var pixels : int = int(remainder)
	remainder -= pixels
	activeScroll.get_v_scroll_bar().value += pixels

func Reset():
	CancelPresses()
	finger = -1
	dragging = false
	velocity = 0
	activeScroll = null

func _process(delta : float):
	if is_instance_valid(activeScroll) and not activeScroll.is_visible_in_tree():
		Reset()
	if finger < 0 and absf(velocity) > 5 and is_instance_valid(activeScroll):
		MoveScroll(velocity * delta)
		velocity = move_toward(velocity, 0.0, delta * 2600)

func _notification(what : int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		Reset()

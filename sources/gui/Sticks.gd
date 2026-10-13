extends HBoxContainer

#
@onready var buttonLeft : TouchScreenButton		= $LeftAnchor/ButtonLeft
@onready var direction : TouchScreenButton		= $LeftAnchor/Direction
@onready var buttonRight : TouchScreenButton	= $RightAnchor/ButtonRight
@onready var actions : Control					= $RightAnchor/Actions

@onready var directionButton : Control			= $LeftAnchor/Direction/Button
@onready var defaultStickPosition : Vector2		= directionButton.get_position()

var leftStickPressed : bool				= false
var lastMove : Vector2 = Vector2.ZERO
var touchIndex : int = -1
var heldButtons : Array[int] = []

#
func GetMove() -> Vector2:
	if leftStickPressed and defaultStickPosition.x != 0.0 and defaultStickPosition.y != 0.0:
		var move : Vector2 = directionButton.get_position() / defaultStickPosition - Vector2.ONE
		lastMove = move
		return move
	else:
		return Vector2.ZERO

func Enable(isEnabled : bool):
	if not isEnabled:
		ReleaseControls()
	if isEnabled:
		var rescaledWindowSize : float = float(DisplayServer.window_get_size().x / Launcher.Root.get_content_scale_factor())
		var horizontalMargin : int = lerp(0, 160, max(0, rescaledWindowSize - Launcher.GUI.settingsWindow.GetVal("Render-MinWindowSize").x * 1.5) / rescaledWindowSize)
		Launcher.GUI.shortcuts.add_theme_constant_override("margin_left", horizontalMargin)
		Launcher.GUI.shortcuts.add_theme_constant_override("margin_right", horizontalMargin)

	buttonLeft.set_visible(isEnabled)
	direction.set_visible(isEnabled)
	buttonRight.set_visible(isEnabled)
	actions.set_visible(isEnabled)

	if Launcher.Action:
		Launcher.Action.supportMouse = not isEnabled

#
func _on_direction_button_down():
	if not LauncherCommons.isMobile:
		leftStickPressed = true

func _on_direction_button_up():
	if not LauncherCommons.isMobile:
		ResetStick()

func _physics_process(_delta):
	if leftStickPressed and touchIndex < 0:
		UpdateStick(direction.get_local_mouse_position())

func UpdateStick(localPos : Vector2):
	var center : Vector2 = Vector2(direction.texture_normal.get_size()) * 0.5
	var radius : float = maxf(1.0, minf(defaultStickPosition.x, defaultStickPosition.y))
	var offset : Vector2 = (localPos - center).limit_length(radius)
	directionButton.position = defaultStickPosition + offset

func ResetStick():
	touchIndex = -1
	leftStickPressed = false
	lastMove = Vector2.ZERO
	if is_instance_valid(directionButton):
		directionButton.position = defaultStickPosition

func ReleaseControls():
	ResetStick()
	for buttonId in heldButtons:
		DeviceManager.SendEventJoy(buttonId, false)
	heldButtons.clear()

func _input(event : InputEvent):
	if not LauncherCommons.isMobile or not is_instance_valid(direction):
		return
	if event is InputEventScreenTouch:
		if not event.pressed and event.index == touchIndex:
			ResetStick()
		elif event.pressed and touchIndex < 0 and direction.is_visible_in_tree():
			var localPos : Vector2 = direction.get_global_transform_with_canvas().affine_inverse() * event.position
			if Rect2(Vector2.ZERO, direction.texture_normal.get_size()).has_point(localPos):
				touchIndex = event.index
				leftStickPressed = true
				UpdateStick(localPos)
	elif event is InputEventScreenDrag and event.index == touchIndex:
		UpdateStick(direction.get_global_transform_with_canvas().affine_inverse() * event.position)

func _notification(what : int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		ReleaseControls()

func _press_button(buttonId : JoyButton):
	if not heldButtons.has(buttonId):
		heldButtons.append(buttonId)
	DeviceManager.SendEventJoy(buttonId, true)

func _release_button(buttonId : JoyButton):
	heldButtons.erase(buttonId)
	DeviceManager.SendEventJoy(buttonId, false)

extends Control
var panel : PanelContainer
var travelButton : Button
var flightButton : Button
var location : Label
var requestSerial : int = 0
var shownMap : int = DB.UnknownHash
var markerRoot : Node2D

func _ready():
	name = "TravelHUD"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = preload("res://data/themes/DefaultTheme.tres")
	travelButton = Button.new()
	travelButton.text = "เดินทาง / วาร์ป"
	add_child(travelButton)
	travelButton.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	travelButton.position += Vector2(100, 8)
	travelButton.custom_minimum_size = Vector2(135, 42)
	travelButton.add_theme_font_size_override("font_size", 16)
	travelButton.pressed.connect(Toggle)
	flightButton = Button.new()
	flightButton.text = "ขี่กระบี่"
	add_child(flightButton)
	flightButton.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	flightButton.position += Vector2(240, 8)
	flightButton.custom_minimum_size = Vector2(95, 42)
	flightButton.add_theme_font_size_override("font_size", 16)
	flightButton.pressed.connect(Fly)
	panel = PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = 60
	panel.offset_bottom = -24
	var column := VBoxContainer.new()
	panel.add_child(column)
	location = Label.new()
	location.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(location)
	var hint := Label.new()
	hint.text = "เลือกจุดหมายเพื่อวาร์ปฟรี • ใช้ได้จากทุกจุดในโหมดออฟไลน์\nขี่กระบี่ได้กลางแจ้ง ลงบนถนนหรือพื้นที่โล่งก่อนต่อสู้"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var destinations := VBoxContainer.new()
	destinations.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(destinations)
	for idx in Travel.POINTS.size():
		var button := Button.new()
		button.text = "%d. %s" % [idx + 1, Travel.POINTS[idx].title]
		button.custom_minimum_size.y = 48
		button.pressed.connect(Warp.bind(idx))
		destinations.add_child(button)
	var close := Button.new()
	close.text = "กลับเข้าเกม"
	close.custom_minimum_size.y = 44
	close.pressed.connect(Close)
	column.add_child(close)
	panel.hide()

func StopCombat(notifyServer : bool = true):
	var hud = Launcher.GUI.get_node_or_null("CombatHUD")
	if hud:
		hud.SetAutoMode(hud.AutoMode.OFF, notifyServer)
	Network.ClearNavigation()
	Launcher.Action.previousMove = Vector2.ZERO

func Toggle():
	if panel.visible:
		Close()
	else:
		StopCombat()
		var guide = Launcher.GUI.get_node_or_null("TrainingGuide")
		if guide:
			guide.CloseGuide()
		Launcher.GUI.sticks.ReleaseControls()
		Launcher.GUI.sticks.hide()
		panel.show()

func Close():
	if panel and panel.visible:
		Launcher.GUI.sticks.show()
		panel.hide()

func Warp(idx : int):
	StopCombat(false)
	Close()
	SendTravel(idx, Travel.WARP_ACTION.hash())

func Fly():
	StopCombat(false)
	Close()
	SendTravel(DB.UnknownHash, Travel.FLIGHT_ACTION.hash())

func _process(_delta : float):
	visible = FSM.IsGameState() and is_instance_valid(Launcher.Player)
	if not visible:
		Close()
		shownMap = DB.UnknownHash
		return
	var blocked : bool = Launcher.GUI.IsDialogueContextOpened() or not Launcher.Action.IsEnabled()
	var offline : bool = Network.Client != null and Network.Client.isOffline
	travelButton.disabled = blocked or not offline
	flightButton.disabled = blocked or not offline or (not Travel.CanFly(Launcher.Map.currentMapID) and not Travel.IsFlying(Launcher.Player))
	flightButton.text = "ลงกระบี่" if Travel.IsFlying(Launcher.Player) else "ขี่กระบี่"
	location.text = "จุดวาร์ปวิถีเซียน • %s" % ("กำลังขี่กระบี่" if Travel.IsFlying(Launcher.Player) else "เลือกจุดสำคัญ ไม่ต้องเดินหา")
	if shownMap != Launcher.Map.currentMapID:
		shownMap = Launcher.Map.currentMapID
		Close()
		RefreshMarkers()

func RefreshMarkers():
	if is_instance_valid(markerRoot):
		markerRoot.queue_free()
	if not Launcher.Map.currentMapNode:
		return
	markerRoot = Node2D.new()
	markerRoot.name = "TravelWaypoints"
	Launcher.Map.currentMapNode.add_child(markerRoot)
	for point in Travel.POINTS:
		if String(point.map).hash() == shownMap:
			var marker = preload("res://sources/travel/WaypointMarker.gd").new()
			marker.position = point.pos
			marker.title = point.title
			markerRoot.add_child(marker)

func SendTravel(target : int, action : int):
	requestSerial += 1
	var serial : int = requestSerial
	var player : Entity = Launcher.Player
	await get_tree().create_timer(float(NetworkCommons.DelayShort) / 1000.0 + 0.05).timeout
	if serial == requestSerial and FSM.IsGameState() and is_instance_valid(player) and Launcher.Player == player:
		Network.TriggerSkill(target, action)

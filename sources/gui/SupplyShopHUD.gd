extends Control

var panel : PanelContainer
var balance : Label
var feedback : Label
var command : LineEdit
var openButton : Button
var readyAt : int = 0

func _ready():
	name = "SupplyShopHUD"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = preload("res://data/themes/DefaultTheme.tres")
	openButton = Button.new()
	openButton.text = "ร้านค้า / GM"
	openButton.position = Vector2(10, 105)
	openButton.custom_minimum_size = Vector2(130, 44)
	openButton.pressed.connect(Toggle)
	add_child(openButton)
	panel = PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = 60
	panel.offset_bottom = -24
	var column := VBoxContainer.new()
	panel.add_child(column)
	balance = Label.new()
	column.add_child(balance)
	var hint := Label.new()
	hint.text = "ซื้อสินค้าได้ในเมือง • ใช้ยา/สวมอุปกรณ์จากกระเป๋า\nล่ามอนสเตอร์รับ G เข้าตัวอัตโนมัติ"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hint)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(rows)
	for index in SupplyShop.CATALOG.size():
		var product : Dictionary = SupplyShop.CATALOG[index]
		var row := HBoxContainer.new()
		rows.add_child(row)
		var title := Label.new()
		title.text = "%s • %d G" % [product.title, product.price]
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(title)
		for count in [1, 10]:
			var buy := Button.new()
			buy.text = "ซื้อ ×%d" % count
			buy.custom_minimum_size = Vector2(88, 46)
			buy.pressed.connect(Buy.bind(index, count))
			row.add_child(buy)
	var gmrow := HBoxContainer.new()
	column.add_child(gmrow)
	command = LineEdit.new()
	command.placeholder_text = "gm g+1000 / gm exp100x / gm exp1x"
	command.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command.text_submitted.connect(RunGM)
	gmrow.add_child(command)
	var send := Button.new()
	send.text = "ส่ง GM"
	send.custom_minimum_size = Vector2(88, 44)
	send.pressed.connect(func(): RunGM(command.text))
	gmrow.add_child(send)
	feedback = Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.text = "GM ใช้ทดสอบออฟไลน์ • EXP กลับปกติเมื่อออกจากเกม"
	column.add_child(feedback)
	var close := Button.new()
	close.text = "กลับเข้าเกม"
	close.custom_minimum_size.y = 44
	close.pressed.connect(Close)
	column.add_child(close)
	panel.hide()

func Toggle():
	if panel.visible:
		Close()
		return
	Launcher.GUI.get_node("TravelHUD").Close()
	Launcher.GUI.get_node("TrainingGuide").CloseGuide()
	Launcher.GUI.get_node("CombatHUD").SetAutoMode(0)
	Network.ClearNavigation()
	Launcher.GUI.sticks.ReleaseControls()
	Launcher.GUI.sticks.hide()
	readyAt = Time.get_ticks_msec() + 150
	panel.show()

func Close():
	if panel.visible:
		command.release_focus()
		panel.hide()
		Launcher.GUI.sticks.show()

func Buy(index : int, count : int):
	if Time.get_ticks_msec() < readyAt:
		return
	readyAt = Time.get_ticks_msec() + 200
	Network.TriggerSkill(index * 100 + count, SupplyShop.ACTION.hash())

func RunGM(value : String):
	if not value.strip_edges().to_lower().begins_with("gm "):
		feedback.text = "GM: ใช้ gm g+1000 / gm exp100x / gm exp1x"
		return
	Network.TriggerCommand(value.strip_edges())
	command.clear()
	command.release_focus()

func _process(_delta : float):
	visible = FSM.IsGameState() and is_instance_valid(Launcher.Player)
	if not visible:
		Close()
		return
	openButton.disabled = not Network.Client or not Network.Client.isOffline or Launcher.GUI.IsDialogueContextOpened()
	balance.text = "ร้านเสบียงฝึกตน • เงิน %d G • %s" % [Launcher.Player.stat.gp, "พร้อมซื้อ" if Cultivation.IsCity(Launcher.Map.currentMapID) else "กลับเมืองก่อนซื้อ"]

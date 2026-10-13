extends Control

var panel : PanelContainer
var summary : Label
var points : Label
var feedback : Label
var ranks : Array[Label] = []
var upgrades : Array[Button] = []
var elapsed := 0.0
var requestAt := 0

func _ready():
	name = "CharacterHUD"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = RPGTheme.Create()
	panel = PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 20
	panel.offset_right = -20
	panel.offset_top = 35
	panel.offset_bottom = -20
	var column := VBoxContainer.new()
	panel.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title := RPGTheme.Text("ตัวละคร • วิถีเซียน", 22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close := Button.new()
	close.text = "ปิด ×"
	close.custom_minimum_size = Vector2(80, 44)
	close.pressed.connect(Close)
	header.add_child(close)
	summary = RPGTheme.Text("")
	column.add_child(summary)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	for index in 2:
		var button := Button.new()
		button.text = ["ค่าสถานะ / เพิ่มคุณสมบัติ", "กระเป๋า / สวมอุปกรณ์"][index]
		button.custom_minimum_size.y = 44
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(OpenNative.bind(index))
		actions.add_child(button)
	points = RPGTheme.Text("", 18)
	column.add_child(points)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for index in SkillTraining.NAMES.size():
		var skill : SkillCell = DB.GetSkill(SkillTraining.NAMES[index].hash())
		var card := PanelContainer.new()
		list.add_child(card)
		var row := HBoxContainer.new()
		card.add_child(row)
		row.add_child(RPGTheme.Icon(skill.icon))
		var text := RPGTheme.Text("")
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text)
		ranks.append(text)
		var upgrade := Button.new()
		upgrade.custom_minimum_size = Vector2(128, 56)
		upgrade.text = "อัปขั้น • 1 แต้ม"
		upgrade.pressed.connect(Upgrade.bind(index))
		row.add_child(upgrade)
		upgrades.append(upgrade)
	feedback = RPGTheme.Text("ได้ 1 แต้มทุกครั้งที่เลเวลอัป • ขั้น 1 ฟรี • ความแรง +10% ต่อขั้น", 14)
	column.add_child(feedback)
	panel.hide()

func Toggle():
	if panel.visible:
		Close()
		return
	if not FSM.IsGameState() or Launcher.GUI.IsDialogueContextOpened():
		return
	Launcher.GUI.get_node("SupplyShopHUD").Close()
	Launcher.GUI.get_node("TravelHUD").Close()
	Launcher.GUI.get_node("TrainingGuide").CloseGuide()
	for window in [Launcher.GUI.inventoryWindow, Launcher.GUI.statWindow, Launcher.GUI.skillWindow]:
		if window.visible:
			window.EnableControl(false)
	Launcher.GUI.get_node("CombatHUD").SetAutoMode(0)
	Network.ClearNavigation()
	Launcher.GUI.sticks.ReleaseControls()
	Launcher.GUI.sticks.hide()
	panel.show()
	Refresh()

func Close():
	if panel.visible:
		panel.hide()
		Launcher.GUI.sticks.show()

func OpenNative(index : int):
	Close()
	var window = Launcher.GUI.statWindow if index == 0 else Launcher.GUI.inventoryWindow
	if not window.visible:
		Launcher.GUI.ToggleControl(window)

func Upgrade(index : int):
	if Time.get_ticks_msec() < requestAt:
		return
	requestAt = Time.get_ticks_msec() + 250
	Network.TriggerSkill(SkillTraining.NAMES[index].hash(), SkillTraining.ACTION.hash())

func Refresh():
	if not is_instance_valid(Launcher.Player):
		return
	var player : Entity = Launcher.Player
	var available : int = SkillTraining.Points(player)
	summary.text = "%s • %s\nHP %d/%d   ปราณ %d/%d   EXP %d/%d   เงิน %d G" % [player.nick, Cultivation.Title(player.stat.level), player.stat.health, player.stat.current.maxHealth, player.stat.mana, player.stat.current.maxMana, player.stat.experience, Experience.GetNeededExperienceForNextLevel(player.stat.level), player.stat.gp]
	points.text = "ฝึกวิชา • แต้มคงเหลือ %d • สูงสุด 20 ขั้น" % available
	for index in ranks.size():
		var skill : SkillCell = DB.GetSkill(SkillTraining.NAMES[index].hash())
		var rank : int = player.progress.GetSkillLevel(skill)
		var mode : String = "โจมตีหมู่รอบตัว" if index < 2 else "โจมตีเป้าหมายเดี่ยว"
		ranks[index].text = "%s • ขั้น %d/20\n%s • ความแรง %d%%" % [SkillTraining.TITLES[index], rank, mode, roundi(SkillTraining.Multiplier(player, skill) * 100)]
		upgrades[index].text = "เต็มขั้นแล้ว" if rank >= 20 else "อัปขั้น • 1 แต้ม"
		upgrades[index].disabled = rank < 1 or rank >= 20 or available < 1 or not Network.Client.isOffline

func _process(delta : float):
	visible = FSM.IsGameState() and is_instance_valid(Launcher.Player)
	if not visible:
		Close()
		return
	elapsed += delta
	if panel.visible and elapsed >= 0.2:
		elapsed = 0
		Refresh()

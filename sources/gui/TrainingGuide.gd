extends Control
## A compact, always-available learning aid. Does not pause or lock combat.

var guideButton : Button
var panel : PanelContainer
var objective : Label
var details : RichTextLabel
var elapsed : float = 0.0

func _ready():
	name = "TrainingGuide"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = preload("res://data/themes/DefaultTheme.tres")
	guideButton = Button.new()
	guideButton.text = "ฝึกตน"
	guideButton.tooltip_text = "ดูเป้าหมายและวิธีพัฒนาตัวละคร"
	guideButton.custom_minimum_size = Vector2(100, 42)
	add_child(guideButton)
	guideButton.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	guideButton.position += Vector2(-50, 8)
	guideButton.pressed.connect(ToggleGuide)
	panel = PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 18
	panel.offset_top = 58
	panel.offset_right = -18
	panel.offset_bottom = -100
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	objective = Label.new()
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(objective)
	details = RichTextLabel.new()
	details.bbcode_enabled = true
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.add_theme_font_size_override("normal_font_size", 18)
	details.text = "[b]ฝึกตนให้แข็งแกร่งขึ้น[/b]\n1. เปิดกระเป๋า เลือกดาบหรือชุด แล้วกดสวมใส่ ดูค่าพลังที่เปลี่ยนก่อนตัดสินใจ\n2. ล่าศัตรูที่สู้ไหวเพื่อรับค่าประสบการณ์ เก็บของด้วย L บนมือถือ\n3. เมื่อระดับเพิ่ม เปิดค่าสถานะ ดูแต้มที่เหลือ กด + แล้วกดบันทึก\n4. เลือกอุปกรณ์ที่เหมาะกับตนเอง พกอาหารและยาก่อนออกสำรวจ\n\n[b]เลือกแต้มอย่างไร[/b]\nกำลัง: เพิ่มโจมตีกายภาพและน้ำหนักที่แบกได้\nพละกำลัง: เพิ่มชีวิตและป้องกัน\nความคล่องตัว: เพิ่มความแม่นยำและการหลบ\nความทนทาน: เพิ่มความอึดและการฟื้นความอึด\nสมาธิ: เพิ่มพลังปราณและพลังเวท\nลองกด + เพื่อดูค่าพลังก่อนบันทึก ปุ่มคืนค่ายกเลิกเฉพาะแต้มที่ยังไม่บันทึก\n\n[b]ปุ่มมือถือ[/b]\nลากแป้นซ้ายเพื่อเดิน • A โจมตี/โต้ตอบ • R เปลี่ยนเป้าหมาย\nL เก็บของ • X วิ่ง • Y นั่งพัก • B ยกเลิก\nฝึกในที่ปลอดภัยก่อน อย่าวิ่งจนความอึดหมดแล้วเข้าต่อสู้"
	column.add_child(details)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	AddShortcut(actions, "กระเป๋า", OpenInventory)
	AddShortcut(actions, "ค่าสถานะ", OpenStats)
	AddShortcut(actions, "ปิดคู่มือ", CloseGuide)
	panel.hide()
	RefreshObjective()

func AddShortcut(container : Container, caption : String, callback : Callable):
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 42
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	container.add_child(button)

func ToggleGuide():
	panel.visible = not panel.visible
	RefreshObjective()

func CloseGuide():
	panel.hide()

func OpenInventory():
	CloseGuide()
	if not Launcher.GUI.inventoryWindow.visible:
		Launcher.GUI.ToggleControl(Launcher.GUI.inventoryWindow)

func OpenStats():
	CloseGuide()
	if not Launcher.GUI.statWindow.visible:
		Launcher.GUI.ToggleControl(Launcher.GUI.statWindow)

func _process(delta : float):
	elapsed += delta
	if elapsed >= 0.5:
		elapsed = 0.0
		RefreshObjective()

func RefreshObjective():
	visible = FSM.IsGameState() and is_instance_valid(Launcher.Player)
	if not visible:
		panel.hide()
		return
	var player : Entity = Launcher.Player
	var state : int = player.progress.GetQuest(ProgressCommons.Quest.TUTORIAL)
	var nextStep : String
	if state < ProgressCommons.TUTORIAL.ELANORE_DONE:
		nextStep = "ขั้นที่ 1: รับชุดจากเอลานอร์ แล้วเปิดกระเป๋าเพื่อสวมใส่"
	elif state < ProgressCommons.TUTORIAL.KAEL_MET:
		nextStep = "ขั้นที่ 2: พบคาเอลข้างแปลงกระบองเพชร รับดาบแล้วสวมใส่"
	elif state < ProgressCommons.TUTORIAL.KAEL_DONE:
		nextStep = "ขั้นที่ 3: กระบองเพชร %d/5 • หนอน %d/5 ครบแล้วกลับหาคาเอล" % [mini(player.progress.GetBestiary("Peyote".hash()), 5), mini(player.progress.GetBestiary("Maggot".hash()), 5)]
	elif state < ProgressCommons.TUTORIAL.EKINU_DONE:
		nextStep = "ขั้นที่ 4: พบเอคินูที่ประตูเมือง รับอุปกรณ์และจัดแต้ม"
	else:
		nextStep = "ฝึกต่อ: ล่าศัตรู → เก็บของ → เปลี่ยนอุปกรณ์ → จัดแต้ม"
	var available : int = Formula.GetMaxAttributePoints(player.stat.level) - Formula.GetAssignedAttributePoints(player.stat)
	objective.text = "%s\nระดับ %d • ค่าประสบการณ์ %d/%d • แต้มที่ยังใช้ได้ %d" % [nextStep, player.stat.level, player.stat.experience, Experience.GetNeededExperienceForNextLevel(player.stat.level), available]
	guideButton.tooltip_text = nextStep
	guideButton.text = "ฝึกตน • %d แต้ม" % available if available > 0 else "ฝึกตน • เป้าหมาย"

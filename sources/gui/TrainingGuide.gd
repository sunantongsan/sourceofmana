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
	details.text = "[b]เริ่มวิถีเซียน[/b]\nตัวละครได้รับและสวมดาบเริ่มต้นแล้ว พร้อมสกิล 3 วิชา\nเมืองเป็นเขตปลอดภัย ออกประตูด้านใต้ไปลานฝึกนอกเมืองเพื่อหาหนอนและกระบองเพชร\n\n[b]เดินทางไม่หลงเมือง[/b]\nกดเดินทาง / วาร์ปด้านบน เลือกผู้ฝึกสอน ประตูใต้ หรือจุดสำคัญเพื่อวาร์ปฟรี\nกดขี่กระบี่เพื่อบินเร็วขึ้น ใช้แป้นเดินหรือแตะจุดหมาย ลงกระบี่บนถนนก่อนต่อสู้\n\n[b]ต่อสู้บนมือถือ[/b]\nปุ่มดาบใหญ่: โจมตีปกติ • ปุ่มรอบดาบ: สกิลพร้อมคูลดาวน์\nออโตตีปกติ: เลือกศัตรูใกล้ตัว เดินเข้าระยะ และตีต่อเนื่อง\nออโตใช้สกิล: ใช้เฉพาะสกิลที่พร้อม หากปราณ/ความอึดไม่พอจะรอ\nขยับแป้นเดินเพื่อควบคุมเอง ออโตจะพักระหว่างเดิน\nปุ่มโต้ตอบใช้คุยกับผู้ฝึกสอน ปุ่มเก็บของเก็บไอเทม ปุ่มพักใช้นั่งฟื้นพลัง\n\n[b]พัฒนาตัวละคร[/b]\nล่าศัตรู → สะสมประสบการณ์ → เลื่อนชั้น → จัดแต้ม → เปลี่ยนอุปกรณ์\nทุก 10 ชั้นจะขึ้นขั้นฝึกตนถัดไป รวม 100 ชั้น\nเปิดค่าสถานะ กด + ดูค่าพลังที่เปลี่ยน แล้วกดบันทึก\nกำลังเพิ่มโจมตี • พละกำลังเพิ่มชีวิตและป้องกัน • ความคล่องตัวเพิ่มแม่นยำและหลบ\nความทนทานเพิ่มความอึด • สมาธิเพิ่มปราณและเวท\n\n[b]สิบขั้นฝึกตน[/b]\n" + Cultivation.Roadmap()
	details.text += "\n\n[b]เก็บเลเวล 1–100[/b]\nทุกเลเวลเพิ่ม HP 20, MP 4, ความอึด 3, พลังโจมตี/เวท 3 และแต้มจัดสรร 3 แต้ม\nSTR เพิ่มโจมตี • VIT เพิ่มเลือด/ป้องกัน • AGI เพิ่มแม่นยำ/ความไว • INT เพิ่มเวท/ปราณ • END เพิ่มความอึด\nเลเวลเพิ่มฟื้นพลังเต็ม ล่ามอนสเตอร์รับ EXP และเงิน ไม่ต้องทำเควสต์เพื่อปลดเลเวล\n\n[b]พื้นที่ล่าตามเลเวล[/b]\n" + Hunting.Guide()
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
	var zone := Hunting.Recommended(player.stat.level)
	var nextStep := "เป้าหมาย: %s (Lv.%d–%d) • ล่า → รับ EXP/เงิน → เก็บของ → จัดแต้ม" % [zone.title, zone.min, zone.max]
	var available : int = Formula.GetMaxAttributePoints(player.stat.level) - Formula.GetAssignedAttributePoints(player.stat)
	objective.text = "%s\n%s • ค่าประสบการณ์ %d/%d • แต้มที่ยังใช้ได้ %d" % [nextStep, Cultivation.Title(player.stat.level), player.stat.experience, Experience.GetNeededExperienceForNextLevel(player.stat.level), available]
	guideButton.tooltip_text = nextStep
	guideButton.text = "ฝึกตน • %d แต้ม" % available if available > 0 else "ฝึกตน • เป้าหมาย"

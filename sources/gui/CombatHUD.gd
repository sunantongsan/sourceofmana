extends Control

const RoundButton = preload("res://sources/gui/CombatButton.gd")
const SKILLS : Array[String] = ["Mana Burst", "Leaf Blades", "Sonic Scream"]
const SKILL_LABELS : Array[String] = ["ปราณม่วง", "กระบี่หยก", "กระบี่คราม"]
enum AutoMode { OFF, NORMAL, SKILLS }
var autoMode : AutoMode = AutoMode.OFF
var attackButton : Control
var skillButtons : Array[Control] = []
var autoButtons : Array[Button] = []
var status : Label
var cooldowns : Dictionary[int, float] = {}
var cooldownMax : Dictionary[int, float] = {}
var tick : float = 0.0
var requestWait : float = 0.0
var pendingSkill : int = DB.UnknownHash
var previousMap : int = DB.UnknownHash
var previousPlayer : Entity
var chasing : bool = false
var chaseTime : float = 0.0
var lastChasePosition : Vector2

func _ready():
	name = "CombatHUD"
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	offset_left = -340
	offset_top = -300
	offset_right = -10
	offset_bottom = -10
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = preload("res://data/themes/DefaultTheme.tres")
	var modes := HBoxContainer.new()
	modes.position = Vector2(26, 0)
	modes.size = Vector2(300, 36)
	add_child(modes)
	for mode in 3:
		var button := Button.new()
		button.text = ["ออโต: ปิด", "ตีปกติ", "ใช้สกิล"][mode]
		button.custom_minimum_size = Vector2(92, 36)
		button.add_theme_font_size_override("font_size", 14)
		button.pressed.connect(SetAutoMode.bind(mode))
		modes.add_child(button)
		autoButtons.append(button)
	status = Label.new()
	status.position = Vector2(24, 38)
	status.size = Vector2(300, 26)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status.add_theme_font_size_override("font_size", 13)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(status)
	attackButton = AddCircle("โจมตี", Vector2(222, 172), 100, "Melee", Attack)
	attackButton.released.connect(ReleaseAttack)
	for idx in SKILLS.size():
		var positions : Array[Vector2] = [Vector2(134, 208), Vector2(130, 116), Vector2(222, 84)]
		skillButtons.append(AddCircle(SKILL_LABELS[idx], positions[idx], 72, SKILLS[idx], ManualSkill.bind(idx)))
	AddCircle("เป้าหมาย", Vector2(282, 58), 44, "", NextTarget)
	AddCircle("โต้ตอบ", Vector2(56, 215), 60, "", Interact)
	AddCircle("เก็บของ", Vector2(1, 230), 50, "", Pickup)
	AddCircle("พัก", Vector2(75, 150), 50, "", Sit)
	SetAutoMode(AutoMode.OFF)

func AddCircle(caption : String, pos : Vector2, diameter : float, skillName : String, callback : Callable) -> Control:
	var button = RoundButton.new()
	button.caption = caption
	button.position = pos
	button.size = Vector2(diameter, diameter)
	if not skillName.is_empty() and DB.HasCellHash(skillName):
		var skill : SkillCell = DB.GetSkill(DB.GetCellHash(skillName))
		if skill:
			button.icon = skill.icon
	button.pressed.connect(callback)
	add_child(button)
	return button

func OverlayOpen() -> bool:
	var shop = Launcher.GUI.get_node_or_null("SupplyShopHUD")
	if shop and shop.panel.visible:
		return true
	var travel = Launcher.GUI.get_node_or_null("TravelHUD")
	if travel and travel.panel and travel.panel.visible:
		return true
	var guide = Launcher.GUI.get_node_or_null("TrainingGuide")
	if guide and guide.panel and guide.panel.visible:
		return true
	for window in [Launcher.GUI.inventoryWindow, Launcher.GUI.statWindow, Launcher.GUI.settingsWindow, Launcher.GUI.skillWindow, Launcher.GUI.progressWindow, Launcher.GUI.messageBox, Launcher.GUI.quitBox]:
		if window and window.is_visible_in_tree():
			return true
	return false

func ReadyForCombat() -> bool:
	return FSM.IsGameState() and is_instance_valid(Launcher.Player) and ActorCommons.IsAlive(Launcher.Player) and Launcher.Action.IsEnabled() and not Launcher.GUI.IsDialogueContextOpened() and not OverlayOpen() and not Travel.IsFlying(Launcher.Player)

func SetAutoMode(mode : int, notifyServer : bool = true):
	StopCombat(notifyServer)
	autoMode = mode as AutoMode
	for idx in autoButtons.size():
		autoButtons[idx].modulate = Color("ffe2a1") if idx == mode else Color("8499ad")

func StopCombat(notifyServer : bool = true):
	pendingSkill = DB.UnknownHash
	chasing = false
	chaseTime = 0
	if notifyServer and is_instance_valid(Launcher.Player) and FSM.IsGameState():
		Network.TriggerSkill(DB.UnknownHash, DB.UnknownHash)

func Attack():
	if not ReadyForCombat():
		return
	pendingSkill = DB.GetCellHash("Melee")
	TryCombat(pendingSkill, false)

func ReleaseAttack():
	# A tap finishes its one pending attack. Auto is controlled only by the selector.
	pass

func ManualSkill(idx : int):
	if not ReadyForCombat():
		return
	var skillID : int = DB.GetCellHash(SKILLS[idx])
	if cooldowns.get(skillID, 0.0) <= 0:
		pendingSkill = skillID
		TryCombat(skillID, false)

func NextTarget():
	if ReadyForCombat():
		Entities.Target(Launcher.Player.position, false, true)

func Interact():
	SetAutoMode(AutoMode.OFF)
	if ReadyForCombat():
		Entities.JustInteract()

func Pickup():
	if ReadyForCombat():
		Launcher.Map.PickupNearestDrop()

func Sit():
	SetAutoMode(AutoMode.OFF)
	if ReadyForCombat():
		Network.TriggerSit()

func OnCasted(skillID : int, duration : float):
	cooldowns[skillID] = duration
	cooldownMax[skillID] = duration
	requestWait = 0.1

func CanUse(skillID : int) -> bool:
	var skill : SkillCell = DB.GetSkill(skillID)
	if not skill or not Launcher.Player.progress.HasSkill(skill) or cooldowns.get(skillID, 0.0) > 0:
		return false
	return Launcher.Player.stat.mana >= maxi(0, -int(skill.modifiers.Get(CellCommons.Modifier.Mana))) and Launcher.Player.stat.stamina >= maxi(0, -int(skill.modifiers.Get(CellCommons.Modifier.Stamina)))

func TryCombat(skillID : int, automatic : bool):
	if not ReadyForCombat() or Cultivation.IsCity(Launcher.Map.currentMapID):
		return
	if requestWait > 0 or not CanUse(skillID):
		return
	if not is_instance_valid(Entities.target) or Entities.target.type != ActorCommons.Type.MONSTER or not ActorCommons.IsAlive(Entities.target):
		Entities.Target(Launcher.Player.position, false)
	if not is_instance_valid(Entities.target) or Entities.target.type != ActorCommons.Type.MONSTER:
		status.text = "ไม่พบศัตรูใกล้ตัว"
		return
	var skill : SkillCell = DB.GetSkill(skillID)
	var reach : float = float(ActorCommons.GetSkillRange(Launcher.Player, skill))
	if skill.mode == Skill.TargetMode.SINGLE:
		reach += Launcher.Player.data._radius
	reach += Entities.target.data._radius
	var distance : float = Launcher.Player.position.distance_to(Entities.target.position)
	if distance > maxf(reach * 0.85, 18):
		if Launcher.Action.GetMove() == Vector2.ZERO:
			if not chasing:
				lastChasePosition = Launcher.Player.position
				chaseTime = 0
			chasing = true
			var destination : Vector2 = Entities.target.position.move_toward(Launcher.Player.position, maxf(12, reach * 0.6))
			Network.SetClickPos(destination)
		return
	if chasing:
		Network.ClearNavigation()
		chasing = false
	Launcher.Player.Cast(skillID)
	requestWait = maxf(0.3, skill.castTime + Launcher.Player.stat.current.castAttackDelay + 0.15)
	if not automatic:
		pendingSkill = DB.UnknownHash

func _process(delta : float):
	var inGame : bool = FSM.IsGameState() and is_instance_valid(Launcher.Player)
	visible = inGame and not OverlayOpen() and not Travel.IsFlying(Launcher.Player)
	if not inGame:
		autoMode = AutoMode.OFF
		pendingSkill = DB.UnknownHash
		previousPlayer = null
		return
	if previousPlayer != Launcher.Player or previousMap != Launcher.Map.currentMapID:
		SetAutoMode(AutoMode.OFF)
		cooldowns.clear()
		previousPlayer = Launcher.Player
		previousMap = Launcher.Map.currentMapID
	Launcher.GUI.sticks.actions.hide()
	Launcher.GUI.sticks.buttonRight.hide()
	Launcher.GUI.actionBoxes.hide()
	for skillID in cooldowns:
		cooldowns[skillID] = maxf(0, cooldowns[skillID] - delta)
	requestWait = maxf(0, requestWait - delta)
	if not ReadyForCombat():
		if autoMode != AutoMode.OFF or pendingSkill != DB.UnknownHash:
			SetAutoMode(AutoMode.OFF)
		return
	if Cultivation.IsCity(previousMap):
		if autoMode != AutoMode.OFF:
			SetAutoMode(AutoMode.OFF)
		status.text = "เขตเมืองปลอดภัย • ฝึกนอกประตูใต้"
	elif autoMode == AutoMode.NORMAL:
		status.text = "ออโต: โจมตีปกติ"
	elif autoMode == AutoMode.SKILLS:
		status.text = "ออโต: ใช้สกิลเมื่อพร้อม"
	else:
		status.text = "แตะมอนสเตอร์เพื่อเลือก • กดโจมตี/สกิล"
	if is_instance_valid(Entities.target) and ActorCommons.IsAlive(Entities.target):
		status.text = "เป้าหมาย: %s • Lv.%d" % [tr(Entities.target.nick), Entities.target.stat.level]
	for idx in skillButtons.size():
		var skillID : int = DB.GetCellHash(SKILLS[idx])
		var button : Control = skillButtons[idx]
		if not button.icon:
			button.icon = DB.GetSkill(skillID).icon
		button.cooldown = cooldowns.get(skillID, 0.0)
		button.cooldownMax = cooldownMax.get(skillID, 1.0)
		button.unavailable = not CanUse(skillID) or Cultivation.IsCity(previousMap)
		button.Refresh()
	if not attackButton.icon:
		attackButton.icon = DB.GetSkill(DB.GetCellHash("Melee")).icon
	attackButton.unavailable = Cultivation.IsCity(previousMap)
	attackButton.Refresh()
	# Manual steering cancels queued approach; auto pauses while steering.
	if Launcher.Action.GetMove() != Vector2.ZERO:
		pendingSkill = DB.UnknownHash
		chasing = false
		return
	if chasing:
		chaseTime += delta
		if Launcher.Player.position.distance_to(lastChasePosition) > 12:
			lastChasePosition = Launcher.Player.position
			chaseTime = 0
		elif chaseTime > 4:
			SetAutoMode(AutoMode.OFF)
			status.text = "ไปไม่ถึงเป้าหมาย กรุณาขยับตัวละคร"
			return
	tick += delta
	if tick < 0.3:
		return
	tick = 0
	if pendingSkill != DB.UnknownHash:
		TryCombat(pendingSkill, false)
	elif autoMode == AutoMode.NORMAL or attackButton.held:
		TryCombat(DB.GetCellHash("Melee"), true)
	elif autoMode == AutoMode.SKILLS:
		for skillName in SKILLS:
			var skillID : int = DB.GetCellHash(skillName)
			if CanUse(skillID):
				TryCombat(skillID, true)
				break

func _notification(what : int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		SetAutoMode(AutoMode.OFF)

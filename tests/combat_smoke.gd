extends Node

func _ready():
	run.call_deferred()

func run():
	await get_tree().create_timer(3.0).timeout
	LauncherCommons.isMobile = true
	var sticks = Launcher.GUI.sticks
	sticks.Enable(true)
	var parent_node = sticks.get_parent()
	while parent_node is CanvasItem:
		parent_node.show()
		parent_node = parent_node.get_parent()
	await get_tree().process_frame
	print("SMOKE stick origin=", sticks.defaultStickPosition, " viewport=", get_tree().root.size)
	var center: Vector2 = Vector2(sticks.direction.texture_normal.get_size()) * 0.5
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = sticks.direction.get_global_transform_with_canvas() * (center + Vector2(45, 0))
	sticks._input(touch)
	assert(sticks.touchIndex == 0, "Stick must capture the first finger")
	assert(sticks.GetMove().x > 0.5, "Dragging right must move right")
	var other := InputEventScreenTouch.new()
	other.index = 1
	other.pressed = true
	other.position = Vector2(10000, 10000)
	sticks._input(other)
	assert(sticks.touchIndex == 0, "Second finger must not steal the joystick")
	sticks._press_button(JOY_BUTTON_A)
	assert(sticks.GetMove().x > 0.5, "Attack must not interrupt movement")
	other.pressed = false
	sticks._input(other)
	assert(sticks.leftStickPressed, "Lifting attack finger must not release joystick")
	touch.pressed = false
	sticks._input(touch)
	assert(sticks.GetMove() == Vector2.ZERO, "Lifting joystick finger must stop movement")
	sticks.ReleaseControls()
	assert(sticks.heldButtons.is_empty(), "Focus loss must release all actions")
	print("MOBILE_SMOKE_PASS")
	var login = Launcher.GUI.loginPanel
	login.EnableAccountCreator(true)
	login.nameTextControl.text = "Smoke" + str(randi() % 1000000000)
	login.passwordTextControl.text = "offline-test-only"
	login.confirmPasswordTextControl.text = "offline-test-only"
	login.emailTextControl.text = "test@example.invalid"
	login.CreateAccount()
	await get_tree().create_timer(3.0).timeout
	assert(FSM.currentState == FSM.States.CHAR_SCREEN, "Offline account should reach character screen")
	var character = Launcher.GUI.characterPanel
	character.EnableCharacterCreator(true)
	character.characterNameLineEdit.text = "Tester" + str(randi() % 1000000000)
	character.CreateCharacter()
	await get_tree().create_timer(3.0).timeout
	character.SelectCharacter()
	await get_tree().create_timer(6.0).timeout
	assert(FSM.IsGameState() and Launcher.Player != null, "Offline character should enter the map")
	print("OFFLINE_GAMEPLAY_SMOKE_PASS player=", Launcher.Player.name)
	assert(TranslationServer.get_locale() == "th")
	assert(tr("Inventory") == "กระเป๋า")
	var font = load("res://data/graphics/fonts/Sarabun-Regular.ttf")
	for code in "ภาษาไทยกำลังฝึก":
		assert(font.has_char(code.unicode_at(0)), "Thai glyph missing")
	var guide = Launcher.GUI.get_node("TrainingGuide")
	guide.RefreshObjective()
	assert(guide.visible)
	guide.ToggleGuide()
	assert(guide.panel.visible and "เป้าหมาย:" in guide.objective.text)
	Launcher.GUI.GoBack()
	assert(not guide.panel.visible)
	guide.ToggleGuide()
	guide.OpenInventory()
	assert(Launcher.GUI.inventoryWindow.visible and not guide.panel.visible)
	guide.OpenStats()
	assert(Launcher.GUI.statWindow.visible)
	Launcher.Player.progress.SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.KAEL_MET)
	Launcher.Player.progress.AddBestiary("Maggot".hash(), 5)
	Launcher.Player.progress.AddBestiary("Peyote".hash(), 5)
	guide.RefreshObjective()
	assert("ลานฝึกนอกเมือง" in guide.objective.text)
	print("THAI_TRAINING_SMOKE_PASS")
	assert(Cultivation.Title(1) == "Lv.1 • หลอมกาย • ชั้น 1/10")
	assert(Cultivation.RealmIndex(10) == 0 and Cultivation.Layer(10) == 10)
	assert(Cultivation.RealmIndex(11) == 1 and Cultivation.Layer(11) == 1)
	assert(Cultivation.Title(100) == "Lv.100 • ปรมาจารย์เซียน • ชั้น 10/10")
	assert(Experience.GetNeededExperienceForNextLevel(100) == 0)
	var agent = Peers.GetAgent(NetworkCommons.PeerAuthorityID)
	var sword = DB.GetItem(DB.GetCellHash("Short Sword"))
	assert(agent.inventory.GetEquipmentCell(sword.slot).id == sword.id)
	var before_items = agent.inventory.itemCount
	agent.GiveCultivationStarter(Peers.GetCharacter(agent.peerID))
	assert(agent.inventory.itemCount == before_items)
	for name in ["Mana Burst", "Leaf Blades", "Sonic Scream"]:
		assert(agent.progress.HasSkill(DB.GetSkill(DB.GetCellHash(name))))
		assert(Launcher.Player.progress.HasSkill(DB.GetSkill(DB.GetCellHash(name))))
	for map_name in ["Tulimshar", "Tulimshar Center", "Tulimshar Bay", "Tulimshar West Wall Pathway"]:
		var town = Launcher.World.GetMap(map_name.hash())
		for spawn in town.spawns:
			assert(spawn.type != ActorCommons.Type.MONSTER, "A city still has a monster spawn")
	Launcher.GUI.messageBox.Call(Launcher.GUI.settingsWindow.set_sessionfirstlogin.bind(false))
	var focused = get_viewport().gui_get_focus_owner()
	if focused:
		focused.release_focus()
	Network.TriggerCloseContext()
	await get_tree().create_timer(0.3).timeout
	for window in [Launcher.GUI.statWindow, Launcher.GUI.inventoryWindow]:
		if window.visible:
			window.EnableControl(false)
	await get_tree().create_timer(0.3).timeout
	var hud = Launcher.GUI.get_node("CombatHUD")
	hud.SetAutoMode(hud.AutoMode.NORMAL)
	await get_tree().create_timer(0.6).timeout
	assert(hud.autoMode == hud.AutoMode.OFF, "City must turn auto off")
	get_tree().root.content_scale_size = Vector2i(800, 480)
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	await get_tree().process_frame
	var rect = hud.get_global_rect()
	print("HUD_LAYOUT ", rect, " viewport=", hud.get_viewport_rect())
	assert(rect.position.x >= 0 and rect.position.y >= 0, "Combat controls must be inside the viewport")
	print("COMBAT_READY ", hud.ReadyForCombat(), " overlay=", hud.OverlayOpen(), " action=", Launcher.Action.IsEnabled(), " locks=", Launcher.Action.disableCounter, " dialogue=", Launcher.GUI.IsDialogueContextOpened())
	for window in [Launcher.GUI.inventoryWindow, Launcher.GUI.statWindow, Launcher.GUI.settingsWindow, Launcher.GUI.skillWindow, Launcher.GUI.progressWindow]:
		print("WINDOW ", window.name, " ", window.visible, " ", window.is_visible_in_tree())
	assert(hud.attackButton.icon != null and hud.skillButtons[0].icon != null)
	NpcCommons.Warp(agent, "Sandstorm".hash(), Vector2(3040, 960))
	await get_tree().create_timer(4.0).timeout
	assert(Launcher.Map.currentMapID == "Sandstorm".hash(), "Outdoor map must be reachable before finishing tutorial")
	var field = WorldAgent.GetMapFromAgent(agent)
	assert(field.spawns.any(func(spawn): return spawn.type == ActorCommons.Type.MONSTER and spawn.id == "Peyote".hash()))
	# Actual server damage, skill cooldown, and stopping automation.
	var spawn = SpawnObject.new()
	spawn.map = field
	spawn.id = "Maggot".hash()
	spawn.type = ActorCommons.Type.MONSTER
	spawn.spawn_position = Vector2i(agent.position + Vector2(20, 0))
	var enemy = WorldAgent.CreateAgent(spawn)
	assert(enemy != null)
	await get_tree().create_timer(1.0).timeout
	enemy.stat.health = 500
	enemy.stat.current.maxHealth = 500
	enemy.set_physics_process(false)
	var target = Entities.Get(enemy.get_rid().get_id())
	assert(target != null)
	Entities.SetTarget(target, false)
	hud.SetAutoMode(hud.AutoMode.NORMAL)
	await get_tree().create_timer(3.5).timeout
	assert(enemy.stat.health < 500, "Normal auto must deal real server damage")
	hud.SetAutoMode(hud.AutoMode.OFF)
	await get_tree().create_timer(1.0).timeout
	var stopped_hp = enemy.stat.health
	await get_tree().create_timer(1.5).timeout
	assert(enemy.stat.health == stopped_hp, "Auto off must stop repeated attacks")
	agent.stat.mana = 100
	agent.stat.stamina = 100
	Launcher.Player.stat.mana = 100
	Launcher.Player.stat.stamina = 100
	hud.SetAutoMode(hud.AutoMode.SKILLS)
	await get_tree().create_timer(5.0).timeout
	assert(enemy.stat.health < stopped_hp, "Skill auto must deal real server damage")
	assert(hud.cooldownMax.has(DB.GetCellHash("Mana Burst")), "Skill cooldown must reach mobile HUD")
	hud._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(hud.autoMode == hud.AutoMode.OFF)
	# A second finger must activate a skill while the joystick is held.
	var button = hud.skillButtons[0]
	button.unavailable = false
	sticks.Enable(true)
	touch.pressed = true
	touch.position = sticks.direction.get_global_transform_with_canvas() * (center + Vector2(45, 0))
	sticks._input(touch)
	assert(sticks.GetMove().x > 0.5)
	var down := InputEventScreenTouch.new()
	down.index = 3
	down.pressed = true
	down.position = button.get_global_transform_with_canvas() * (button.size * 0.5)
	button._input(down)
	assert(button.finger == 3 and button.held)
	down.pressed = false
	button._input(down)
	assert(not button.held and button.finger == -1)
	assert(sticks.GetMove().x > 0.5, "Skill release must not stop held movement")
	touch.pressed = false
	sticks._input(touch)
	agent.stat.level = 10
	agent.stat.experience = 0
	agent.stat.AddExperience(Experience.GetNeededExperienceForNextLevel(10), false)
	assert(agent.stat.level == 11 and agent.stat.experience == 0)
	agent.stat.level = 99
	agent.stat.AddExperience(Experience.GetNeededExperienceForNextLevel(99) + 500000, false)
	assert(agent.stat.level == 100 and agent.stat.experience == 0)
	agent.stat.AddExperience(500000, false)
	assert(agent.stat.level == 100 and agent.stat.experience == 0)
	print("CULTIVATION_COMBAT_CITY_PASS")
	# Presentation must animate the whole equipped body, cancel cleanly,
	# exercise every drawing path, and release its capped allocations.
	hud.StopCombat()
	await get_tree().create_timer(2.0).timeout
	var visual = Launcher.Player.visual
	for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		Launcher.Player.entityOrientation = direction
		visual.BeginStrike()
		await get_tree().create_timer(0.08).timeout
		print("STRIKE_CHECK ", direction, " position=", visual.preset.position, " delay=", Launcher.Player.stat.current.castAttackDelay, " type=", Launcher.Player.type, " morph=", Launcher.Player.stat.IsMorph())
		assert(visual.preset.position.length() > 0.1, "Wind-up must move the layered sprite")
		visual.StopStrike()
		assert(visual.preset.position == Vector2.ZERO)
	Launcher.Player.interactive.DisplayCast("Mana Burst".hash())
	assert(is_instance_valid(Launcher.Player.interactive.cultivationCharge))
	Launcher.Player.interactive.DisplayCast(DB.UnknownHash)
	assert(Launcher.Player.interactive.cultivationCharge == null)
	var holder := Node2D.new()
	add_child(holder)
	for effect in ["slash", "hit", "burst", "blades", "wave", "charge"]:
		var fx := CultivationFX.Spawn(holder, Vector2.ZERO, effect, Vector2.RIGHT)
		assert(fx != null)
	await get_tree().create_timer(1.2).timeout
	assert(holder.get_child_count() == 0, "Finished effects must release themselves")
	for i in range(CultivationFX.LIMIT + 5):
		CultivationFX.Spawn(holder, Vector2.ZERO, "hit", Vector2.RIGHT)
	assert(CultivationFX.active <= CultivationFX.LIMIT)
	await get_tree().create_timer(0.5).timeout
	assert(holder.get_child_count() == 0)
	print("CULTIVATION_FX_LIFECYCLE_PASS")
	Launcher.Quit()

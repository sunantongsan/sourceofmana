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
	assert(guide.panel.visible and "ขั้นที่ 1" in guide.objective.text)
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
	assert("5/5" in guide.objective.text)
	print("THAI_TRAINING_SMOKE_PASS")
	assert(Cultivation.Title(1) == "หลอมกาย • ชั้น 1/10")
	assert(Cultivation.RealmIndex(10) == 0 and Cultivation.Layer(10) == 10)
	assert(Cultivation.RealmIndex(11) == 1 and Cultivation.Layer(11) == 1)
	assert(Cultivation.Title(100) == "ปรมาจารย์เซียน • ชั้น 10/10")
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
	var travel = Launcher.GUI.get_node("TravelHUD")
	# Resolve and use every server-owned waypoint through the real HUD/RPC.
	for idx in Travel.POINTS.size():
		var point = Travel.POINTS[idx]
		var map = Launcher.World.GetMap(String(point.map).hash())
		var landing = NavigationServer2D.region_get_closest_point(map.regionRID, point.pos)
		print("WAYPOINT ", idx, " ", point.title, " delta=", landing.distance_to(point.pos))
		assert(landing.distance_to(point.pos) <= 128, "Waypoint must be walkable nearby")
		travel.Warp(idx)
		await get_tree().create_timer(2.5).timeout
		assert(Launcher.Map.currentMapID == map.id)
		assert(agent.position.distance_to(landing) < 20)
		assert(not Travel.IsFlying(agent))
	var previous_pos = agent.position
	Travel.Warp(agent, -1)
	Travel.Warp(agent, 9999)
	assert(agent.position == previous_pos)
	var walk_speed = agent.currentWalkSpeed.x
	travel.Fly()
	await get_tree().create_timer(0.5).timeout
	assert(Travel.IsFlying(agent) and Travel.IsFlying(Launcher.Player))
	assert(Launcher.Player.get_node("SwordFlightVisual").visible)
	assert(Launcher.Player.visual.position.y < -10)
	assert(agent.currentWalkSpeed.x > walk_speed * 2)
	var start = agent.position
	Network.SetMovePos(Vector2.RIGHT)
	await get_tree().create_timer(0.5).timeout
	assert(agent.position.x > start.x + walk_speed * 0.5)
	Network.ClearNavigation()
	var health_before = agent.stat.health
	Skill.Damaged(enemy, agent, DB.GetSkill("Melee".hash()), 1.0)
	assert(agent.stat.health == health_before, "Flight must reject damage")
	assert(not SkillCommons.IsAttackable(agent, enemy, DB.GetSkill("Melee".hash())))
	var flight_map = WorldAgent.GetMapFromAgent(agent)
	# Find a real obstacle in this map, not an assumed roof coordinate.
	var obstacle = Vector2.INF
	for x in range(int(agent.flightBounds.position.x) + 32, int(agent.flightBounds.end.x) - 32, 96):
		for y in range(int(agent.flightBounds.position.y) + 32, int(agent.flightBounds.end.y) - 32, 96):
			var candidate = Vector2(x, y)
			if NavigationServer2D.region_get_closest_point(flight_map.regionRID, candidate).distance_to(candidate) > 100:
				obstacle = candidate
				break
		if obstacle != Vector2.INF:
			break
	assert(obstacle != Vector2.INF)
	agent.position = obstacle
	assert(not Travel.Land(agent), "Must not land inside an obstacle")
	Launcher.SQL.UpdateCharacter(agent)
	var saved = Launcher.SQL.GetCharacter(Peers.GetCharacter(agent.peerID))
	var saved_pos = Vector2(saved.pos_x, saved.pos_y)
	assert(NavigationServer2D.region_get_closest_point(flight_map.regionRID, saved_pos).distance_to(saved_pos) < 2)
	Network.SetMovePos(Vector2.RIGHT)
	await get_tree().create_timer(0.2).timeout
	assert(agent.position.x > obstacle.x, "Flight must cross non-walkable ground")
	Network.ClearNavigation()
	agent.position = agent.flightBounds.end - Vector2(1, 1)
	Network.SetMovePos(Vector2.ONE)
	await get_tree().create_timer(0.2).timeout
	assert(agent.position.x <= agent.flightBounds.end.x and agent.position.y <= agent.flightBounds.end.y)
	Network.ClearNavigation()
	agent.position = NavigationServer2D.region_get_closest_point(flight_map.regionRID, agent.position)
	await get_tree().create_timer(0.3).timeout
	travel.Fly()
	await get_tree().create_timer(0.4).timeout
	assert(not Travel.IsFlying(agent) and not Travel.IsFlying(Launcher.Player))
	assert(is_equal_approx(agent.currentWalkSpeed.x, walk_speed))
	travel.Fly()
	await get_tree().create_timer(0.4).timeout
	assert(Travel.IsFlying(agent))
	travel.Warp(3)
	await get_tree().create_timer(2.5).timeout
	assert(Launcher.Map.currentMapID == "Tulimshar".hash() and not Travel.IsFlying(agent))
	travel.Toggle()
	await get_tree().create_timer(0.1).timeout
	assert(travel.panel.visible and not hud.visible)
	Launcher.GUI.GoBack()
	assert(not travel.panel.visible)
	print("TRAVEL_WAYPOINT_FLIGHT_PASS")
	Launcher.Quit()

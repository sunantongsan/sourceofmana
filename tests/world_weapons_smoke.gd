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
	var shop = Launcher.GUI.get_node("SupplyShopHUD")
	shop.Toggle()
	assert(shop.panel.visible and hud.OverlayOpen())
	Launcher.GUI.GoBack()
	assert(not shop.panel.visible)
	var starting_gold : int = agent.stat.gp
	CommandManager.Handle(agent, "gm g+100000")
	assert(agent.stat.gp == starting_gold + 100000)
	CommandManager.Handle(agent, "gm g+-1")
	assert(agent.stat.gp == starting_gold + 100000)
	CommandManager.Handle(agent, "gm exp100x")
	assert(agent.monsterExpMultiplier == 100)
	CommandManager.Handle(agent, "gm exp1x")
	assert(agent.monsterExpMultiplier == 1)
	var peer = Peers.GetPeer(agent.peerID)
	var permission = peer.permission
	peer.permission = ActorCommons.Permission.NONE
	Network.ENetServer.isOffline = false
	CommandManager.Handle(agent, "gm g+10")
	assert(agent.stat.gp == starting_gold + 100000, "Online non-GM must be rejected even in debug builds")
	Network.ENetServer.isOffline = true
	peer.permission = permission
	for index in SupplyShop.CATALOG.size():
		var product : Dictionary = SupplyShop.CATALOG[index]
		assert(DB.GetItem(String(product.item).hash()) != null, "Shop item missing")
		var before : int = agent.stat.gp
		assert(SupplyShop.Buy(agent, index * 100 + 1))
		assert(agent.stat.gp == before - int(product.price))
	var saved_gold : int = agent.stat.gp
	agent.stat.gp = 0
	assert(not SupplyShop.Buy(agent, 1))
	assert(agent.stat.gp == 0)
	agent.stat.gp = saved_gold
	assert(not SupplyShop.Buy(agent, -1) and not SupplyShop.Buy(agent, 99999))
	assert(is_equal_approx(Launcher.Player.visual.heldWeapon.blade.scale.x, HeldWeapon.LENGTH_SCALE))
	var slots : int = agent.inventory.itemCount
	agent.inventory.itemCount = ActorCommons.InventorySize
	assert(not SupplyShop.Buy(agent, 401))
	assert(agent.stat.gp == saved_gold)
	agent.inventory.itemCount = slots
	print("SHOP_GM_AUTHORITY_PASS")
	NpcCommons.Warp(agent, "Sandstorm".hash(), Vector2(3040, 960))
	await get_tree().create_timer(4.0).timeout
	assert(Launcher.Map.currentMapID == "Sandstorm".hash(), "Outdoor map must be reachable before finishing tutorial")
	assert(not SupplyShop.Buy(agent, 1), "Outdoor purchase must fail")
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
	Entities.ClearTarget()
	var select_touch := InputEventScreenTouch.new()
	select_touch.pressed = true
	select_touch.index = 2
	select_touch.position = target.get_global_transform_with_canvas() * Vector2(0, -18)
	Launcher.Action._unhandled_input(select_touch)
	assert(Entities.target == target, "Touch must select the requested monster")
	print("TOUCH_TARGET_SELECTION_PASS")
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

	# World tiers and growth stay consistent for all 100 persisted levels.
	var stats := ActorStats.new()
	var last_hp := 0
	for rank in range(1, 101):
		stats.level = rank
		stats.RefreshAttributes()
		assert(stats.current.maxHealth > last_hp)
		last_hp = stats.current.maxHealth
		assert(Formula.GetMaxAttributePoints(rank) == 2 + rank * 3)
	assert(stats.current.castAttackDelay >= 0.18)
	assert(ActorCommons.MaxPointPerAttributes == 100)
	# Every visible live monster has its level and HP displayed without selecting it.
	for mob in Entities.entities.values():
		if mob.type == ActorCommons.Type.MONSTER and ActorCommons.IsAlive(mob):
			assert(mob.interactive.healthBar.visible)
			assert("Lv." in mob.interactive.nameLabel.text)
	# Verify real arm/body frame changes, not only effect creation.
	for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		Launcher.Player.entityOrientation = direction
		visual.BeginSpellPose(false)
		await get_tree().create_timer(0.06).timeout
		var initial_frame = visual.sprites[ActorCommons.Slot.BODY].frame
		await get_tree().create_timer(0.18).timeout
		assert(visual.spellPose and not visual.animationTree.active)
		assert(visual.sprites[ActorCommons.Slot.BODY].frame != initial_frame)
		visual.BeginSpellPose(true)
		await get_tree().create_timer(0.4).timeout
		assert(not visual.spellPose and visual.animationTree.active)
	# Kill one persistent mob; it must disappear, pay rewards once, and return at full HP.
	var persistent := SpawnObject.new()
	persistent.map = field
	persistent.id = "Maggot".hash()
	persistent.type = ActorCommons.Type.MONSTER
	persistent.spawn_position = Vector2i(agent.position + Vector2(32, 0))
	persistent.is_persistant = true
	persistent.respawn_delay = 1.3
	var victim = WorldAgent.CreateAgent(persistent)
	await get_tree().create_timer(0.5).timeout
	victim.set_physics_process(false)
	var old_rid = victim.get_rid().get_id()
	agent.stat.level = 50
	agent.stat.experience = 0
	agent.stat.RefreshAttributes()
	CommandManager.Handle(agent, "gm exp100x")
	var expected_exp : int = victim.stat.baseExp * 100
	var old_gold = agent.stat.gp
	victim.AddAttacker(agent, victim.stat.current.maxHealth)
	victim.stat.SetHealth(-victim.stat.health)
	await get_tree().create_timer(1.0).timeout
	assert(WorldAgent.GetAgent(old_rid) == null)
	assert(agent.stat.gp > old_gold)
	assert(agent.stat.experience == expected_exp, "Monster EXP must be exactly x100")
	CommandManager.Handle(agent, "gm exp1x")
	print("MONSTER_GOLD_AND_EXP100_PASS")
	await get_tree().create_timer(1.5).timeout
	var revived = WorldAgent.GetInstanceFromAgent(agent).mobs.filter(func(mob): return mob.spawnInfo == persistent)
	assert(revived.size() == 1)
	assert(revived[0].stat.health == revived[0].stat.current.maxHealth)
	assert(field.spawns.filter(func(sp): return sp.type == ActorCommons.Type.MONSTER).all(func(sp): return sp.respawn_delay == 8.0))
	# Validate all hunting waypoint landings without changing the player's save.
	for point in Travel.POINTS:
		var map = Launcher.World.GetMap(String(point.map).hash())
		assert(map != null, point.map)
		var landing = NavigationServer2D.region_get_closest_point(map.regionRID, point.pos)
		print("HUNTING_WAYPOINT ", point.map, " distance=", landing.distance_to(point.pos), " landing=", landing)
		assert(landing.distance_to(point.pos) <= 128, point.map)
	print("LEVELING_CAST_DEATH_RESPAWN_PASS")
	# Every original map is packaged, navigable, exposed in travel and instantiated.
	var covered : Dictionary = {}
	for point in Travel.POINTS:
		covered[String(point.map).hash()] = true
	assert(covered.size() == 40 and DB.MapsDB.size() == 40)
	for map_id in DB.MapsDB:
		assert(covered.has(map_id))
		var data = DB.MapsDB[map_id]
		var packed : PackedScene = load(data.layersPath)
		assert(packed != null, data._name)
		var layers = packed.instantiate()
		assert(layers.get_child_count() > 0, data._name)
		layers.free()
		var area = Launcher.World.GetMap(map_id)
		var mob_spawns = area.spawns.filter(func(sp): return sp.type == ActorCommons.Type.MONSTER)
		if Hunting.IsHuntingMap(map_id):
			assert(not mob_spawns.is_empty(), data._name)
			var total := 0
			for sp in mob_spawns:
				assert(DB.EntitiesDB.has(sp.id), data._name)
				total += sp.count
			assert(total <= 96, data._name)
			var tier := Hunting.Tier(map_id)
			for mob in area.instances[0].mobs:
				assert(mob.stat.level >= tier.x and mob.stat.level <= tier.y, data._name)
		else:
			assert(mob_spawns.is_empty() and Cultivation.IsCity(map_id), data._name)
		await get_tree().process_frame
	print("ALL_40_MAPS_AND_BALANCED_SPAWNS_PASS")
	# Walking and directional casting retain exactly one visible, equipped weapon.
	var held = visual.heldWeapon
	assert(held.blade.texture == DB.GetItem("Short Sword".hash()).icon)
	for facing in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		Launcher.Player.entityOrientation = facing
		visual.previousState = ActorCommons.State.WALK
		held.source.frame = 1
		held.RefreshPose()
		assert(held.visible and not held.source.visible)
		var hand_start : Vector2 = held.position
		held.source.frame = 2
		held.RefreshPose()
		assert(not held.position.is_equal_approx(hand_start), "Weapon must follow the walking hand")
	held.Equip(null)
	held.RefreshPose()
	assert(not held.visible)
	held.Equip(DB.GetItem("Short Sword".hash()))
	visual.Refresh()
	var flight = Launcher.Player.get_node("SwordFlightVisual")
	assert(flight.scale == Vector2.ONE)
	print("HELD_WEAPON_AND_FLIGHT_SCALE_PASS")
	# Moving out of initial reach during wind-up must still complete a nearby strike.
	hud.SetAutoMode(hud.AutoMode.OFF)
	await get_tree().create_timer(1.0).timeout
	var melee = DB.GetSkill("Melee".hash())
	var moving = revived[0]
	moving.set_physics_process(false)
	moving.stat.health = 5000
	moving.stat.current.maxHealth = 5000
	moving.stat.current.dodgeRate = 0
	agent.stat.stamina = agent.stat.current.maxStamina
	agent.cooldownTimers.clear()
	var range_px : float = ActorCommons.GetSkillRange(agent, melee) + agent.data._radius + moving.data._radius
	var test_direction := Vector2.ZERO
	for axis in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		moving.position = agent.position + axis * (range_px + 20)
		if SkillCommons.IsNear(agent, moving, ActorCommons.GetSkillRange(agent, melee) + 24):
			test_direction = axis
			break
	assert(test_direction != Vector2.ZERO, "Need an unobstructed chase test lane")
	moving.position = agent.position + test_direction * (range_px - 5)
	Skill.Cast(agent, moving, melee)
	assert(agent.meleeCommittedTargetRID == moving.get_rid().get_id())
	moving.position = agent.position + test_direction * (range_px + 20)
	assert(not SkillCommons.IsAttackable(agent, moving, melee))
	assert(Skill.CanFollowThrough(agent, moving, melee))
	await get_tree().create_timer(1.0).timeout
	assert(moving.stat.health < 5000, "A fleeing target must take the committed melee hit")
	Skill.Stopped(agent)
	agent.cooldownTimers.clear()
	moving.position = agent.position + test_direction * (range_px + 120)
	Skill.Cast(agent, moving, melee)
	assert(agent.meleeCommittedTargetRID == 0, "No starting a melee strike from far away")
	assert(not Skill.CanFollowThrough(agent, moving, melee))
	print("MOVING_TARGET_MELEE_AND_RANGE_GUARD_PASS")
	await ExtraChecks(agent)
	Launcher.Quit()

func ExtraChecks(_agent : PlayerAgent):
	pass

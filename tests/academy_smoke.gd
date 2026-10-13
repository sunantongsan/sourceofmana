extends "res://tests/world_weapons_smoke.gd"

func ExtraChecks(agent : PlayerAgent):
	var hud = Launcher.GUI.get_node("CombatHUD")
	hud.SetAutoMode(0)
	Network.ClearNavigation()
	await get_tree().create_timer(1.0).timeout
	# Catalog entries must resolve to distinct packaged items and textures.
	assert(SupplyShop.CATALOG.size() == 14 and SkillTraining.NAMES.size() == 8)
	for index in range(3, 8):
		var skill : SkillCell = DB.GetSkill(SkillTraining.NAMES[index].hash())
		assert(skill.icon and skill.modifiers.Get(CellCommons.Modifier.MAttack) > 0)
		var book : ItemCell = DB.GetItem(("คัมภีร์" + SkillTraining.NAMES[index]).hash())
		assert(book.icon and agent.inventory.GetItem(book))
		var count : int = agent.inventory.GetItem(book).count
		agent.stat.level = 1
		assert(not SkillTraining.Learn(agent, skill.id))
		assert(agent.inventory.GetItem(book).count == count)
		agent.stat.level = 100
		assert(SkillTraining.Learn(agent, skill.id))
		assert(agent.progress.GetSkillLevel(skill) == 1)
		var remaining = agent.inventory.GetItem(book)
		assert((remaining.count if remaining else 0) == count - 1)
		assert(not SkillTraining.Learn(agent, skill.id), "Repeated learning must not spend another book")
		assert(SkillTraining.Equip(agent, index * 10 + index % 3))
		assert(SkillTraining.Equipped(agent, index % 3) == skill.id)
	var solar := DB.GetSkill(SkillTraining.NAMES[7].hash())
	for rank in range(2, 21):
		assert(SkillTraining.Upgrade(agent, solar.id))
	assert(not SkillTraining.Upgrade(agent, solar.id))
	assert(SkillTraining.Points(agent) == 80)
	var imported := ActorProgress.new(agent, true)
	imported.ImportProgress(Peers.GetCharacter(agent.peerID))
	assert(imported.GetSkillLevel(solar) == 20)
	assert(imported.GetQuest(SkillTraining.SlotKey(1)) == solar.id)
	for item_name in ["หินวิญญาณ", "หยก"]:
		var item := DB.GetItem(item_name.hash())
		assert(item.stackable and agent.inventory.GetItem(item).count == 1)
	print("ACADEMY_BOOK_LEARN_UPGRADE_EQUIP_PERSISTENCE_PASS")
	# All five new abilities must damage real enemies, with four AoE attacks.
	var victims : Array[BaseAgent] = []
	for index in 2:
		var spawn := SpawnObject.new()
		spawn.map = WorldAgent.GetMapFromAgent(agent)
		spawn.id = "Maggot".hash()
		spawn.type = ActorCommons.Type.MONSTER
		spawn.spawn_position = Vector2i(agent.position + Vector2(16 + index * 14, 0))
		var victim = WorldAgent.CreateAgent(spawn)
		victim.set_physics_process(false)
		victim.stat.current.maxHealth = 1000000
		victim.stat.health = 1000000
		victim.stat.current.dodgeRate = 0
		victims.append(victim)
	await get_tree().create_timer(0.6).timeout
	for index in range(3, 8):
		var skill := DB.GetSkill(SkillTraining.NAMES[index].hash())
		var hp0 : int = victims[0].stat.health
		var hp1 : int = victims[1].stat.health
		seed(703)
		if skill.mode == Skill.TargetMode.ZONE:
			Skill.HandleZone(agent, agent.position, skill, 1.0)
			assert(victims[1].stat.health < hp1)
		else:
			Skill.Handle(agent, victims[0], skill, 1.0)
		assert(victims[0].stat.health < hp0)
		Launcher.Player.interactive.DisplayCast(skill.id)
		assert(Launcher.Player.visual.spellPose)
		Launcher.Player.interactive.DisplaySkill(Launcher.Player, skill.id, 0)
		var fx := CultivationFX.Spawn(Launcher.Map.currentFringe, agent.position, SkillTraining.EFFECTS[index], Vector2.RIGHT, skill.skillRange)
		assert(fx != null)
		await get_tree().process_frame
	Launcher.Player.interactive.DisplayCast(DB.UnknownHash)
	await get_tree().create_timer(1.1).timeout
	print("FIVE_NEW_DAMAGE_AND_FX_PASS")
	# Temporary locks and unavailable skills must not switch auto off.
	hud.SetAutoMode(hud.AutoMode.NORMAL)
	Launcher.Action.Enable(false)
	await get_tree().create_timer(0.15).timeout
	assert(hud.autoMode == hud.AutoMode.NORMAL)
	Launcher.Action.Enable(true)
	var target : Entity = Entities.Get(victims[0].get_rid().get_id())
	Entities.SetTarget(target, false)
	var before : int = victims[0].stat.health
	await get_tree().create_timer(2.5).timeout
	assert(hud.autoMode == hud.AutoMode.NORMAL and victims[0].stat.health < before)
	hud.SetAutoMode(hud.AutoMode.SKILLS)
	Launcher.Player.stat.mana = 0
	Launcher.Player.stat.stamina = 0
	assert(hud.NextAutoSkill() == "Melee".hash())
	hud.SkipBlockedTarget()
	assert(hud.autoMode == hud.AutoMode.SKILLS)
	assert(not is_instance_valid(Entities.target) or Entities.target != target)
	hud.SetAutoMode(0)
	print("AUTO_PAUSE_RESUME_NO_MANA_RETARGET_PASS")
	# A swipe starting on an upgrade/shop/warp row is a scroll, never a click.
	var character = Launcher.GUI.get_node("CharacterHUD")
	character.Toggle()
	get_tree().root.size = Vector2i(800, 480)
	await get_tree().process_frame
	await get_tree().process_frame
	character.Refresh()
	assert(character.openButton.text == "วิชา / สกิล")
	var menus = Launcher.GUI.get_node("TouchMenus")
	var scroll : ScrollContainer = character.skillScroll
	var start : Vector2 = scroll.get_global_rect().position + Vector2(180, scroll.size.y * 0.8)
	assert(menus.FindScroll(start) == scroll)
	var touch := InputEventScreenTouch.new()
	touch.index = 6
	touch.pressed = true
	touch.position = start
	menus._input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 6
	drag.position = start - Vector2(0, 100)
	menus._input(drag)
	assert(scroll.scroll_vertical >= 90 and menus.dragging)
	touch.pressed = false
	touch.position = drag.position
	menus._input(touch)
	assert(menus.finger == -1 and not menus.dragging)
	var at_release : int = scroll.scroll_vertical
	await get_tree().create_timer(0.08).timeout
	assert(scroll.scroll_vertical > at_release, "Menu should coast after releasing a swipe")
	character.Close()
	await get_tree().process_frame
	assert(menus.activeScroll == null)
	var shop = Launcher.GUI.get_node("SupplyShopHUD")
	shop.Toggle()
	shop.Filter(3)
	assert(shop.selected == 7 and shop.products[7].visible and not shop.products[4].visible)
	shop.Filter(4)
	assert(shop.selected == 12 and shop.itemIcon.texture == DB.GetItem("หินวิญญาณ".hash()).icon)
	await get_tree().process_frame
	assert(shop.panel.get_global_rect().end.y <= shop.get_viewport_rect().end.y)
	shop.Filter(0)
	shop.Select(7)
	await get_tree().process_frame
	var row : Button = shop.products[0]
	var row_center : Vector2 = row.get_global_rect().position + Vector2(50, 24)
	var swipe := InputEventScreenTouch.new()
	swipe.index = 8
	swipe.pressed = true
	swipe.position = row_center
	get_viewport().push_input(swipe)
	await get_tree().process_frame
	var move := InputEventScreenDrag.new()
	move.index = 8
	move.position = row_center - Vector2(0, 100)
	move.relative = Vector2(0, -100)
	get_viewport().push_input(move)
	await get_tree().process_frame
	swipe.pressed = false
	swipe.position = move.position
	get_viewport().push_input(swipe)
	await get_tree().process_frame
	assert(shop.selected == 7, "Swiping a shop row must not select or buy it")
	assert(menus.activeScroll.get_v_scroll_bar().value > 0)
	shop.Close()
	print("TOUCH_SCROLL_INERTIA_ACADEMY_SHOP_PASS")

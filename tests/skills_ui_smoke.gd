extends "res://tests/world_weapons_smoke.gd"

func ExtraChecks(agent : PlayerAgent):
	var hud = Launcher.GUI.get_node("CombatHUD")
	hud.SetAutoMode(0)
	await get_tree().create_timer(1.0).timeout
	var hp = DB.GetItem("Cactus Potion".hash())
	var mp = DB.GetItem("ยาฟื้นปราณ".hash())
	agent.inventory.AddItem(hp, 5)
	agent.inventory.AddItem(mp, 5)
	agent.stat.health = agent.stat.current.maxHealth
	var hp_count : int = agent.inventory.GetItem(hp).count
	assert(not QuickPotion.Use(agent, hp))
	assert(agent.inventory.GetItem(hp).count == hp_count)
	agent.stat.health -= 150
	var before : int = agent.stat.health
	assert(QuickPotion.Use(agent, hp))
	assert(agent.stat.health == before + 100)
	assert(agent.inventory.GetItem(hp).count == hp_count - 1)
	assert(not QuickPotion.Use(agent, hp), "Rapid repeat must not consume another potion")
	agent.stat.mana = 0
	assert(not QuickPotion.Use(agent, mp), "Both quick potions share a cooldown")
	await get_tree().create_timer(1.1).timeout
	agent.stat.mana = 0
	var mp_count : int = agent.inventory.GetItem(mp).count
	assert(QuickPotion.Use(agent, mp))
	assert(agent.stat.mana == mini(100, agent.stat.current.maxMana))
	assert(agent.inventory.GetItem(mp).count == mp_count - 1)
	print("QUICK_POTION_AUTHORITY_PASS")
	var burst = DB.GetSkill("Mana Burst".hash())
	for skill_name in SkillTraining.NAMES:
		agent.progress.AddSkill(DB.GetSkill(skill_name.hash()), 1)
	agent.stat.level = 1
	assert(SkillTraining.Points(agent) == 0)
	assert(not SkillTraining.Upgrade(agent, burst.id))
	assert(not SkillTraining.Upgrade(agent, "Melee".hash()))
	agent.stat.level = 2
	assert(SkillTraining.Upgrade(agent, burst.id))
	assert(SkillTraining.Points(agent) == 0)
	assert(not SkillTraining.Upgrade(agent, burst.id))
	agent.stat.level = 100
	for rank in range(3, 21):
		assert(SkillTraining.Upgrade(agent, burst.id))
	assert(agent.progress.GetSkillLevel(burst) == 20)
	assert(is_equal_approx(SkillTraining.Multiplier(agent, burst), 2.9))
	assert(not SkillTraining.Upgrade(agent, burst.id))
	assert(SkillTraining.Points(agent) == 80)
	var saved : Array[Dictionary] = Launcher.SQL.GetSkills(Peers.GetCharacter(agent.peerID))
	assert(saved.any(func(row): return row.skill_id == burst.id and row.level == 20))
	var restored := ActorProgress.new(agent, true)
	restored.ImportProgress(Peers.GetCharacter(agent.peerID))
	assert(restored.GetSkillLevel(burst) == 20)
	var targets : Array[BaseAgent] = []
	for index in 2:
		var spawn := SpawnObject.new()
		spawn.map = WorldAgent.GetMapFromAgent(agent)
		spawn.id = "Maggot".hash()
		spawn.type = ActorCommons.Type.MONSTER
		spawn.spawn_position = Vector2i(agent.position + Vector2(30 + index * 25, 0))
		var target = WorldAgent.CreateAgent(spawn)
		target.set_physics_process(false)
		target.stat.current.maxHealth = 100000
		target.stat.health = 100000
		target.stat.current.dodgeRate = 0
		targets.append(target)
	var zone = SkillCommons.GetZoneTargets(WorldAgent.GetInstanceFromAgent(agent), agent.position, burst)
	assert(zone.has(targets[0]) and zone.has(targets[1]), "AoE must include multiple nearby enemies")

	seed(4822)
	Skill.HandleZone(agent, agent.position, burst, 1.0)
	assert(targets.all(func(target): return target.stat.health < 100000), "AoE must actually damage both enemies")
	agent.progress.skills[burst.id] = 1
	seed(9354)
	var rank_one : int = SkillCommons.GetDamage(agent, targets[0], burst, 1.0).value
	agent.progress.skills[burst.id] = 20
	seed(9354)
	var rank_twenty : int = SkillCommons.GetDamage(agent, targets[0], burst, 1.0).value
	assert(rank_one > 0 and rank_twenty > rank_one * 2)
	print("SKILL_POINTS_RANK20_PERSISTENCE_AOE_PASS")
	await get_tree().create_timer(0.5).timeout
	Launcher.GUI.sticks._open_inventory()
	assert(Launcher.GUI.inventoryWindow.visible)
	Launcher.GUI.inventoryWindow.EnableControl(false)
	var character = Launcher.GUI.get_node("CharacterHUD")
	character.Toggle()
	assert(character.panel.visible and hud.OverlayOpen())
	character.Refresh()
	assert(character.upgrades[0].disabled)
	assert("20/20" in character.ranks[0].text)
	Launcher.GUI.GoBack()
	assert(not character.panel.visible)
	get_tree().root.size = Vector2i(800, 480)
	var shop = Launcher.GUI.get_node("SupplyShopHUD")
	shop.Toggle()
	await get_tree().process_frame
	for product in shop.products:
		assert(product.icon != null)
	shop.Filter(2)
	assert(shop.selected == 4 and not shop.products[0].visible)
	assert(shop.itemIcon.texture == DB.GetItem("Short Sword".hash()).icon)
	shop.Filter(0)
	shop.Select(1)
	assert(shop.itemIcon.texture == mp.icon)
	assert(shop.panel.get_global_rect().end.y <= shop.get_viewport_rect().end.y)
	assert(shop.buyButtons[0].get_global_rect().end.y <= shop.get_viewport_rect().end.y)
	print("MOBILE_INVENTORY_CHARACTER_SHOP_LAYOUT_PASS viewport=", shop.get_viewport_rect(), " panel=", shop.panel.get_global_rect())
	shop.Close()

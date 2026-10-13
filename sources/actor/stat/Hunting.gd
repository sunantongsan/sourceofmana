extends RefCounted
class_name Hunting

# Fixed world tiers: monsters do not scale up when a stronger player arrives.
const ZONES: Array[Dictionary] = [
	{"map":"Sandstorm", "title":"ลานฝึกนอกเมือง", "min":1, "max":10},
	{"map":"Tulimshar Beach", "title":"ชายฝั่งฝึกปราณ", "min":11, "max":20},
	{"map":"Tulimshar Western Hills", "title":"เนินเขาตะวันตก", "min":21, "max":30},
	{"map":"Tulimshar Eastern Hills", "title":"เนินเขาตะวันออก", "min":31, "max":40},
	{"map":"Tulimshar Southern Hills", "title":"หุบเขาทิศใต้", "min":41, "max":50},
	{"map":"Desert Mines", "title":"เหมืองปราณ", "min":51, "max":60},
	{"map":"Desert Mountains", "title":"ภูเขาทะเลทราย", "min":61, "max":70},
	{"map":"Desert Pit", "title":"หุบเหวอสูร", "min":71, "max":80},
	{"map":"Desert Mountain Cave", "title":"ถ้ำหลอมเซียน", "min":81, "max":90},
	{"map":"Splatyna's Chamber", "title":"ถ้ำปรมาจารย์", "min":91, "max":100},
	{"map": "Drazil", "title": "ป่าดราซิล", "min": 11, "max": 20},
	{"map": "Manayir Beach", "title": "ชายฝั่งมานาเยอร์", "min": 31, "max": 40},
	{"map": "Artis Sewer", "title": "ท่อระบายน้ำอาร์ทิส", "min": 41, "max": 50},
	{"map": "Candor Cave", "title": "ถ้ำแคนดอร์", "min": 21, "max": 30},
	{"map": "Candor Arena", "title": "สนามประลองแคนดอร์", "min": 91, "max": 100},
	{"map": "Ship Hold", "title": "เรือ • ห้องเก็บสินค้า", "min": 1, "max": 10},
	{"map": "Ship Alige Hide", "title": "เรือ • ห้องลับ", "min": 1, "max": 10},
	{"map": "Splatyna's Corridor", "title": "ทางเดินถ้ำปรมาจารย์", "min": 81, "max": 90},
	{"map": "Splatyna's Marvin Hole", "title": "ถ้ำมาร์วิน", "min": 91, "max": 93},
	{"map": "Splatyna's Dorian Dead End", "title": "ถ้ำโดเรียน", "min": 94, "max": 96},
	{"map": "Splatyna's Gabriel Pit", "title": "ถ้ำกาเบรียล", "min": 97, "max": 99},
	{"map": "Snake Pit", "title": "ถ้ำอสรพิษ", "min": 71, "max": 80},
	{"map": "Desert Abandoned Level", "title": "เหมืองร้าง", "min": 51, "max": 60},
	{"map": "Desert Deep Level", "title": "เหมืองลึก", "min": 61, "max": 70},
	{"map": "Tulimshar Western Cave", "title": "ถ้ำตะวันตก", "min": 21, "max": 30}
]

static func Tier(mapID: int) -> Vector2i:
	for zone in ZONES:
		if String(zone.map).hash() == mapID:
			return Vector2i(zone.min, zone.max)
	return Vector2i(1, 100)

static func ApplyMonster(actor: Actor, mapID: int):
	if actor.type != ActorCommons.Type.MONSTER:
		return
	var tier := Tier(mapID)
	var original := maxi(1, int(actor.data._stats.get("level", 1)))
	var rank := tier.x + clampi(roundi(log(float(original + 1)) * 2.7) - 2, 0, tier.y - tier.x)
	if actor.data._isBoss or actor.data._name in ["Marvin", "Dorian", "Gabriel"]:
		rank = tier.y
	if actor.data._name == "Splatyna":
		rank = 100
	actor.stat.level = rank
	actor.stat.baseExp = 8 + rank * 7
	actor.stat.SetEntityStats({"maxHealth":40 + rank * 16, "attack":5 + rank * 3, "mattack":5 + rank * 3, "defense":1 + rank / 2, "mdefense":1 + rank / 2, "regenHealth":0})
	if actor.data._isBoss or actor.data._name in ["Marvin", "Dorian", "Gabriel"]:
		actor.stat.baseExp *= 5
		actor.stat.SetEntityStats({"maxHealth": actor.stat.entityStat.maxHealth * 4})
	actor.stat.health = actor.stat.current.maxHealth
	actor.stat.RefreshVitalStats()

static func Recommended(level: int) -> Dictionary:
	return ZONES[clampi((level - 1) / 10, 0, 9)]

static func Guide() -> String:
	var lines := ""
	for zone in ZONES:
		lines += "Lv.%d–%d  %s\n" % [zone.min, zone.max, zone.title]
	return lines

static func IsHuntingMap(mapID : int) -> bool:
	for zone in ZONES:
		if String(zone.map).hash() == mapID:
			return true
	return false

static func ConfigureSpawns(map : WorldMap):
	if not IsHuntingMap(map.id):
		# All cities, ship hubs and exploration maps stay safe.
		map.spawns = map.spawns.filter(func(spawn): return spawn.type != ActorCommons.Type.MONSTER)
		return
	var monsters : Array[SpawnObject] = []
	for spawn in map.spawns:
		if spawn.type == ActorCommons.Type.MONSTER:
			if not DB.EntitiesDB.has(spawn.id):
				spawn.id = "Sea Slime".hash()
			monsters.append(spawn)
	# Populate previously empty hunting maps with existing animated enemies.
	if monsters.is_empty():
		var species : Array[String] = ["Ratto", "Maggot"]
		if map.name == "Desert Deep Level":
			species = ["Bat", "Skeleton", "Fire Goblin"]
		elif map.name == "Candor Arena":
			species = ["Skeleton", "Fire Skull", "Red Scorpion"]
		for monsterName in species:
			var spawn := SpawnObject.new()
			spawn.map = map
			spawn.id = monsterName.hash()
			spawn.type = ActorCommons.Type.MONSTER
			spawn.count = 6
			spawn.is_global = true
			map.spawns.append(spawn)
			monsters.append(spawn)
	var total := 0
	for spawn in monsters:
		total += spawn.count
	# Avoid hundreds of active agents on low-memory phones, retain regional groups.
	var budget := 96 if Travel.CanFly(map.id) else 64
	if map.name.begins_with("Ship"):
		budget = 12
	for spawn in monsters:
		spawn.count = maxi(1, floori(float(spawn.count) * budget / maxi(total, budget)))
		spawn.is_persistant = true
		spawn.respawn_delay = 8.0

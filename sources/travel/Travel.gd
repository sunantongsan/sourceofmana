extends RefCounted
class_name Travel

# Travel requests share the existing reliable action envelope; coordinates are
# never accepted from the client. The authority resolves this fixed catalogue.
const WARP_ACTION : String = "XianWayWaypoint"
const FLIGHT_ACTION : String = "Flying Sword"
const POINTS : Array[Dictionary] = [
	{"title":"ลานเริ่มต้น • เอลานอร์", "map":"Tulimshar", "pos":Vector2(2189, 2580)},
	{"title":"ลานฝึก • คาเอล", "map":"Tulimshar", "pos":Vector2(2810, 2180)},
	{"title":"ผู้ฝึกสอน • เอคินู", "map":"Tulimshar", "pos":Vector2(1850, 2900)},
	{"title":"ประตูใต้ • ออกล่ามอนสเตอร์", "map":"Tulimshar", "pos":Vector2(1524, 2960)},
	{"title":"ใจกลางเมือง", "map":"Tulimshar Center", "pos":Vector2(1500, 4230)},
	{"title":"ท่าเรือ", "map":"Tulimshar Bay", "pos":Vector2(1440, 3250)},
	{"title":"หน้าปราสาท", "map":"Tulimshar", "pos":Vector2(1450, 1460)},
	{"title":"ลานฝึกนอกเมือง", "map":"Sandstorm", "pos":Vector2(3040, 1050)},
	{"title":"ชายฝั่งฝึกปราณ • Lv.11–20", "map":"Tulimshar Beach", "pos":Vector2(2538, 1141)},
	{"title":"เนินเขาตะวันตก • Lv.21–30", "map":"Tulimshar Western Hills", "pos":Vector2(1556, 3000)},
	{"title":"เนินเขาตะวันออก • Lv.31–40", "map":"Tulimshar Eastern Hills", "pos":Vector2(2293, 3139)},
	{"title":"หุบเขาทิศใต้ • Lv.41–50", "map":"Tulimshar Southern Hills", "pos":Vector2(2022, 1591)},
	{"title":"เหมืองปราณ • Lv.51–60", "map":"Desert Mines", "pos":Vector2(1280, 1216)},
	{"title":"ภูเขาทะเลทราย • Lv.61–70", "map":"Desert Mountains", "pos":Vector2(1790, 1216)},
	{"title":"หุบเหวอสูร • Lv.71–80", "map":"Desert Pit", "pos":Vector2(3061, 3160)},
	{"title":"ถ้ำหลอมเซียน • Lv.81–90", "map":"Desert Mountain Cave", "pos":Vector2(3476, 794)},
	{"title":"ถ้ำปรมาจารย์ • Lv.91–100", "map":"Splatyna's Chamber", "pos":Vector2(1733, 1539)},
	{"title": "เมืองอาร์ทิส • เขตปลอดภัย", "map": "Artis", "pos":Vector2(3584, 2554)},
	{"title": "สนามประลองแคนดอร์ • Lv.91–100", "map": "Candor Arena", "pos":Vector2(1833, 1807)},
	{"title": "ถ้ำแคนดอร์ • Lv.21–30", "map": "Candor Cave", "pos":Vector2(1642, 1524)},
	{"title": "ป่าดราซิล • Lv.11–20", "map": "Drazil", "pos":Vector2(1936, 2458)},
	{"title": "มหาสมุทร • จุดพักเดินทาง", "map": "Ocean", "pos":Vector2(2010, 1815)},
	{"title": "แดนวิญญาณ • สำรวจ", "map": "Overworld", "pos":Vector2(2675, 2490)},
	{"title": "ท่อระบายน้ำอาร์ทิส • Lv.41–50", "map": "Artis Sewer", "pos":Vector2(3126, 2957)},
	{"title": "เรือ • ห้องลับ • Lv.1–10", "map": "Ship Alige Hide", "pos":Vector2(1030, 958)},
	{"title": "เรือ • ดาดฟ้าหลัก", "map": "Ship First Deck", "pos":Vector2(853, 874)},
	{"title": "เรือ • ห้องเก็บสินค้า • Lv.1–10", "map": "Ship Hold", "pos":Vector2(1161, 987)},
	{"title": "เรือ • ห้องกัปตัน", "map": "Ship Nard's Room", "pos":Vector2(830, 854)},
	{"title": "เรือ • ดาดฟ้าชั้นสอง", "map": "Ship Second Deck", "pos":Vector2(1446, 1061)},
	{"title": "ปากถ้ำปรมาจารย์ • จุดพัก", "map": "Splatyna Cave Entrance", "pos":Vector2(1736, 1302)},
	{"title": "ทางเดินถ้ำปรมาจารย์ • Lv.81–90", "map": "Splatyna's Corridor", "pos":Vector2(2125, 2906)},
	{"title": "ถ้ำโดเรียน • Lv.94–96", "map": "Splatyna's Dorian Dead End", "pos":Vector2(1430, 1524)},
	{"title": "ถ้ำกาเบรียล • Lv.97–99", "map": "Splatyna's Gabriel Pit", "pos":Vector2(1152, 1355)},
	{"title": "ถ้ำมาร์วิน • Lv.91–93", "map": "Splatyna's Marvin Hole", "pos":Vector2(1481, 1463)},
	{"title": "ถ้ำอสรพิษ • Lv.71–80", "map": "Snake Pit", "pos":Vector2(2000, 1926)},
	{"title": "ชายฝั่งมานาเยอร์ • Lv.31–40", "map": "Manayir Beach", "pos":Vector2(3974, 3095)},
	{"title": "เมืองมานาเยอร์ • เขตปลอดภัย", "map": "Manayir", "pos":Vector2(2425, 3063)},
	{"title": "เหมืองร้าง • Lv.51–60", "map": "Desert Abandoned Level", "pos":Vector2(1982, 2021)},
	{"title": "เหมืองลึก • Lv.61–70", "map": "Desert Deep Level", "pos":Vector2(1595, 2286)},
	{"title": "ทางเดินปราสาท", "map": "Tulimshar Castle Corridors", "pos":Vector2(2300, 1238)},
	{"title": "ปราสาท • เขตปลอดภัย", "map": "Tulimshar Castle", "pos":Vector2(1797, 1633)},
	{"title": "ห้องปีกตะวันตก", "map": "Tulimshar West Chamber", "pos":Vector2(1301, 1397)},
	{"title": "ทางเดินกำแพงตะวันตก", "map": "Tulimshar West Wall Pathway", "pos":Vector2(2446, 2042)},
	{"title": "ถ้ำตะวันตก • Lv.21–30", "map": "Tulimshar Western Cave", "pos":Vector2(1780, 1930)}
]
const OUTDOORS : Array[String] = ["Tulimshar", "Tulimshar Center", "Tulimshar Bay", "Sandstorm", "Tulimshar Beach", "Tulimshar Western Hills", "Tulimshar Eastern Hills", "Tulimshar Southern Hills", "Desert Mountains", "Manayir", "Manayir Beach", "Artis", "Drazil"]

static func IsFlying(actor : Actor) -> bool:
	return is_instance_valid(actor) and actor.stat.buffs.GetValue(CellCommons.Modifier.Flight) > 0

static func CanFly(mapID : int) -> bool:
	for mapName in OUTDOORS:
		if mapID == mapName.hash():
			return true
	return false

static func Tell(player : PlayerAgent, message : String):
	Network.PushNotification(message, player.peerID)

static func Stop(player : PlayerAgent):
	Skill.Stopped(player)
	player.SetRelativeMode(false, Vector2.ZERO)
	player.ResetNav()
	player.velocity = Vector2.ZERO
	player.currentVelocity = Vector2.ZERO
	player.requireFullUpdate = true

static func Warp(player : PlayerAgent, index : int):
	if not player or not ActorCommons.IsAlive(player) or player.isWarping:
		return
	if index < 0 or index >= POINTS.size():
		return
	if player.ownScript:
		Tell(player, "ปิดบทสนทนาก่อนเดินทาง")
		return
	if Time.get_ticks_msec() < player.travelReadyAt:
		Tell(player, "รอครู่หนึ่งก่อนวาร์ปอีกครั้ง")
		return
	var point : Dictionary = POINTS[index]
	var map : WorldMap = Launcher.World.GetMap(String(point.map).hash())
	if not map or not map.regionRID.is_valid():
		return
	var landing : Vector2 = NavigationServer2D.region_get_closest_point(map.regionRID, point.pos)
	if landing.distance_to(point.pos) > 128:
		Tell(player, "จุดหมายนี้ยังไม่พร้อมใช้งาน")
		return
	Stop(player)
	Land(player, true)
	player.travelReadyAt = Time.get_ticks_msec() + 2000
	NpcCommons.Warp(player, map.id, landing)

static func Bounds(map : WorldMap) -> Rect2:
	var vertices : PackedVector2Array = map.navPoly.get_vertices()
	if vertices.is_empty():
		return Rect2()
	var bounds := Rect2(vertices[0], Vector2.ZERO)
	for vertex in vertices:
		bounds = bounds.expand(vertex)
	return bounds.grow(-8)

static func ToggleFlight(player : PlayerAgent):
	if not player or not ActorCommons.IsAlive(player) or player.isWarping:
		return
	if player.ownScript:
		Tell(player, "ปิดบทสนทนาก่อนขี่กระบี่")
		return
	if IsFlying(player):
		Land(player)
		return
	var map : WorldMap = WorldAgent.GetMapFromAgent(player)
	if not map or not CanFly(map.id) or not map.navPoly:
		Tell(player, "ขี่กระบี่ได้เฉพาะพื้นที่กลางแจ้ง")
		return
	Stop(player)
	player.SetRunning(false)
	player.flightBounds = Bounds(map)
	player.flightGoal = player.position
	player.stat.buffs.Apply(CellCommons.Modifier.Flight, 1, -1, FLIGHT_ACTION.hash(), false)
	Tell(player, "ขึ้นกระบี่แล้ว • ใช้แป้นเดินหรือแตะจุดหมาย • ลงพื้นก่อนต่อสู้")

static func Land(player : PlayerAgent, force : bool = false) -> bool:
	if not IsFlying(player):
		return true
	var map : WorldMap = WorldAgent.GetMapFromAgent(player)
	if not map or not map.regionRID.is_valid():
		return false
	var landing : Vector2 = NavigationServer2D.region_get_closest_point(map.regionRID, player.position)
	if not force and landing.distance_to(player.position) > 64:
		Tell(player, "ยังลงไม่ได้ • บินไปเหนือถนนหรือพื้นที่โล่งก่อน")
		return false
	Stop(player)
	player.position = landing
	player.stat.buffs.Clear(CellCommons.Modifier.Flight)
	player.requireFullUpdate = true
	player.NotifyPosition()
	return true

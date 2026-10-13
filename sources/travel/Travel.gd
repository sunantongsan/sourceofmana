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
	{"title":"ลานฝึกนอกเมือง", "map":"Sandstorm", "pos":Vector2(3040, 1050)}
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

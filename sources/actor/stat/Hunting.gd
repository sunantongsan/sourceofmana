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
	{"map":"Splatyna's Chamber", "title":"ถ้ำปรมาจารย์", "min":91, "max":100}
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
	var rank := clampi(original, 1, 100) if tier.y == 100 and tier.x == 1 else tier.x + mini(original - 1, tier.y - tier.x)
	if actor.data._name == "Splatyna":
		rank = 100
	actor.stat.level = rank
	actor.stat.baseExp = 8 + rank * 7
	actor.stat.SetEntityStats({"maxHealth":40 + rank * 16, "attack":5 + rank * 3, "mattack":5 + rank * 3, "defense":1 + rank / 2, "mdefense":1 + rank / 2, "regenHealth":0})
	if actor.data._isBoss:
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

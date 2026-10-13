extends RefCounted
class_name Cultivation

const REALMS : PackedStringArray = [
	"หลอมกาย", "ฝึกปราณ", "สร้างรากฐาน", "แก่นปราณ", "แก่นทองคำ",
	"ทารกกำเนิด", "ก่อกำเนิดวิญญาณ", "หลอมเซียน", "เซียน", "ปรมาจารย์เซียน"
]
const LAYERS : int = 10
const MAX_LEVEL : int = 100

static func RealmIndex(level : int) -> int:
	return (clampi(level, 1, MAX_LEVEL) - 1) / LAYERS

static func Layer(level : int) -> int:
	return (clampi(level, 1, MAX_LEVEL) - 1) % LAYERS + 1

static func Title(level : int) -> String:
	return "Lv.%d • %s • ชั้น %d/10" % [level, REALMS[RealmIndex(level)], Layer(level)]

static func Roadmap() -> String:
	var result : String = ""
	for idx in REALMS.size():
		result += "%d. %s — ชั้น 1–10\n" % [idx + 1, REALMS[idx]]
	return result

static func IsCity(mapID : int) -> bool:
	for mapName in ["Tulimshar", "Tulimshar Center", "Tulimshar Bay", "Tulimshar Castle", "Tulimshar Castle Corridors", "Tulimshar West Chamber", "Tulimshar West Wall Pathway", "Artis", "Manayir", "Ship First Deck", "Ship Second Deck", "Ship Nard's Room", "Ocean", "Overworld", "Splatyna Cave Entrance"]:
		if mapID == mapName.hash():
			return true
	return false

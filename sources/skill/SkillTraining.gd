extends RefCounted
class_name SkillTraining

const ACTION := "XianWayTrainSkill"
const MAX_RANK := 20
const SHORT_TITLES : Array[String] = ["ปราณม่วง", "กระบี่หยก", "คลื่นคราม", "อัคคี", "อัสนี", "เหมันต์", "วายุ", "สุริยัน"]
const LEARN_ACTION := "XianWayLearnSkill"
const EQUIP_ACTION := "XianWayEquipSkill"
const NAMES : Array[String] = ["Mana Burst", "Leaf Blades", "Sonic Scream", "กระบี่อัคคี", "อัสนีเก้าฟ้า", "บุปผาเหมันต์", "วายุหมุนสวรรค์", "กระบี่สุริยัน"]
const TITLES : Array[String] = ["ปราณม่วงระเบิด", "พายุกระบี่หยก", "กระบี่คลื่นคราม", "กระบี่อัคคี", "อัสนีเก้าฟ้า", "บุปผาเหมันต์", "วายุหมุนสวรรค์", "กระบี่สุริยัน"]

static func Points(actor : Actor) -> int:
	if not actor or not actor.progress:
		return 0
	var spent := 0
	for skill_name in NAMES:
		spent += maxi(0, actor.progress.skills.get(skill_name.hash(), 1) - 1)
	return maxi(0, actor.stat.level - 1 - spent)

static func Multiplier(actor : Actor, skill : SkillCell) -> float:
	if not actor or not actor.progress or not NAMES.any(func(skill_name): return skill_name.hash() == skill.id):
		return 1.0
	var rank : int = clampi(actor.progress.GetSkillLevel(skill), 1, MAX_RANK)
	return 1.0 + (rank - 1) * 0.10

static func Upgrade(player : PlayerAgent, skillID : int) -> bool:
	if not player or not ActorCommons.IsAlive(player) or player.isWarping or player.ownScript:
		return false
	var allowed := false
	for skill_name in NAMES:
		allowed = allowed or skill_name.hash() == skillID
	var skill : SkillCell = DB.GetSkill(skillID) if allowed else null
	if not skill or not player.progress.HasSkill(skill):
		return false
	var rank : int = player.progress.GetSkillLevel(skill)
	if rank >= MAX_RANK or Points(player) < 1:
		Network.CommandFeedback("สกิล: แต้มไม่พอ หรือสกิลถึงขั้น 20 แล้ว", player.peerID)
		return false
	var charID : int = Peers.GetCharacter(player.peerID)
	# Persist the earned level before spending its point; ranks are the spending ledger.
	if not Launcher.SQL.RefreshCharacter(player) or not Launcher.SQL.SetSkill(charID, skillID, rank + 1):
		Network.CommandFeedback("สกิล: บันทึกไม่สำเร็จ กรุณาลองอีกครั้ง", player.peerID)
		return false
	player.progress.AddSkill(skill, rank + 1)
	Network.CommandFeedback("สกิล: อัปเกรดสำเร็จเป็นขั้น %d/20" % (rank + 1), player.peerID)
	return true

const REQUIRED_LEVELS : Array[int] = [1, 1, 1, 5, 10, 15, 20, 25]
const EFFECTS : Array[String] = ["burst", "blades", "wave", "flame", "thunder", "frost", "gale", "solar"]

static func Index(skillID : int) -> int:
	for index in NAMES.size():
		if NAMES[index].hash() == skillID:
			return index
	return -1

static func Learn(player : PlayerAgent, skillID : int) -> bool:
	var index : int = Index(skillID)
	if not player or index < 3 or not ActorCommons.IsAlive(player) or player.isWarping or player.ownScript:
		return false
	var skill : SkillCell = DB.GetSkill(skillID)
	if player.progress.HasSkill(skill):
		Network.CommandFeedback("สกิล: เรียนวิชานี้แล้ว ไม่เสียคัมภีร์เพิ่ม", player.peerID)
		return false
	if player.stat.level < REQUIRED_LEVELS[index]:
		Network.CommandFeedback("สกิล: ต้องมีเลเวล %d" % REQUIRED_LEVELS[index], player.peerID)
		return false
	var book : ItemCell = DB.GetItem(("คัมภีร์" + NAMES[index]).hash())
	var item_index : int = player.inventory.FindItemIndex(book)
	if item_index < 0:
		Network.CommandFeedback("สกิล: ซื้อคัมภีร์วิชานี้จากร้านเสบียงก่อน", player.peerID)
		return false
	var charID : int = Peers.GetCharacter(player.peerID)
	if not Launcher.SQL.RefreshCharacter(player) or not Launcher.SQL.SetSkill(charID, skillID, 1):
		return false
	if not player.inventory.RemoveItem(book, 1, item_index):
		Launcher.SQL.SetSkill(charID, skillID, 0)
		return false
	player.progress.AddSkill(skill, 1)
	Network.CommandFeedback("สกิล: เรียน " + TITLES[index] + " สำเร็จ • เลือกใส่ช่อง 1–3 ได้เลย", player.peerID)
	return true

static func SlotKey(slot : int) -> int:
	return ("XianWaySkillSlot%d" % slot).hash()

static func Equipped(actor : Actor, slot : int) -> int:
	var saved : int = actor.progress.GetQuest(SlotKey(slot))
	if Index(saved) >= 0 and actor.progress.skills.get(saved, 0) > 0:
		return saved
	return NAMES[slot].hash()

static func Equip(player : PlayerAgent, request : int) -> bool:
	var index : int = request / 10
	var slot : int = request % 10
	if not player or request < 0 or index >= NAMES.size() or slot >= 3:
		return false
	var skillID : int = NAMES[index].hash()
	if not player.progress.HasSkill(DB.GetSkill(skillID)):
		return false
	# Swapping preserves three distinct assigned skills.
	var old : int = Equipped(player, slot)
	for other in 3:
		if other != slot and Equipped(player, other) == skillID:
			player.progress.SetQuest(SlotKey(other), old)
	player.progress.SetQuest(SlotKey(slot), skillID)
	Network.CommandFeedback("สกิล: ใส่ %s ในช่อง %d แล้ว" % [TITLES[index], slot + 1], player.peerID)
	return true

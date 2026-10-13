extends RefCounted
class_name SkillTraining

const ACTION := "XianWayTrainSkill"
const MAX_RANK := 20
const NAMES : Array[String] = ["Mana Burst", "Leaf Blades", "Sonic Scream"]
const TITLES : Array[String] = ["ปราณม่วงระเบิด", "พายุกระบี่หยก", "กระบี่คลื่นคราม"]

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

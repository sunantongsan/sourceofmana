extends NpcScript

const FIELD_POSITION : Vector2 = Vector2(2912, 1312)

func OnStart():
	var state : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if state < ProgressCommons.TUTORIAL.ELANORE_DONE:
		Mes("ขั้นที่ 1: รับชุดเริ่มต้นจากเอลานอร์ก่อน แล้วเปิดกระเป๋าเพื่อสวมใส่")
		LookAtNpc("Elanore")
		ResetCamera()
	elif state == ProgressCommons.TUTORIAL.ELANORE_DONE:
		OnFieldCleanUp()
	elif state == ProgressCommons.TUTORIAL.KAEL_MET:
		OnCheckProgress()
	else:
		Mes("ฝึกต่อได้โดยล่าศัตรูที่สู้ไหว เก็บของ และจัดแต้มเมื่อระดับเพิ่ม")
		Choice("ทบทวนวิธีต่อสู้", OnFightTutorial)
		Choice("ไปฝึกต่อ", Farewell)

func OnFieldCleanUp():
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.KAEL_MET)
	AddItem(DB.GetCellHash("Short Sword"))
	Mes("ขั้นที่ 2: ได้รับดาบสั้นแล้ว เปิดกระเป๋า เลือกดาบ แล้วกดสวมใส่")
	OnFightTutorial()
	LookAtPosition(FIELD_POSITION)
	Mes("ขั้นที่ 3: กำจัดกระบองเพชรเดินได้ 5 ตัว และหนอนทราย 5 ตัวบริเวณนี้ แล้วกลับมารับค่าประสบการณ์ 20 หน่วย")
	ResetCamera()
	npc.ownScript.TrackPlayer(own)

func OnCheckProgress():
	var tracker : KaelGlobal = npc.ownScript as KaelGlobal
	tracker.TrackPlayer(own)
	var cactus : int = tracker.GetKillCount(own, tracker.peyoteID)
	var maggot : int = tracker.GetKillCount(own, tracker.maggotID)
	if cactus >= KaelGlobal.PEYOTE_REQUIRED and maggot >= KaelGlobal.MAGGOT_REQUIRED:
		SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.KAEL_DONE)
		AddExp(20)
		Mes("ฝึกสำเร็จ! ได้รับค่าประสบการณ์ 20 หน่วย\nต่อไป: พบเอคินูที่ประตูเมืองเพื่อรับอุปกรณ์เพิ่ม")
		LookAtNpc("Ekinu")
		ResetCamera()
		npc.ownScript.UntrackPlayer(own)
		ClearTracker()
	else:
		Mes("ความคืบหน้า: กระบองเพชร %d/5 • หนอน %d/5\nกำจัดให้ครบแล้วกลับมารับรางวัล" % [mini(cactus, 5), mini(maggot, 5)])
		Choice("ทบทวนวิธีต่อสู้", OnFightTutorial)
		Choice("ไปฝึกต่อ", Farewell)

func OnFightTutorial():
	DisplayActions(["gp_interact", "gp_target", "gp_sit"])
	Narrate("มือถือ: A โจมตีศัตรูใกล้ตัว • R เปลี่ยนเป้าหมาย • L เก็บของ\nทุกการโจมตีใช้ความอึด หากหมดให้ถอยแล้วกด Y นั่งพัก")
	Narrate("กำจัดศัตรูเพื่อรับค่าประสบการณ์ เมื่อระดับเพิ่ม เปิดค่าสถานะ → กด + → ดูค่าพลังที่เปลี่ยน → กดบันทึก")

func Farewell():
	pass

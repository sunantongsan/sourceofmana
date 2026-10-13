extends NpcScript

func OnStart():
	var state : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if state < ProgressCommons.TUTORIAL.ELANORE_DONE:
		Mes("เริ่มฝึก: รับชุดจากเอลานอร์ แล้วสวมใส่ในกระเป๋า")
		LookAtNpc("Elanore")
		ResetCamera()
	elif state < ProgressCommons.TUTORIAL.KAEL_DONE:
		Mes("ฝึกต่อสู้กับคาเอลก่อน: กำจัดกระบองเพชรและหนอนอย่างละ 5 ตัว แล้วกลับไปรับรางวัล")
		LookAtNpc("Kael")
		ResetCamera()
	elif state < ProgressCommons.TUTORIAL.EKINU_DONE:
		OnJobExplanation()
	else:
		OnComplete()

func OnSkipTutorial():
	Mes("ก่อนออกนอกเมือง ควรสวมดาบและชุดให้ครบ ศัตรูด้านนอกแข็งแกร่งขึ้น")
	Choice("กลับไปฝึกพื้นฐาน", OnStart)
	Choice("พร้อมออกสำรวจ", OnJobExplanation)

func OnJobExplanation():
	var state : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if state < ProgressCommons.TUTORIAL.EKINU_DONE:
		AddItem(DB.GetCellHash("Desert Boots"))
		AddItem(DB.GetCellHash("Desert Goggles"))
		if state < ProgressCommons.TUTORIAL.KAEL_MET:
			AddItem(DB.GetCellHash("Short Sword"))
		SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.EKINU_DONE)
		AddExp(20)
		Mes("ได้รับรองเท้า แว่นกันทราย และค่าประสบการณ์ 20 หน่วย\nเปิดกระเป๋าแล้วสวมอุปกรณ์ใหม่ เปรียบเทียบค่าพลังกับของเดิมก่อนเปลี่ยน")
		HighlightUI(UICommons.UITarget.STAT)
		Narrate("ขั้นที่ 4: เปิดค่าสถานะ ดูแต้มที่เหลือ กด + เพื่อทดลองจัดแต้ม แล้วกดบันทึกเพื่อใช้จริง\nกำลังเพิ่มโจมตี • พละกำลังเพิ่มชีวิตและป้องกัน • ความทนทานเพิ่มความอึด")
		HighlightUI(UICommons.UITarget.NONE)
	if GetQuest(ProgressCommons.Quest.MINE_EXPLORATION) < ProgressCommons.MINE_EXPLORATION.STARTED:
		SetQuest(ProgressCommons.Quest.MINE_EXPLORATION, ProgressCommons.MINE_EXPLORATION.STARTED)
	Mes("ต่อจากนี้: ฝึกกับศัตรูที่สู้ไหว → เก็บของ → เปลี่ยนอุปกรณ์ → จัดแต้ม\nเมื่อพร้อม ค่อยออกทางใต้ไปสำรวจเหมือง เปิดปุ่ม ‘ฝึกตน’ เพื่อดูคู่มือได้เสมอ")

func OnComplete():
	Mes("พัฒนาต่อ: ล่าศัตรูรับค่าประสบการณ์ เก็บของ จัดแต้ม และเปรียบเทียบอุปกรณ์\nหากเสียชีวิตบ่อย ให้ฝึกในเมืองและเพิ่มพละกำลังก่อน")
	DisplayActions(["gp_run", "gp_sit"])
	Narrate("มือถือ: X วิ่งหนีเมื่ออันตราย • Y นั่งพักในที่ปลอดภัย\nการวิ่งใช้ความอึด เก็บไว้ให้พอต่อสู้ด้วย")

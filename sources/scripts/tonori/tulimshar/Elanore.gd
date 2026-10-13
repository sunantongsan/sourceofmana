extends NpcScript

func OnStart():
	var state : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if state < ProgressCommons.TUTORIAL.INTRO_ITEMS_GIVEN:
		AddItem(DB.GetCellHash("Water Bottle"))
		AddItem(DB.GetCellHash("Cactus Sour Candy"))
	if state < ProgressCommons.TUTORIAL.CLOTHES_GIVEN:
		AddItem(DB.GetCellHash("Cotton Shirt"), 1, "Used")
		AddItem(DB.GetCellHash("Shorts"), 1, "Used")
	if state < ProgressCommons.TUTORIAL.ELANORE_DONE:
		Mes("วิถีเซียนเริ่มจากการลงมือฝึก
ขั้นที่ 1: ได้รับเสื้อและกางเกงแล้ว เปิดกระเป๋า เลือกของ แล้วกดสวมใส่")
		HighlightUI(UICommons.UITarget.INVENTORY)
		Narrate("อุปกรณ์ช่วยเพิ่มความสามารถ ตรวจค่าพลังก่อนสวมใส่
อาหารและยาใช้ฟื้นพลัง เลือกของในกระเป๋าแล้วกดใช้")
		HighlightUI(UICommons.UITarget.HEALTHBAR)
		Narrate("ดูพลังชีวิตก่อนสู้ หากใกล้หมดให้ถอย
ความอึดใช้โจมตีและวิ่ง นั่งพักในที่ปลอดภัยเพื่อฟื้นตัว")
		HighlightUI(UICommons.UITarget.NONE)
		SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.ELANORE_DONE)
		OnSendToKael()
	else:
		OnMainChoice()

func GetPotionBatchCount() -> int:
	var maggotSlimeID : int = DB.GetCellHash("Maggot Slime")
	var waterBottleID : int = DB.GetCellHash("Water Bottle")
	var pitayaID : int = DB.GetCellHash("Pitaya")

	var batchCount : int = 0
	while HasItem(maggotSlimeID, (batchCount + 1) * 6) and HasItem(waterBottleID, batchCount + 1) and HasItem(pitayaID, batchCount + 1):
		batchCount += 1
	return batchCount

func OnMainChoice():
	if GetQuest(ProgressCommons.Quest.TUTORIAL) < ProgressCommons.CompletedProgress:
		Choice("เป้าหมายต่อไป", OnDirections)

	var potionQuestState : int = GetQuest(ProgressCommons.Quest.ELANORE_POTION)
	var hasPotionIngredients : bool = GetPotionBatchCount() > 0
	match potionQuestState:
		ProgressCommons.ELANORE_POTION.INACTIVE:
			Choice("เรียนปรุงยาฟื้นพลัง", OnHelpWithPotions)
		ProgressCommons.ELANORE_POTION.STARTED:
			if hasPotionIngredients:
				Choice("ส่งวัตถุดิบปรุงยา", OnPotionQuestTurnIn)
			else:
				Choice("ดูสูตรปรุงยา", OnPotionQuestReminder)
		ProgressCommons.ELANORE_POTION.BREWED:
			if hasPotionIngredients:
				Choice("ปรุงยาเพิ่ม", OnPotionQuestTurnIn)
			else:
				Choice("ดูสูตรปรุงยา", OnPotionQuestReminder)

	Choice("ไปฝึกต่อ", Farewell)

	if GetQuest(ProgressCommons.Quest.TUTORIAL) == ProgressCommons.CompletedProgress:
		Choice("ไปฝึกต่อ", Farewell)

# Help with potions
func OnHelpWithPotions():
	Mes("บทฝึกเสริม: เก็บของจากมอนสเตอร์มาแลกยาฟื้นพลัง")
	Mes("สูตร: เมือกหนอน 6 ชิ้น + ขวดน้ำ 1 ขวด + แก้วมังกร 1 ผล → ยากระบองเพชร 1 ขวด")
	Choice("รับบทฝึกปรุงยา", OnPotionQuestAccept)
	Choice("ไว้ภายหลัง", OnPotionQuestDecline)

func OnPotionQuestAccept():
	Mes("เก็บเมือกหนอน 6 ชิ้น ขวดน้ำ 1 ขวด และแก้วมังกร 1 ผล แล้วกลับมาแลกยา")
	SetQuest(ProgressCommons.Quest.ELANORE_POTION, ProgressCommons.ELANORE_POTION.STARTED)
	Action(OnMainChoice)

func OnPotionQuestDecline():
	Mes("กลับมาเรียนเมื่อพร้อมได้เสมอ")
	Action(OnMainChoice)

func OnPotionQuestReminder():
	Mes("วัตถุดิบต่อยา 1 ขวด: เมือกหนอน 6 ชิ้น + ขวดน้ำ 1 ขวด + แก้วมังกร 1 ผล")
	OnMainChoice()

func OnPotionQuestTurnIn():
	var batchCount : int = GetPotionBatchCount()
	if batchCount > 1:
		Mes("วัตถุดิบพอปรุงยาได้ %d ขวด ต้องการกี่ขวด?" % batchCount)
		Choice("1 ขวด", OnPotionBrew.bind(1))
		Choice("ทั้งหมด %d ขวด" % batchCount, OnPotionBrew.bind(batchCount))
	else:
		OnPotionBrew(1)

func OnPotionBrew(brewCount : int):
	var removeItems : Array = [[DB.GetCellHash("Maggot Slime"), 6 * brewCount], [DB.GetCellHash("Water Bottle"), brewCount], [DB.GetCellHash("Pitaya"), brewCount]]
	ExchangeItems(removeItems, [[DB.GetCellHash("Cactus Potion"), brewCount]], OnPotionBrewed)

func OnPotionBrewed(result : ActorInventory.ExchangeResult):
	match result:
		ActorInventory.ExchangeResult.OK:
			var isFirstBrew : bool = GetQuest(ProgressCommons.Quest.ELANORE_POTION) == ProgressCommons.ELANORE_POTION.STARTED
			SetQuest(ProgressCommons.Quest.ELANORE_POTION, ProgressCommons.ELANORE_POTION.BREWED)
			if isFirstBrew:
				Mes("ปรุงยาสำเร็จ! เปิดกระเป๋า เลือกยา แล้วกดใช้เมื่อพลังชีวิตลด")
				Mes("เก็บวัตถุดิบมาปรุงเพิ่มได้ เพื่อออกฝึกได้นานขึ้น")
			else:
				Mes("ได้รับยาแล้ว ใช้จากกระเป๋าได้")
			Action(OnPotionBrewedChoice)
		ActorInventory.ExchangeResult.MISSING_ITEMS:
			Mes("วัตถุดิบไม่ครบ ตรวจในกระเป๋าอีกครั้ง")
			Action(OnMainChoice)
		ActorInventory.ExchangeResult.NO_SPACE:
			Mes("กระเป๋าเต็ม จัดพื้นที่ว่างก่อนรับยา")
			Action(OnMainChoice)

func OnPotionBrewedChoice():
	Choice("ดูบทฝึกอื่น", OnMainChoice)
	Choice("ไปฝึกต่อ", Farewell)

func Farewell():
	pass

func OnDirections():
	if GetQuest(ProgressCommons.Quest.TUTORIAL) < ProgressCommons.TUTORIAL.KAEL_DONE:
		OnSendToKael()
	else:
		Mes("พบเอคินูที่ประตูเมืองเพื่อรับอุปกรณ์และเรียนจัดแต้ม")
		LookAtNpc("Ekinu")
		ResetCamera()

func OnSendToKael():
	Mes("เป้าหมายต่อไป: รับดาบและฝึกต่อสู้กับคาเอล ทางตะวันออกเฉียงเหนือข้างแปลงกระบองเพชร")
	LookAtNpc("Kael")
	ResetCamera()

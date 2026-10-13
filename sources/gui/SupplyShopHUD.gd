extends Control

var panel : PanelContainer
var balance : Label
var feedback : Label
var command : LineEdit
var openButton : Button
var readyAt : int = 0
var selected := 0
var products : Array[Button] = []
var itemIcon : TextureRect
var itemTitle : Label
var itemDetail : Label
var buyButtons : Array[Button] = []
var gmrow : HBoxContainer
var elapsed := 0.0

func _ready():
	name = "SupplyShopHUD"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = RPGTheme.Create()
	openButton = Button.new()
	openButton.text = "ร้านเสบียง"
	openButton.position = Vector2(10, 105)
	openButton.custom_minimum_size = Vector2(130, 44)
	openButton.pressed.connect(Toggle)
	add_child(openButton)
	panel = PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 20
	panel.offset_right = -20
	panel.offset_top = 35
	panel.offset_bottom = -20
	var column := VBoxContainer.new()
	column.add_child(BuildHeader())
	panel.add_child(column)
	balance = RPGTheme.Text("")
	column.add_child(balance)
	var categories := HBoxContainer.new()
	column.add_child(categories)
	for index in 5:
		var category := Button.new()
		category.text = ["ทั้งหมด", "ยาฟื้นฟู", "อุปกรณ์", "คัมภีร์", "วัตถุดิบ"][index]
		category.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		category.custom_minimum_size.y = 40
		category.pressed.connect(Filter.bind(index))
		categories.add_child(category)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for index in SupplyShop.CATALOG.size():
		var product : Dictionary = SupplyShop.CATALOG[index]
		var cell : ItemCell = DB.GetItem(String(product.item).hash())
		var row := Button.new()
		row.text = "%s\n%d G" % [String(product.title).split(" • ")[0], product.price]
		row.icon = cell.icon
		row.expand_icon = true
		row.add_theme_constant_override("icon_max_width", 40)
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.custom_minimum_size.y = 60
		row.pressed.connect(Select.bind(index))
		list.add_child(row)
		products.append(row)
	var detailsScroll := ScrollContainer.new()
	detailsScroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detailsScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(detailsScroll)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detailsScroll.add_child(details)
	itemIcon = RPGTheme.Icon(null, 72)
	details.add_child(itemIcon)
	itemTitle = RPGTheme.Text("", 20)
	details.add_child(itemTitle)
	itemDetail = RPGTheme.Text("")
	details.add_child(itemDetail)
	var buyrow := HBoxContainer.new()
	column.add_child(buyrow)
	for count in [1, 10]:
		var buy := Button.new()
		buy.custom_minimum_size.y = 46
		buy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy.pressed.connect(func(): Buy(selected, count))
		buyrow.add_child(buy)
		buyButtons.append(buy)
	feedback = RPGTheme.Text("เลือกสินค้าเพื่อดูรายละเอียด • ล่ามอนสเตอร์เพื่อรับเงิน G", 14)
	column.add_child(feedback)
	gmrow = HBoxContainer.new()
	column.add_child(gmrow)
	command = LineEdit.new()
	command.placeholder_text = "gm g+1000 / gm exp100x / gm exp1x"
	command.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command.text_submitted.connect(RunGM)
	gmrow.add_child(command)
	var send := Button.new()
	send.text = "ส่ง GM"
	send.custom_minimum_size = Vector2(88, 44)
	send.pressed.connect(func(): RunGM(command.text))
	gmrow.add_child(send)
	gmrow.hide()
	Select(0)
	panel.hide()

func BuildHeader() -> HBoxContainer:
	var header := HBoxContainer.new()
	var title := RPGTheme.Text("ร้านเสบียง • เตรียมตัวออกผจญภัย", 22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var gm := Button.new()
	gm.text = "GM"
	gm.custom_minimum_size = Vector2(58, 44)
	gm.pressed.connect(func(): gmrow.visible = not gmrow.visible)
	header.add_child(gm)
	var close := Button.new()
	close.text = "ปิด ×"
	close.custom_minimum_size = Vector2(80, 44)
	close.pressed.connect(Close)
	header.add_child(close)
	return header

func Filter(category : int):
	var first := -1
	for index in products.size():
		products[index].visible = category == 0 or SupplyShop.Category(index) == category
		if products[index].visible and first < 0:
			first = index
	if not products[selected].visible:
		Select(first)

func Select(index : int):
	selected = index
	for idx in products.size():
		products[idx].modulate = Color("c4e1f6") if idx == index else Color.WHITE
	RefreshProduct()

func RefreshProduct():
	var product : Dictionary = SupplyShop.CATALOG[selected]
	var cell : ItemCell = DB.GetItem(String(product.item).hash())
	itemIcon.texture = cell.icon
	itemTitle.text = String(product.title).split(" • ")[0]
	var count := 0
	if is_instance_valid(Launcher.Player):
		var item = Launcher.Player.inventory.GetItem(cell)
		count = item.count if item else 0
	itemDetail.text = "%s\n\nราคา %d G ต่อชิ้น\nในกระเป๋า %d ชิ้น\n%s" % [product.title, product.price, count, cell.description if selected >= 7 else ("ใช้จากปุ่มเลือด / ปราณ หรือกระเป๋า" if selected < 4 else "สวมใส่จากกระเป๋าเพื่อเพิ่มค่าสถานะ")]
	for idx in buyButtons.size():
		var quantity : int = 1 if idx == 0 else 10
		var cost : int = product.price * quantity
		buyButtons[idx].text = "ซื้อ ×%d • %d G" % [quantity, cost]
		buyButtons[idx].disabled = not is_instance_valid(Launcher.Player) or not Cultivation.IsCity(Launcher.Map.currentMapID) or Launcher.Player.stat.gp < cost

func Toggle():
	if panel.visible:
		Close()
		return
	Launcher.GUI.get_node("CharacterHUD").Close()
	Launcher.GUI.get_node("TravelHUD").Close()
	Launcher.GUI.get_node("TrainingGuide").CloseGuide()
	Launcher.GUI.get_node("CombatHUD").StopCombat()
	Network.ClearNavigation()
	Launcher.GUI.sticks.ReleaseControls()
	Launcher.GUI.sticks.hide()
	readyAt = Time.get_ticks_msec() + 150
	panel.show()
	RefreshProduct()

func Close():
	if panel.visible:
		command.release_focus()
		panel.hide()
		Launcher.GUI.sticks.show()

func Buy(index : int, count : int):
	if Time.get_ticks_msec() < readyAt:
		return
	readyAt = Time.get_ticks_msec() + 200
	Network.TriggerSkill(index * 100 + count, SupplyShop.ACTION.hash())

func RunGM(value : String):
	if not value.strip_edges().to_lower().begins_with("gm "):
		feedback.text = "GM: ใช้ gm g+1000 / gm exp100x / gm exp1x"
		return
	Network.TriggerCommand(value.strip_edges())
	command.clear()
	command.release_focus()

func _process(delta : float):
	visible = FSM.IsGameState() and is_instance_valid(Launcher.Player)
	if not visible:
		Close()
		return
	openButton.disabled = not Network.Client or not Network.Client.isOffline or Launcher.GUI.IsDialogueContextOpened()
	balance.text = "เงิน %d G • %s" % [Launcher.Player.stat.gp, "เขตเมือง • ซื้อสินค้าได้" if Cultivation.IsCity(Launcher.Map.currentMapID) else "กลับเมืองเพื่อซื้อสินค้า"]
	elapsed += delta
	if panel.visible and elapsed >= 0.2:
		elapsed = 0
		RefreshProduct()

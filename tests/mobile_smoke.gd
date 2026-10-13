extends Node

func _ready():
	run.call_deferred()

func run():
	await get_tree().create_timer(3.0).timeout
	LauncherCommons.isMobile = true
	var sticks = Launcher.GUI.sticks
	sticks.Enable(true)
	var parent_node = sticks.get_parent()
	while parent_node is CanvasItem:
		parent_node.show()
		parent_node = parent_node.get_parent()
	await get_tree().process_frame
	print("SMOKE stick origin=", sticks.defaultStickPosition, " viewport=", get_tree().root.size)
	var center: Vector2 = Vector2(sticks.direction.texture_normal.get_size()) * 0.5
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = sticks.direction.get_global_transform_with_canvas() * (center + Vector2(45, 0))
	sticks._input(touch)
	assert(sticks.touchIndex == 0, "Stick must capture the first finger")
	assert(sticks.GetMove().x > 0.5, "Dragging right must move right")
	var other := InputEventScreenTouch.new()
	other.index = 1
	other.pressed = true
	other.position = Vector2(10000, 10000)
	sticks._input(other)
	assert(sticks.touchIndex == 0, "Second finger must not steal the joystick")
	sticks._press_button(JOY_BUTTON_A)
	assert(sticks.GetMove().x > 0.5, "Attack must not interrupt movement")
	other.pressed = false
	sticks._input(other)
	assert(sticks.leftStickPressed, "Lifting attack finger must not release joystick")
	touch.pressed = false
	sticks._input(touch)
	assert(sticks.GetMove() == Vector2.ZERO, "Lifting joystick finger must stop movement")
	sticks.ReleaseControls()
	assert(sticks.heldButtons.is_empty(), "Focus loss must release all actions")
	print("MOBILE_SMOKE_PASS")
	var login = Launcher.GUI.loginPanel
	login.EnableAccountCreator(true)
	login.nameTextControl.text = "Smoke" + str(randi() % 1000000000)
	login.passwordTextControl.text = "offline-test-only"
	login.confirmPasswordTextControl.text = "offline-test-only"
	login.emailTextControl.text = "test@example.invalid"
	login.CreateAccount()
	await get_tree().create_timer(3.0).timeout
	assert(FSM.currentState == FSM.States.CHAR_SCREEN, "Offline account should reach character screen")
	var character = Launcher.GUI.characterPanel
	character.EnableCharacterCreator(true)
	character.characterNameLineEdit.text = "Tester" + str(randi() % 1000000000)
	character.CreateCharacter()
	await get_tree().create_timer(3.0).timeout
	character.SelectCharacter()
	await get_tree().create_timer(6.0).timeout
	assert(FSM.IsGameState() and Launcher.Player != null, "Offline character should enter the map")
	print("OFFLINE_GAMEPLAY_SMOKE_PASS player=", Launcher.Player.name)
	assert(TranslationServer.get_locale() == "th")
	assert(tr("Inventory") == "กระเป๋า")
	var font = load("res://data/graphics/fonts/Sarabun-Regular.ttf")
	for code in "ภาษาไทยกำลังฝึก":
		assert(font.has_char(code.unicode_at(0)), "Thai glyph missing")
	var guide = Launcher.GUI.get_node("TrainingGuide")
	guide.RefreshObjective()
	assert(guide.visible)
	guide.ToggleGuide()
	assert(guide.panel.visible and "ขั้นที่ 1" in guide.objective.text)
	Launcher.GUI.GoBack()
	assert(not guide.panel.visible)
	guide.ToggleGuide()
	guide.OpenInventory()
	assert(Launcher.GUI.inventoryWindow.visible and not guide.panel.visible)
	guide.OpenStats()
	assert(Launcher.GUI.statWindow.visible)
	Launcher.Player.progress.SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.KAEL_MET)
	Launcher.Player.progress.AddBestiary("Maggot".hash(), 5)
	Launcher.Player.progress.AddBestiary("Peyote".hash(), 5)
	guide.RefreshObjective()
	assert("5/5" in guide.objective.text)
	print("THAI_TRAINING_SMOKE_PASS")
	Launcher.Quit()

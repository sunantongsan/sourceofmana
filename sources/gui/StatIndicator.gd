extends Control

@onready var hpStat : Control			= $HP
@onready var manaStat : Control			= $Mana
@onready var staminaStat : Control		= $Stamina
@onready var expStat : Control			= $Exp
@onready var button : TouchScreenButton	= $TouchButton

var levelLabel: Label
var portrait : Control

#
func Refresh():
	if Launcher.Player:
		if levelLabel:
			levelLabel.text = "Lv.%d • %s" % [Launcher.Player.stat.level, Cultivation.REALMS[Cultivation.RealmIndex(Launcher.Player.stat.level)]]
		hpStat.SetStat(Launcher.Player.stat.health, Launcher.Player.stat.current.maxHealth)
		manaStat.SetStat(Launcher.Player.stat.mana, Launcher.Player.stat.current.maxMana)
		staminaStat.SetStat(Launcher.Player.stat.stamina, Launcher.Player.stat.current.maxStamina)
		expStat.SetStat(Launcher.Player.stat.experience, Experience.GetNeededExperienceForNextLevel(Launcher.Player.stat.level))

func Connect():
	if Launcher.Player:
		if not Launcher.Player.stat.vital_stats_updated.is_connected(Refresh):
			Launcher.Player.stat.vital_stats_updated.connect(Refresh)

func SetBarsVisible(isVisible : bool):
	hpStat.set_visible(isVisible)
	manaStat.set_visible(isVisible)
	staminaStat.set_visible(isVisible)
	expStat.hide()
	if portrait:
		portrait.visible = isVisible
	button.set_visible(isVisible)
	if levelLabel:
		levelLabel.visible = isVisible

#
func _post_launch():
	if Launcher.Map:
		if not Launcher.Map.PlayerWarped.is_connected(Connect):
			Launcher.Map.PlayerWarped.connect(Connect)

func _ready():
	expStat.hide()
	portrait = preload("res://sources/gui/CharacterPortrait.gd").new()
	portrait.position = Vector2(3, 4)
	portrait.size = Vector2(54, 54)
	add_child(portrait)
	levelLabel = Label.new()
	levelLabel.position = Vector2(52, 64)
	levelLabel.add_theme_font_size_override("font_size", 16)
	levelLabel.add_theme_color_override("font_color", Color("ffe1a0"))
	levelLabel.add_theme_color_override("font_shadow_color", Color.BLACK)
	levelLabel.add_theme_constant_override("shadow_offset_x", 1)
	levelLabel.add_theme_constant_override("shadow_offset_y", 1)
	levelLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(levelLabel)
	_post_launch()

func _on_button_pressed():
	Launcher.GUI.get_node("CharacterHUD").Toggle()

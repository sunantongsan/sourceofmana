extends Control

var layers : Array[Sprite2D] = []
var age := 0.0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	for slot in ActorCommons.Slot.COUNT:
		var sprite := Sprite2D.new()
		add_child(sprite)
		layers.append(sprite)

func _draw():
	draw_circle(size * 0.5, size.x * 0.5, Color("18394e"))
	draw_arc(size * 0.5, size.x * 0.5 - 2, 0, TAU, 48, Color("e8c575"), 2, true)

func _process(delta : float):
	age += delta
	if age < 0.25 or not is_instance_valid(Launcher.Player) or not Launcher.Player.visual:
		return
	age = 0
	if is_instance_valid(Launcher.Player.visual.heroArt) and Launcher.Player.visual.heroArt.visible:
		for layer in layers:
			layer.hide()
		var portrait := layers[0]
		portrait.show()
		portrait.texture = HeroArt.SHEET
		portrait.region_enabled = true
		portrait.region_rect = HeroArt.REGIONS[0]
		portrait.position = size * Vector2(0.5, 0.85)
		portrait.offset = HeroArt.REGIONS[0].size * 0.5 - (HeroArt.FEET[0] - HeroArt.REGIONS[0].position)
		portrait.scale = Vector2.ONE * 0.65
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		return
	for layer in layers:
		layer.region_enabled = false
	var sources : Array[Sprite2D] = Launcher.Player.visual.sprites
	for idx in layers.size():
		var sprite := layers[idx]
		var source : Sprite2D = sources[idx] if idx < sources.size() else null
		sprite.visible = source != null and source.texture != null and idx != ActorCommons.Slot.WEAPON
		if not sprite.visible:
			continue
		sprite.texture = source.texture
		sprite.material = source.material
		sprite.hframes = source.hframes
		sprite.vframes = source.vframes
		sprite.frame = 0
		sprite.z_index = source.get_index()
		sprite.offset = source.offset
		sprite.centered = source.centered
		sprite.position = Vector2(size.x * 0.5, size.y * 1.15) + source.position * 1.2
		sprite.scale = Vector2.ONE * 1.2
	queue_redraw()

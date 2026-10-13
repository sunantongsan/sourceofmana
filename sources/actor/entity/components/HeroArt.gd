extends Node2D
class_name HeroArt
const ROOT := "res://data/graphics/hero/craftpix/"
static var rig_data: Dictionary = {}
static var textures: Dictionary = {}
var visual: EntityVisual
var layers: Array[Sprite2D] = []
var clip := "Idle"
var clock := 0.0
var strike_left := 0.0
var strike_duration := 0.5
var hit_left := 0.0
var preview := false
static func Available() -> bool:
	return FileAccess.file_exists(ROOT + "rig.json")
func _ready():
	if rig_data.is_empty() and Available():
		rig_data = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "rig.json"))
	scale = Vector2.ONE * 0.125
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for i in 32:
		var part := Sprite2D.new()
		part.centered = false
		add_child(part)
		layers.append(part)
	ShowPose("Front", "Idle", 0.0)
func begin_strike():
	strike_duration = clampf(visual.entity.stat.current.castAttackDelay, 0.18, 1.0)
	strike_left = strike_duration
	clock = 0.0
func begin_hit():
	hit_left = 0.22
func _process(delta: float):
	if preview or not is_instance_valid(visual) or rig_data.is_empty():
		return
	var actor: Entity = visual.entity
	visible = not actor.stat.IsMorph()
	if is_instance_valid(visual.preset):
		visual.preset.visible = not visible
	if not visible:
		return
	var moving := actor.entityVelocity.length_squared() > 1.0
	var facing: Vector2 = actor.entityVelocity.normalized() if moving else actor.entityOrientation
	var direction := "Right_Side" if facing.x >= 0 else "Left_Side"
	if absf(facing.y) >= absf(facing.x):
		direction = "Front" if facing.y >= 0 else "Back"
	var next_clip := "Walk" if moving else "Idle"
	if Travel.IsFlying(actor):
		next_clip = "Idle"
	if hit_left > 0 and strike_left <= 0:
		next_clip = "Hurt"
	if strike_left > 0:
		next_clip = "Attack_1"
	if visual.spellPose:
		next_clip = "Attack_2"
	if actor.state == ActorCommons.State.DEATH:
		next_clip = "Died"
	if clip != next_clip:
		clock = 0.0
	clip = next_clip
	var sample_time := clock
	if clip == "Walk":
		sample_time *= clampf(Formula.GetWalkRatio(actor.stat), 0.5, 2.0)
	elif clip == "Attack_1":
		sample_time = (1.0 - strike_left / strike_duration) * 0.5
	elif visual.spellPose and clip == "Attack_2":
		sample_time = minf(0.49, 0.2 + visual.spellAge) if visual.spellRelease else minf(0.15, visual.spellAge)
	ShowPose(direction, clip, sample_time)
	clock += delta
	strike_left = maxf(0.0, strike_left - delta)
	hit_left = maxf(0.0, hit_left - delta)
func ShowPose(facing: String, animation_name: String, seconds: float):
	if rig_data.is_empty() or layers.is_empty():
		return
	var rig: Dictionary = rig_data.directions[facing]
	var animation_data: Dictionary = rig.animations[animation_name]
	var duration: float = animation_data.duration
	var looping := animation_name in ["Idle", "Idle Blinking", "Walk", "Run", "Communication"]
	var time: float = fposmod(seconds, duration) if looping else clampf(seconds, 0.0, duration)
	var frames: Array = animation_data.frames
	var frame_data: Array = frames[mini(int(time * float(rig_data.fps)), frames.size() - 1)]
	for i in layers.size():
		var sprite := layers[i]
		sprite.visible = i < frame_data.size()
		if not sprite.visible:
			continue
		var p: Array = frame_data[i]
		var part: Dictionary = rig.textures[int(p[0])]
		var path: String = ROOT + str(part.path)
		if not textures.has(path):
			textures[path] = load(path)
		sprite.texture = textures[path]
		sprite.position = Vector2(float(p[1]), float(p[2]))
		sprite.rotation = float(p[3])
		sprite.scale = Vector2(float(p[4]), float(p[5]))
		sprite.modulate.a = float(p[6])
		sprite.offset = Vector2(-float(p[7]) * float(part.w), -(1.0 - float(p[8])) * float(part.h))
		sprite.z_index = i

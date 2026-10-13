extends Sprite2D
class_name HeroArt

# Four independently painted directions: SE, SW, NE, NW. Never mirror the sword hand.
const SHEET = preload("res://data/graphics/hero/swordsman-v2.png")
const REGIONS = [
	Rect2(0, 0, 157, 157),
	Rect2(157, 0, 157, 157),
	Rect2(314, 0, 156, 157),
	Rect2(470, 0, 157, 157),
	Rect2(627, 0, 157, 157),
	Rect2(784, 0, 156, 157),
	Rect2(940, 0, 157, 157),
	Rect2(1097, 0, 157, 157),
	Rect2(0, 157, 157, 157),
	Rect2(157, 157, 153, 157),
	Rect2(310, 157, 160, 157),
	Rect2(470, 157, 157, 157),
	Rect2(627, 157, 157, 157),
	Rect2(784, 157, 155, 157),
	Rect2(939, 157, 158, 157),
	Rect2(1097, 157, 157, 157),
	Rect2(0, 314, 157, 157),
	Rect2(157, 314, 157, 157),
	Rect2(314, 314, 156, 157),
	Rect2(470, 314, 157, 157),
	Rect2(627, 314, 157, 157),
	Rect2(784, 314, 156, 157),
	Rect2(940, 314, 157, 157),
	Rect2(1097, 314, 157, 157),
	Rect2(0, 471, 157, 158),
	Rect2(157, 471, 157, 158),
	Rect2(314, 471, 152, 158),
	Rect2(466, 471, 161, 158),
	Rect2(627, 471, 157, 158),
	Rect2(784, 471, 156, 158),
	Rect2(940, 471, 166, 158),
	Rect2(1106, 471, 148, 158),
	Rect2(0, 629, 157, 158),
	Rect2(157, 629, 157, 158),
	Rect2(314, 629, 156, 158),
	Rect2(470, 629, 157, 158),
	Rect2(627, 629, 157, 158),
	Rect2(784, 629, 156, 158),
	Rect2(940, 629, 157, 158),
	Rect2(1097, 629, 157, 158),
	Rect2(0, 787, 150, 157),
	Rect2(150, 787, 161, 157),
	Rect2(311, 787, 151, 157),
	Rect2(462, 787, 165, 157),
	Rect2(627, 787, 155, 157),
	Rect2(782, 787, 155, 157),
	Rect2(937, 787, 167, 157),
	Rect2(1104, 787, 150, 157),
	Rect2(0, 944, 154, 154),
	Rect2(154, 944, 155, 154),
	Rect2(309, 944, 156, 154),
	Rect2(465, 944, 156, 154),
	Rect2(621, 944, 159, 154),
	Rect2(780, 944, 158, 154),
	Rect2(938, 944, 153, 154),
	Rect2(1091, 944, 163, 154),
	Rect2(0, 1098, 157, 156),
	Rect2(157, 1098, 157, 156),
	Rect2(314, 1098, 156, 156),
	Rect2(470, 1098, 157, 156),
	Rect2(627, 1098, 157, 156),
	Rect2(784, 1098, 155, 156),
	Rect2(939, 1098, 167, 156),
	Rect2(1106, 1098, 148, 156)
]
const FEET = [
	Vector2(99.5, 151),
	Vector2(256.0, 150),
	Vector2(400.0, 150),
	Vector2(565.0, 151),
	Vector2(729.0, 150),
	Vector2(881.0, 149),
	Vector2(1039.0, 151),
	Vector2(1195.5, 151),
	Vector2(110.0, 312),
	Vector2(268.5, 310),
	Vector2(364.0, 310),
	Vector2(580.0, 309),
	Vector2(729.0, 309),
	Vector2(859.0, 308),
	Vector2(1018.0, 308),
	Vector2(1149.0, 302),
	Vector2(58.0, 467),
	Vector2(217.0, 466),
	Vector2(402.0, 467),
	Vector2(532.0, 465),
	Vector2(685.0, 465),
	Vector2(840.0, 466),
	Vector2(995.0, 467),
	Vector2(1150.0, 467),
	Vector2(111.0, 626),
	Vector2(267.0, 626),
	Vector2(418.0, 626),
	Vector2(572.0, 625),
	Vector2(741.0, 626),
	Vector2(873.0, 626),
	Vector2(1023.0, 624),
	Vector2(1150.0, 614),
	Vector2(93.0, 776),
	Vector2(249.0, 776),
	Vector2(386.0, 784),
	Vector2(535.0, 779),
	Vector2(684.0, 781),
	Vector2(844.0, 778),
	Vector2(1005.0, 783),
	Vector2(1163.0, 783),
	Vector2(45.0, 936),
	Vector2(194.0, 939),
	Vector2(401.0, 934),
	Vector2(569.0, 941),
	Vector2(741.0, 942),
	Vector2(851.0, 940),
	Vector2(1020.5, 930),
	Vector2(1148.0, 928),
	Vector2(62.0, 1092),
	Vector2(218.0, 1089),
	Vector2(375.5, 1092),
	Vector2(558.0, 1093),
	Vector2(721.0, 1094),
	Vector2(879.0, 1095),
	Vector2(1035.0, 1095),
	Vector2(1194.0, 1092),
	Vector2(120.0, 1247),
	Vector2(278.0, 1248),
	Vector2(360.0, 1247),
	Vector2(520.0, 1246),
	Vector2(677.0, 1246),
	Vector2(881.0, 1247),
	Vector2(1022.5, 1238),
	Vector2(1148.0, 1235)
]
var visual : EntityVisual
var clock := 0.0
var strike_left := 0.0
var strike_duration := 0.5
var hit_left := 0.0
var mode := ""
var direction_index := 0
var pose_index := 0

func _ready():
	texture = SHEET
	region_enabled = true
	region_filter_clip_enabled = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	scale = Vector2.ONE * 0.49
	set_pose(0)

func begin_strike():
	strike_duration = maxf(0.18, visual.entity.stat.current.castAttackDelay)
	strike_left = strike_duration

func cancel_strike():
	strike_left = 0.0

func begin_hit():
	# Visual feedback only: receiving damage must not stop auto-combat or movement.
	hit_left = 0.14

func set_pose(index : int):
	pose_index = clampi(index, 0, REGIONS.size() - 1)
	flip_h = false
	region_rect = REGIONS[pose_index]
	offset = region_rect.size * 0.5 - (FEET[pose_index] - region_rect.position)

func _process(delta : float):
	if not is_instance_valid(visual) or not is_instance_valid(visual.entity):
		return
	var actor := visual.entity
	visible = not actor.stat.IsMorph()
	if is_instance_valid(visual.preset):
		visual.preset.visible = not visible
	if not visible:
		strike_left = 0.0
		hit_left = 0.0
		return
	var facing := actor.entityOrientation
	if facing.length_squared() > 0.01:
		direction_index = (2 if facing.y < -0.2 else 0) + (1 if facing.x < 0 else 0)
	strike_left = maxf(0.0, strike_left - delta)
	hit_left = maxf(0.0, hit_left - delta)
	var next_mode := "idle"
	if actor.state == ActorCommons.State.DEATH:
		next_mode = "death"
		strike_left = 0.0
	elif Travel.IsFlying(actor):
		next_mode = "fly"
	elif visual.spellPose:
		next_mode = "cast"
	elif strike_left > 0:
		next_mode = "attack"
	elif actor.entityVelocity.length_squared() > 1:
		next_mode = "walk"
	elif hit_left > 0:
		next_mode = "hit"
	if next_mode != mode:
		clock = 0.0
		mode = next_mode
	clock += delta
	var base := direction_index * 16
	var index := base
	match mode:
		"idle": index += int(clock * 2.0) % 2
		"walk":
			var cadence := clampf(actor.entityVelocity.length() / 6.0, 6.0, 16.0)
			index += 2 + int(clock * cadence) % 6
		"attack":
			var progress := 1.0 - strike_left / strike_duration
			index += 8 + clampi(int(progress * 3.0), 0, 2)
		"cast": index += 12 if visual.spellRelease else 11
		"hit": index += 13
		"death": index += 14
		"fly": index += 15
	set_pose(index)

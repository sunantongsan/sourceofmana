extends Node2D
class_name HeldWeapon

# Reuse the equipped item's artwork, independent of the old attack-only atlas.
var visual : EntityVisual
var source : Sprite2D
var blade := Sprite2D.new()
const LENGTH_SCALE := 2.25

func _ready():
	name = "HeldWeapon"
	process_priority = 10
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	blade.centered = false
	blade.scale = Vector2.ONE * LENGTH_SCALE
	add_child(blade)

func Equip(cell : ItemCell):
	blade.texture = cell.icon if cell else null
	if blade.texture:
		# Equipment icons point diagonally up-right, with the grip at lower left.
		blade.offset = -Vector2(blade.texture.get_size()) * Vector2(0.29, 0.72)

func _process(_delta : float):
	RefreshPose()

func RefreshPose():
	if not is_instance_valid(visual) or not is_instance_valid(source):
		hide()
		return
	var actor := visual.entity
	visible = blade.texture != null and ActorCommons.IsAlive(actor) and not actor.stat.IsMorph() and not Travel.IsFlying(actor)
	# Exactly one weapon renderer: never leave the small old blade underneath.
	source.visible = blade.texture == null
	if not visible:
		return
	var frame := source.frame
	var direction := actor.entityOrientation
	var angle := direction.angle()
	var hand := Vector2(3, -22)
	if absf(direction.y) >= absf(direction.x):
		hand = Vector2(5, -19) if direction.y >= 0 else Vector2(-6, -23)
		z_index = 1 if direction.y >= 0 else -1
	else:
		hand = Vector2(3, -23) if direction.x >= 0 else Vector2(-4, -23)
		z_index = 1
	var pose := frame % 16
	if pose >= 7 and pose <= 10 and (actor.state == ActorCommons.State.ATTACK or visual.spellPose):
		var swing : Array[float] = [-1.25, -0.8, 0.4, 1.05]
		angle += swing[pose - 7]
		hand += Vector2.from_angle(angle) * 5
	elif visual.previousState == ActorCommons.State.WALK:
		var stride := sin(float(pose - 1) * TAU / 6.0)
		hand += Vector2(stride * 1.5, absf(stride) * -1.5)
		angle += 0.35 + stride * 0.12
	else:
		angle += 0.45
	position = hand
	rotation = angle + PI / 4.0

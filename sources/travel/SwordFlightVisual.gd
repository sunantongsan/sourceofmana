extends Node2D

var entity : Entity
var basePosition : Vector2
var baseZ : int
var airborne : bool = false
var phase : float = 0.0

func _ready():
	name = "SwordFlightVisual"
	entity = get_parent() as Entity
	basePosition = entity.visual.position
	baseZ = entity.z_index
	z_index = -1
	scale = Vector2.ONE

func _process(delta : float):
	var flying : bool = Travel.IsFlying(entity)
	visible = flying
	if flying != airborne:
		airborne = flying
		entity.z_index = 40 if flying else baseZ
		if not flying:
			entity.visual.position = basePosition
		entity.visual.Refresh()
	if flying:
		phase += delta
		position = basePosition + Vector2(0, -18 + sin(phase * 3) * 1.5)
		entity.visual.position = position
		rotation = entity.entityOrientation.angle()
		queue_redraw()

func _draw():
	# Replacement atlas includes the flying sword. Avoid drawing a second one.
	if is_instance_valid(entity.visual.heroArt) and entity.visual.heroArt.visible:
		return
	# A small original sword silhouette matching the existing pixel-art scale.
	draw_line(Vector2(-44, 0), Vector2(-19, 0), Color(0.3, 0.85, 1, 0.3), 9)
	draw_line(Vector2(-54, 0), Vector2(-19, 0), Color(0.65, 0.95, 1, 0.65), 2)
	draw_colored_polygon(PackedVector2Array([Vector2(-16,-5), Vector2(22,-5), Vector2(35,0), Vector2(22,5), Vector2(-16,5)]), Color("afdce8"))
	draw_line(Vector2(-15,0), Vector2(33,0), Color("f0ffff"), 2)
	draw_line(Vector2(-18,-9), Vector2(-18,9), Color("d7ae59"), 4)
	draw_line(Vector2(-29,0), Vector2(-20,0), Color("74503e"), 5)
	draw_circle(Vector2(-30,0), 3, Color("d7ae59"))

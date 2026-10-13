extends Node2D
class_name CultivationFX

# Lightweight vector effects: no new textures or shader compilation on mobile.
const LIMIT := 48
static var active := 0
var kind := "slash"
var age := 0.0
var duration := 0.5
var radius := 40.0
var facing := Vector2.RIGHT
var tint := Color(0.25, 0.85, 1.0)

static func Spawn(host: Node2D, point: Vector2, effect: String, direction: Vector2, reach: float = 40.0) -> CultivationFX:
	if not is_instance_valid(host) or active >= LIMIT:
		return null
	var fx := CultivationFX.new()
	fx.kind = effect
	fx.facing = direction.normalized() if direction.length_squared() > 0.01 else Vector2.DOWN
	fx.radius = clampf(reach, 28.0, 110.0)
	fx.duration = 0.32 if effect == "hit" else (0.48 if effect == "slash" else 0.95)
	if effect == "blades":
		fx.tint = Color(0.3, 1.0, 0.65)
	elif effect == "burst":
		fx.tint = Color(0.65, 0.45, 1.0)
	elif effect == "hit":
		fx.tint = Color(1.0, 0.8, 0.35)
	host.add_child(fx)
	fx.global_position = point
	return fx

func _ready():
	active += 1
	z_index = 8

func _exit_tree():
	active -= 1

func _process(delta: float):
	age += delta
	if age >= duration:
		queue_free()
	else:
		queue_redraw()

func ring(r: float, color: Color, width: float, turn: float = 0.0, sweep: float = TAU):
	var points := PackedVector2Array()
	for i in range(49):
		var angle := turn + sweep * i / 48.0
		points.append(Vector2(cos(angle) * r, sin(angle) * r * 0.55))
	draw_polyline(points, color, width, true)

func blade(center: Vector2, angle: float, length: float, alpha: float):
	var axis := Vector2.from_angle(angle)
	var side := axis.orthogonal()
	var points := PackedVector2Array([center + axis * length, center + side * 3, center - axis * 7, center - side * 3])
	draw_colored_polygon(points, Color(tint, alpha))
	draw_line(center - axis * 4, center + axis * (length - 2), Color(0.94, 1, 1, alpha), 1.5, true)

func _draw():
	var t := clampf(age / duration, 0.0, 1.0)
	var fade := pow(1.0 - t, 1.4)
	var color := Color(tint, fade)
	match kind:
		"slash":
			var center := facing * 9.0 + Vector2(0, -17)
			var heading := facing.angle()
			for layer in range(3):
				var points := PackedVector2Array()
				var r := radius * (0.75 + layer * 0.12)
				for i in range(25):
					var a := heading - 1.3 + 2.6 * i / 24.0 * minf(1.0, 0.15 + t * 5.0) + t * 0.35
					points.append(center + Vector2.from_angle(a) * r)
				draw_polyline(points, Color(tint.lerp(Color.WHITE, layer * 0.4), fade * (0.3 + layer * 0.3)), 7.0 - layer * 2, true)
		"hit":
			for i in range(9):
				var v := Vector2.from_angle(i * TAU / 9.0 + 0.2)
				draw_line(v * (3 + t * 12), v * (8 + t * 25), color, 2, true)
			draw_circle(Vector2.ZERO, 7 * fade, Color(1, 0.97, 0.8, fade))
		"burst":
			for i in range(3):
				var progress := clampf(t * 1.6 - i * 0.18, 0.0, 1.0)
				ring(radius * progress, Color(tint, fade * (1 - i * 0.2)), 5 - i)
			for i in range(12):
				var a := i * TAU / 12.0
				var p := Vector2(cos(a), sin(a) * 0.55) * radius * (0.3 + t * 0.7)
				draw_line(p, p + Vector2(0, -35 * sin(t * PI)), Color(0.8, 0.7, 1, fade), 2, true)
			ring(radius * 0.75, Color(0.9, 0.8, 1, fade * 0.5), 1, t)
		"blades":
			ring(radius * 0.8, Color(tint, fade * 0.4), 2, t * 5, TAU * 0.8)
			for i in range(8):
				var a := i * TAU / 8.0 + t * 5
				var p := Vector2(cos(a), sin(a) * 0.55) * radius * (0.45 + 0.55 * sin(t * PI * 0.5))
				blade(p + Vector2(0, -10), a + PI * 0.5, 21, fade)
		"wave":
			for i in range(3):
				var p := facing * radius * clampf(t * 1.5 - i * 0.15, 0, 1) + Vector2(0, -16)
				var points := PackedVector2Array()
				for j in range(21):
					var a := facing.angle() - 1.15 + j * 2.3 / 20
					points.append(p + Vector2.from_angle(a) * (15 + t * 18))
				draw_polyline(points, Color(tint.lerp(Color.WHITE, i * 0.3), fade * (1 - i * 0.2)), 5 - i, true)
		"charge":
			ring(radius * (0.9 - t * 0.35), Color(tint, sin(t * PI) * 0.65), 2, t * 3, TAU * 0.85)
			for i in range(6):
				var a := i * TAU / 6 + t * 2
				var p := Vector2(cos(a), sin(a) * 0.55) * radius * (1 - t)
				draw_circle(p + Vector2(0, -t * 18), 2, color)

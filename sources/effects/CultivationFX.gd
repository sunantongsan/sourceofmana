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
	fx.radius = clampf(reach, 28.0, 200.0)
	fx.duration = 0.32 if effect == "hit" else (0.48 if effect == "slash" else 0.95)
	if effect == "blades":
		fx.tint = Color(0.3, 1.0, 0.65)
	elif effect == "burst":
		fx.tint = Color(0.65, 0.45, 1.0)
	elif effect == "hit":
		fx.tint = Color(1.0, 0.8, 0.35)
	if effect in ["flame", "thunder", "frost", "gale", "solar"]:
		fx.tint = EffectColor(effect)
		fx.duration = 1.25 if effect == "gale" else 0.95
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
		"flame": DrawFlame(t, fade)
		"thunder": DrawThunder(t, fade)
		"frost": DrawFrost(t, fade)
		"gale": DrawGale(t, fade)
		"solar": DrawSolar(t, fade)
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

func DrawFlame(t : float, fade : float):
	ring(radius * minf(1, t * 3), Color(1, 0.35, 0.08, fade), 5)
	for index in 14:
		var a : float = TAU * index / 14.0 + t * 2
		var p := Vector2(cos(a), sin(a) * 0.55) * radius * (0.25 + t * 0.75)
		var height : float = 20 + 35 * sin(PI * t)
		var flame := PackedVector2Array([p + Vector2(-7, 0), p + Vector2(-10, -height * 0.4), p + Vector2(3, -height), p + Vector2(9, -height * 0.3), p + Vector2(6, 2)])
		draw_colored_polygon(flame, Color(1, 0.22, 0.06, fade * 0.7))
		draw_line(p, p + Vector2(2, -height * 0.7), Color(1, 0.85, 0.35, fade), 4, true)

func DrawThunder(t : float, fade : float):
	ring(radius * 0.8, Color(0.6, 0.4, 1, fade * 0.5), 3, t)
	for index in 7:
		var a : float = TAU * index / 7.0
		var end := Vector2(cos(a), sin(a) * 0.55) * radius * 0.75
		var points := PackedVector2Array()
		for segment in 7:
			var jitter : float = sin(segment * 8.1 + index * 3 + floor(t * 14)) * 11
			points.append(end + Vector2(jitter if segment < 6 else 0.0, -100 + segment * 100.0 / 6))
		draw_polyline(points, Color(0.5, 0.35, 1, fade * 0.35), 10, true)
		draw_polyline(points, Color(0.8, 0.8, 1, fade), 4, true)
		draw_polyline(points, Color(1, 1, 1, fade), 1.5, true)
		draw_circle(end, 8 * fade, Color(0.8, 0.85, 1, fade * 0.6))

func DrawFrost(t : float, fade : float):
	ring(radius * minf(1, t * 2), Color(0.4, 0.9, 1, fade), 3)
	for index in 12:
		var a : float = TAU * index / 12
		var p := Vector2(cos(a), sin(a) * 0.55) * radius * (0.2 + 0.8 * t)
		var height : float = maxf(1.0, (24 + index % 3 * 8) * sin(PI * minf(0.8, t)))
		var shard := PackedVector2Array([p + Vector2(-7, 0), p + Vector2(-3, -height * 0.65), p + Vector2(1, -height), p + Vector2(8, -height * 0.3), p + Vector2(6, 2)])
		draw_colored_polygon(shard, Color(0.2, 0.65, 0.9, fade * 0.7))
		draw_line(p + Vector2(1, -height), p, Color(0.9, 1, 1, fade), 2, true)
		draw_line(Vector2.ZERO, p, Color(0.5, 0.95, 1, fade * 0.3), 1, true)

func DrawGale(t : float, fade : float):
	for layer in 9:
		var points := PackedVector2Array()
		var r : float = radius * (0.3 + layer * 0.075)
		for step in 33:
			var a : float = TAU * step / 32 + t * 12 + layer * 0.4
			points.append(Vector2(cos(a) * r, sin(a) * r * 0.3 - layer * 7))
		draw_polyline(points, Color(0.35 + layer * 0.06, 1, 0.8, fade * (0.3 + layer * 0.055)), 2 + layer % 3, true)
	for index in 10:
		var a : float = TAU * index / 10 + t * 12
		blade(Vector2(cos(a) * radius * 0.8, sin(a) * radius * 0.4 - 25), a + PI * 0.5, 15, fade)

func DrawSolar(t : float, fade : float):
	var start := Vector2(0, -18)
	var tip := start + facing * maxf(24.0, radius * minf(1, t * 4))
	var side := facing.orthogonal()
	for layer in 3:
		var width : float = 17 - layer * 6
		var shape := PackedVector2Array([start - side * width, tip - facing * 18 - side * width, tip + facing * 20, tip - facing * 18 + side * width, start + side * width])
		draw_colored_polygon(shape, Color(1, 0.5 + layer * 0.22, 0.15 + layer * 0.35, fade * (0.35 + layer * 0.2)))
	for index in 8:
		var a : float = TAU * index / 8 + t
		draw_line(tip + Vector2.from_angle(a) * 7, tip + Vector2.from_angle(a) * (18 + t * 25), Color(1, 0.85, 0.4, fade), 2, true)

static func EffectColor(effect : String) -> Color:
	var colors := {"burst":"a673ff", "blades":"4dffa6", "wave":"55dfff", "flame":"ff6b31", "thunder":"b395ff", "frost":"8fefff", "gale":"66efbd", "solar":"ffda75"}
	return Color(colors.get(effect, "55dfff"))

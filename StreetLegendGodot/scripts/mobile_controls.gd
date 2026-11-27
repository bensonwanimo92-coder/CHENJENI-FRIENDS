extends Control
class_name StreetLegendMobileControls

signal pause_requested

@export var fighter: StreetLegendFighter
@export var vehicle: StreetLegendVehicleController
var driving_mode := false
var joystick_finger := -1
var joystick_origin := Vector2.ZERO
var joystick_value := Vector2.ZERO
var gas_pressed := false
var brake_pressed := false
var steer_value := 0.0
var attack_flash := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)

func set_driving_mode(enabled: bool) -> void:
	driving_mode = enabled
	joystick_finger = -1
	joystick_value = Vector2.ZERO
	steer_value = 0.0
	gas_pressed = false
	brake_pressed = false
	queue_redraw()

func _process(delta: float) -> void:
	attack_flash = maxf(0.0, attack_flash - delta)
	if is_instance_valid(fighter) and not driving_mode:
		fighter.set_mobile_move_input(joystick_value)
	if is_instance_valid(vehicle) and driving_mode:
		vehicle.set_input(steer_value, 1.0 if gas_pressed else 0.0, brake_pressed)
	queue_redraw()

func _input(event: InputEvent) -> void:
	var screen := get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x > screen.x * 0.90 and event.position.y < screen.y * 0.18:
				pause_requested.emit()
			elif event.position.x < screen.x * 0.48 and joystick_finger == -1:
				joystick_finger = event.index
				joystick_origin = event.position
				_update_joystick(event.position)
			else:
				_handle_right_touch(event.position, screen, true)
		else:
			if event.index == joystick_finger:
				joystick_finger = -1
				joystick_value = Vector2.ZERO
			else:
				_handle_right_touch(event.position, screen, false)
	elif event is InputEventScreenDrag and event.index == joystick_finger:
		_update_joystick(event.position)

func _update_joystick(position: Vector2) -> void:
	var delta := position - joystick_origin
	joystick_value = Vector2(delta.x, -delta.y).limit_length(90.0) / 90.0

func _handle_right_touch(position: Vector2, screen: Vector2, pressed: bool) -> void:
	if driving_mode:
		if position.x > screen.x * 0.72:
			if position.y > screen.y * 0.62:
				gas_pressed = pressed
			else:
				brake_pressed = pressed
		else:
			steer_value = clampf((position.x - screen.x * 0.58) / (screen.x * 0.14), -1.0, 1.0) if pressed else 0.0
	else:
		if not pressed or not is_instance_valid(fighter):
			return
		if position.x > screen.x * 0.78 and position.y > screen.y * 0.58:
			fighter.attack(true)
			attack_flash = 0.18
		elif position.x > screen.x * 0.58:
			fighter.attack(false)
			attack_flash = 0.18

func _draw() -> void:
	var screen := get_viewport().get_visible_rect().size
	draw_circle(Vector2(screen.x * 0.95, screen.y * 0.10), 34.0, Color(0.12, 0.18, 0.25, 0.75))
	draw_string(ThemeDB.fallback_font, Vector2(screen.x * 0.93, screen.y * 0.115), "II", HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color.WHITE)
	if driving_mode:
		draw_circle(Vector2(screen.x * 0.84, screen.y * 0.80), 66.0, Color(0.10, 0.52, 0.76, 0.34))
		draw_string(ThemeDB.fallback_font, Vector2(screen.x * 0.80, screen.y * 0.81), "GAS", HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color.WHITE)
		draw_circle(Vector2(screen.x * 0.84, screen.y * 0.47), 52.0, Color(0.75, 0.24, 0.14, 0.32))
		draw_string(ThemeDB.fallback_font, Vector2(screen.x * 0.80, screen.y * 0.48), "BRAKE", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.WHITE)
		draw_circle(Vector2(screen.x * 0.22, screen.y * 0.80), 74.0, Color(0.12, 0.22, 0.30, 0.30))
		draw_string(ThemeDB.fallback_font, Vector2(screen.x * 0.16, screen.y * 0.81), "STEER", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.WHITE)
		if is_instance_valid(vehicle):
			var speed_kmh := int(round(vehicle.velocity.length() * 3.6))
			draw_string(ThemeDB.fallback_font, Vector2(screen.x * 0.46, screen.y * 0.18), "SPEED  %d km/h" % speed_kmh, HORIZONTAL_ALIGNMENT_CENTER, -1, 28, Color.WHITE)
	else:
		draw_circle(Vector2(joystick_origin.x if joystick_finger >= 0 else screen.x * 0.15, joystick_origin.y if joystick_finger >= 0 else screen.y * 0.80), 72.0, Color(0.75, 0.86, 0.96, 0.16))
		draw_circle(Vector2(screen.x * 0.83, screen.y * 0.80), 58.0, Color(0.10, 0.55, 0.82, 0.36))
		draw_string(ThemeDB.fallback_font, Vector2(screen.x * 0.79, screen.y * 0.81), "STRIKE", HORIZONTAL_ALIGNMENT_CENTER, -1, 19, Color.WHITE)
		draw_circle(Vector2(screen.x * 0.92, screen.y * 0.62), 48.0, Color(0.60, 0.20, 0.17, 0.42 if attack_flash > 0.0 else 0.30))
		draw_string(ThemeDB.fallback_font, Vector2(screen.x * 0.88, screen.y * 0.63), "HEAVY", HORIZONTAL_ALIGNMENT_CENTER, -1, 17, Color.WHITE)

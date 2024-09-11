extends AnimatedSprite2D

@export_group("Talking")
@export_range(0, 200, 0.1) var talking_threshold: float = 110
@export var move_y_talking: float = 10
@export_range(0, 200, 0.1) var talking_loud_threshold: float = 97
@export var move_y_talkingloud: float = 20

@export_group("Blinking")
@export var blink_time_out_sec: float = 2
@export var blink_time_out_fuzz_sec: float = 8
@export var blink_state_duration: float = 0.15

var bus_index = 0
var is_blinking: bool = false
var timer_blink_timeout: Timer
var timer_blink: Timer
var start_position

func _ready() -> void:
	start_position = position
	timer_blink_timeout = $TimerBlinkTimeOut
	timer_blink = $TimerBlink
	timer_blink.wait_time = blink_state_duration
	print(AudioServer.input_device)
	bus_index = AudioServer.get_bus_index("Record")

func _process(delta: float) -> void:
	var volume = abs(AudioServer.get_bus_peak_volume_left_db(bus_index, 0))
	print(volume)
	
	var state_keys = ["pngtuber"]
	var move_y = 0
	
	if volume < talking_loud_threshold:
		state_keys.push_back("talkingloud")
		move_y = move_y_talkingloud
	elif volume < talking_threshold:
		state_keys.push_back("talking")
		move_y = move_y_talking
	
	if is_blinking:
		state_keys.push_back("blinking")
	
	self.animation = "_".join(state_keys)
	self.position = start_position - Vector2(0, move_y);

func blink_timeout_timer_done():
	timer_blink_timeout.wait_time = blink_time_out_sec + blink_time_out_fuzz_sec * randf()
	timer_blink.start()
	is_blinking = true

func blink_timer_done():
	is_blinking = false
	timer_blink_timeout.start()

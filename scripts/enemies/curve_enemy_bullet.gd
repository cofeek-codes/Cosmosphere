extends Area2D

const SPEED = 300.0
const LIFETIME = 5

@export var OSCILLATION_AMPLITUDE: float = 2.0
@export var OSCILLATION_FREQUENCY: float = 2.0
@export var direction: Vector2 = Vector2.RIGHT

var time: float = 0.0

var trail_point_queue: Array
var TRAIL_POINT_QUEUE_MAX_LENGTH = 15


@onready var timer: Timer = $DispawnTimer
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var trail: Line2D = $Trail

@onready var player: CharacterBody2D = get_node('../Player')


func movement(delta: float):
		# Update time for oscillation
	time += delta * OSCILLATION_FREQUENCY

	# Calculate vertical offset using sine wave
	var vertical_offset = sin(time) * OSCILLATION_AMPLITUDE

	# Create movement vector combining horizontal and vertical components
	var movement = direction * SPEED * delta
	movement.y += vertical_offset
	
	# Apply movement
	position -= movement


func trailing():
	
	var pos = self.position
	trail_point_queue.push_front(pos)
	
	if trail_point_queue.size() > TRAIL_POINT_QUEUE_MAX_LENGTH:
		trail_point_queue.pop_back()
		
	trail.clear_points()
	for point in trail_point_queue:	
		trail.add_point(point)
	

func _ready() -> void:
	audio_player.pitch_scale = randf_range(0.5, 1.5)
	audio_player.play()

func _physics_process(delta: float) -> void:
	movement(delta)
	trailing()


func _on_dispawn_timer_timeout() -> void:
	queue_free()



func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player.emit_signal('got_hit')
		queue_free()

extends Area2D

var boid_list : Array = []
var close_boids : int = 0
var direction := Vector2.ZERO
var screensize : Vector2
var colour : Color

@onready var main = get_tree().get_first_node_in_group("main")
@onready var boid_speed = main.boid_speed
@onready var cohesion_amount = main.cohesion_amount
@onready var alignment_amount = main.alignment_amount
@onready var separation_distance = main.separation_distance
@onready var separation_amount = main.separation_amount
@onready var tracking_amount = main.tracking_amount


func _ready():
	screensize = DisplayServer.window_get_size()
	colour = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0), 0.5)
	
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	if is_instance_valid(main) && main.boids_die:
		await get_tree().create_timer(30.0).timeout
		queue_free()


func _process(delta):
	check_for_offscreen()
	close_boids = 0
	if boid_list:
		var flock_data = flock_rules()
		if flock_data[0] != Vector2.ZERO && alignment_amount > 0:
			direction += flock_data[0] * alignment_amount
		if flock_data[1] != Vector2.ZERO && cohesion_amount > 0:
			direction += flock_data[1] * cohesion_amount
		if flock_data[2] != Vector2.ZERO && separation_amount > 0:
			direction += flock_data[2] * separation_amount
#			position = lerp(position, position + flock_data[2], separation_amount)
		
	if main.follow_mouse:
		var mouse_pos = ((get_viewport().get_mouse_position() - position))
		direction += mouse_pos * tracking_amount
	
	rotation = direction.angle()
	
	translate(direction.normalized() * delta * boid_speed)


func flock_rules() -> Array:
	var cohesion = Vector2.ZERO
	var alignment = Vector2.ZERO
	var separation = Vector2.ZERO
	
	for boid in boid_list:
		cohesion += boid.position
		alignment += boid.direction
		if position.distance_to(boid.position) < separation_distance:
			close_boids += 1
			separation += (position - boid.position)
	cohesion = ((cohesion / boid_list.size()) - position)
	alignment = ((alignment / boid_list.size()))
	if close_boids > 0:
		separation /= close_boids
	return [ alignment.normalized(), cohesion.normalized(), separation ]


func check_for_offscreen():
		if position.x < 0:
			position.x = screensize.x
		elif position.x > screensize.x:
			position.x = 0
		if position.y < 0:
			position.y = screensize.y
		elif position.y > screensize.y:
			position.y = 0


func _on_area_entered(area: Area2D):
	if area.is_in_group("boids"):
		boid_list.append(area)


func _on_area_exited(area):
	if area.is_in_group("boids"):
		boid_list.erase(area)

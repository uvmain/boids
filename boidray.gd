extends Node2D

var boid_list : Array = []
var close_boids : Array = []
var velocity : Vector2
var direction : Vector2
var screensize
var rays : Array = []
var colour

@onready var main = get_tree().get_first_node_in_group("main")
@onready var boid_mesh = get_tree().get_first_node_in_group("boid_mesh")
@onready var boid_speed = main.boid_speed if is_instance_valid(main) else 200
@onready var cohesion_amount = main.cohesion_amount if is_instance_valid(main) else 200
@onready var alignment_amount = main.alignment_amount if is_instance_valid(main) else 200
@onready var separation_distance = main.separation_distance if is_instance_valid(main) else 200
@onready var separation_amount = main.separation_amount if is_instance_valid(main) else 200
@onready var tracking_amount = main.tracking_amount if is_instance_valid(main) else 200


func _ready():
	screensize = DisplayServer.window_get_size()
	colour = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0), 0.5)
	
	for child in get_children():
		if child is RayCast2D:
			rays.append(child)
	
	while velocity == Vector2.ZERO:
		velocity = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		
		
	if is_instance_valid(main) && main.boids_die:
		await get_tree().create_timer(30.0).timeout
		queue_free()


func _process(delta):
	check_for_offscreen()
	boid_list.clear()
	close_boids.clear()
	
	for ray in rays:
		var collider = ray.get_collider()
		if collider:
			boid_list.append(collider)
	if boid_list:
		var flock_data = flock_rules()
		direction += flock_data[0] * cohesion_amount
		direction += flock_data[1] * alignment_amount
		direction += flock_data[2] * separation_amount
		
	if is_instance_valid(main) && main.follow_mouse:
		var mouse_pos = ((get_viewport().get_mouse_position() - position)).normalized()
		direction += mouse_pos * tracking_amount
		
	velocity = (velocity + direction).normalized()
	rotation = velocity.angle()
	translate(velocity * delta * boid_speed)


func flock_rules() -> Array:
	var cohesion = Vector2.ZERO
	var alignment = Vector2.ZERO
	var separation = Vector2.ZERO
	var boid_list_size = boid_list.size()
	
	for boid in boid_list:
		cohesion += boid.position
		alignment += boid.velocity
		if position.distance_to(boid.position) < separation_distance:
			close_boids.append(boid)
			var difference = position - boid.position
			separation += difference.normalized() / difference.length()
	cohesion = (((cohesion / boid_list_size) - position) - velocity).normalized()
	alignment = (((alignment / boid_list_size) - position) - velocity).normalized()
	if close_boids:
		separation = (((separation / close_boids.size()) - position) - velocity).normalized()
	return [cohesion, alignment,separation]


func check_for_offscreen():
		if position.x < 0:
			position.x = screensize.x
		elif position.x > screensize.x:
			position.x = 0
		if position.y < 0:
			position.y = screensize.y
		elif position.y > screensize.y:
			position.y = 0

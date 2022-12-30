extends Node2D

var boid_list : Array = []
var velocity : Vector2
var direction : Vector2
var screensize

@onready var main = get_tree().get_first_node_in_group("main")
@onready var boid_speed = main.boid_speed
@onready var cohesion_amount = main.cohesion_amount
@onready var alignment_amount = main.alignment_amount
@onready var separation_distance = main.separation_distance
@onready var separation_amount = main.separation_amount
@onready var tracking_amount = main.tracking_amount


func _ready():
	screensize = DisplayServer.window_get_size()
	
	while velocity == Vector2.ZERO:
		velocity = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * boid_speed
	if is_instance_valid(main) && main.boids_die:
		await get_tree().create_timer(30.0).timeout
		queue_free()


func _process(delta):
	check_for_offscreen()
	if boid_list:
		var flock_data = flock_rules()
		direction += flock_data.alignment * alignment_amount
		direction += flock_data.cohesion * cohesion_amount
		direction += flock_data.separation * separation_amount
		
	if main.follow_mouse:
		var mouse_pos = ((get_viewport().get_mouse_position() - position) - velocity).normalized()
		direction += mouse_pos * tracking_amount
		
	velocity = (velocity + direction).normalized()
	rotation = velocity.angle()
	translate(velocity * delta * boid_speed)


func flock_rules() -> Dictionary:
	var cohesion = Vector2.ZERO
	var alignment = Vector2.ZERO
	var separation = Vector2.ZERO
	var close_boids : Array = []
	
	for boid in boid_list:
		cohesion += boid.position
		alignment += boid.velocity
		if position.distance_to(boid.position) < separation_distance:
			close_boids.append(boid)
			var difference = position - boid.position
			separation += difference.normalized() / difference.length()
	cohesion /= boid_list.size()
	cohesion = ((cohesion - position) - velocity).normalized()
	alignment /= boid_list.size()
	alignment = ((alignment - position) - velocity).normalized()
	if close_boids:
		separation /= close_boids.size()
		separation = ((separation - position) - velocity).normalized()
	return { "cohesion": cohesion, "alignment": alignment, "separation": separation }


func check_for_offscreen():
		if position.x < 0:
			position.x = screensize.x
		if position.x > screensize.x:
			position.x = 0
		if position.y < 0:
			position.y = screensize.y
		if position.y > screensize.y:
			position.y = 0


func _on_area_2d_area_entered(area):
	if area.is_in_group("boids"):
		boid_list.append(area.get_parent())


func _on_area_2d_area_exited(area):
	if area.is_in_group("boids"):
		boid_list.erase(area.get_parent())

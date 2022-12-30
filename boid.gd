extends Node2D

var boid_list : Array = []
var direction : Vector2
var screensize

@export var speed : int = 200
@export_range(0.0, 1.0) var cohesion_amount = 0.01
@export_range(0.0, 1.0) var alignment_amount = 0.01
@export_range(0, 100) var separation_distance = 10
@export_range(0.0, 1.0) var separation_amount = 0.01
@export_range(0.0, 1.0) var tracking_amount = 0.1


func _ready():
	screensize = DisplayServer.window_get_size()
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	await get_tree().create_timer(30.0).timeout
	queue_free()


func _process(delta):
	check_for_offscreen()
	var new_rotation = rotation
	if boid_list:
		var flock_data = flock_rules()
		position = lerp(position, flock_data.average_position, cohesion_amount)
		new_rotation = lerp(new_rotation, flock_data.average_rotation, alignment_amount)
		direction = Vector2(cos(new_rotation), sin(new_rotation))
		position = lerp(position, flock_data.separation_position, separation_amount)
	direction = lerp(direction, position.direction_to(get_viewport().get_mouse_position()), tracking_amount)
	position += (direction * speed * delta)
	look_at(position + direction)


func flock_rules() -> Dictionary:
	var average_rotation := 0.0
	var average_position := Vector2.ZERO
	var separation_position := Vector2.ZERO
	var boids_too_close := 0
	for boid in boid_list:
		average_position += boid.position
		average_rotation += boid.rotation
		if position.distance_to(boid.position) < separation_distance:
			boids_too_close += 1
			var difference = position - boid.position
			separation_position += difference.normalized() / difference.length()
	average_position /= boid_list.size()
	average_rotation /= boid_list.size()
	if boids_too_close > 0:
		separation_position /= boids_too_close
	separation_position += position
	return { "average_position": average_position, "average_rotation": average_rotation, "separation_position": separation_position }


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

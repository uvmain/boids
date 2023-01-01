extends Node2D

var screensize

@export var boid_area_scene : PackedScene
@export var boid_ray_scene : PackedScene
@export var follow_mouse : bool = false
@export var boids_die : bool = false

@export var spawn_count : int = 200
@export_range(100, 600) var boid_speed : int = 200
@export_range(0.0, 500.0) var cohesion_amount = 20.0
@export_range(0.0, 500.0) var alignment_amount = 20.5
@export_range(0, 100) var separation_distance = 30
@export_range(0.0, 100.0) var separation_amount = 100.0
@export_range(0, 2000) var tracking_amount = 800


func _ready():
	screensize = DisplayServer.window_get_size()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			for i in range(spawn_count):
				var new_boid = boid_area_scene.instantiate()
				$BoidHolder.add_child(new_boid)
				new_boid.position = Vector2(randf_range(0, screensize.x), randf_range(0, screensize.y))
		elif event.button_index == 2 and event.pressed:
			for i in range(spawn_count):
				var new_boid = boid_ray_scene.instantiate()
				$BoidHolder.add_child(new_boid)
				new_boid.position = Vector2(randf_range(0, screensize.x), randf_range(0, screensize.y))
		elif event.button_index == 3 and event.pressed:
			get_tree().reload_current_scene()

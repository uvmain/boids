extends Node2D

@export var boid_scene : PackedScene
@export var follow_mouse : bool = false
@export var boids_die : bool = false

@export_range(100, 600) var boid_speed : int = 200
@export_range(0.0, 100.0) var cohesion_amount = 20.0
@export_range(0.0, 100.0) var alignment_amount = 20.5
@export_range(0, 100) var separation_distance = 30
@export_range(0.0, 1.0) var separation_amount = 1.0
@export_range(0, 500) var tracking_amount = 100

var screensize


func _ready():
	screensize = DisplayServer.window_get_size()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var new_boid = boid_scene.instantiate()
			add_child(new_boid)
			new_boid.position = event.position
		elif event.button_index == 2:
			for i in range(40):
				var new_boid = boid_scene.instantiate()
				add_child(new_boid)
				new_boid.position = Vector2(randf_range(0, screensize.x), randf_range(0, screensize.y))

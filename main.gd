extends Node2D

@export var boid_scene : PackedScene
@export var follow_mouse: bool = false

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

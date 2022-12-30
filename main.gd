extends Node2D

@export var boid_scene : PackedScene


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var new_boid = boid_scene.instantiate()
			add_child(new_boid)
			new_boid.position = event.position
		elif event.button_index == 2:
			get_tree().quit()

extends Node2D

var screensize
var meshes : Array = []

@export var number_of_meshes : int = 100

@onready var multi_mesh_instance := $MultiMeshInstance2D
@onready var multi_mesh : MultiMesh = $MultiMeshInstance2D.multimesh
@onready var mesh_instance = $MeshInstance2D
@onready var boid_holder = get_tree().get_first_node_in_group("boid_holder")

func _ready():
	screensize = DisplayServer.window_get_size()
#	generate_meshes()
#	render_meshes()

func _process(_delta):
	var boid_array : Array = []
	for boid in boid_holder.get_children():
		boid_array.append(
			{
			rot = boid.rotation,
			pos = boid.position,
			col = boid.colour
			}
		)
	set_and_render_meshes(boid_array)
	

func render_meshes():
	multi_mesh.set_instance_count(0)
	multi_mesh.set_mesh(mesh_instance.mesh)
	multi_mesh.set_use_custom_data(1)
	multi_mesh.set_use_colors(1)
	multi_mesh.set_instance_count(meshes.size())
	var b_int = 0
	for i in meshes:
		var transformvec = Transform2D(i.rot, i.pos) if typeof(i) != TYPE_VECTOR2 else Transform2D(0, i)
		multi_mesh.set_instance_transform_2d(b_int, transformvec)
		multi_mesh.set_instance_color(b_int, i.col)
		b_int += 1


func generate_meshes():
	meshes.clear()
	for i in number_of_meshes:
		meshes.append(
			{
			rot = randf_range(0.0, TAU),
			pos = Vector2(randf_range(0.0, screensize.x), randf_range(0.0, screensize.y)),
			col = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0), 0.5)
			}
		)

func set_and_render_meshes(mesh_node_array: Array):
	meshes = mesh_node_array.duplicate(true)
	render_meshes()

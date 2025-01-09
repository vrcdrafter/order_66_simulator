
extends Node3D

@onready var Ray_thing :RayCast3D = get_node("RayCast3D")


func _process(delta: float) -> void:
	print(Ray_thing.get_collision_point())
	
	$CPUParticles3D.global_position = Ray_thing.get_collision_point()

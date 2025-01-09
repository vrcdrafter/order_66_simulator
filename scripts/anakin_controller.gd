extends Node3D

@onready var Anim :AnimationPlayer = get_node("anikin/AnimationPlayer")

func _ready() -> void:
	
	Anim.play("run")
	

func _process(delta: float) -> void:
	
	if Anim.is_playing():
		print("animation is playing")

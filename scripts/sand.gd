extends Node3D


@onready var sprite_sand1 :Sprite3D = get_node("Sprite3D")
@onready var sprite_sand2 :Sprite3D = get_node("Sprite3D2")
@onready var sprite_sand3 :Sprite3D = get_node("Sprite3D3")
@export var oneshot :bool = true
@export var reset = false

func _process(delta: float) -> void:
	
	if oneshot and not reset:
	
		tween_it(sprite_sand1,false)
		tween_it(sprite_sand2, false)
		tween_it(sprite_sand3, false)
		oneshot = false
	
	if reset:
		tween_it(sprite_sand1,true)
		tween_it(sprite_sand2, true)
		tween_it(sprite_sand3, true)
		oneshot = true
	
	
func tween_it(thing :Sprite3D, reset :bool):
	var tween = get_tree().create_tween()


	if reset:
		thing.hide()
		tween.parallel().tween_property(thing, "position", Vector3(0,0,0), 1)
		tween.parallel().tween_property(thing, "modulate", Color(1, 1, 1, 1), 1)
		tween.parallel().tween_property(thing, "scale", Vector3(1,1,1), 1)
	else :
		thing.show()
		tween.parallel().tween_property(thing, "position", Vector3(1,1,0), 1)
		tween.parallel().tween_property(thing, "modulate", Color(0, 0, 0, 0), 1)
		tween.parallel().tween_property(thing, "scale", Vector3(2,2,2), 1)
	#tween.tween_callback(sprite_sand.queue_free)

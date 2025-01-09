extends Node3D

@onready var anakin :Node3D = get_node("../CharacterBody3D")

var state :String = "idl"
var health :int = 10
var flee_position :Vector3
var t = 0.0
var bool_die :bool = true
var random_ting :bool = false


func _ready() -> void:
	
	$random_decision.start()

func _process(delta: float) -> void:
	
	match  state:
		
		"flee":
			$youngling/AnimationTree.set("parameters/Blend2/blend_amount", 1)
			t += delta * 0.001
			self.look_at(flee_position)
			global_position += (flee_position - global_position).normalized() * delta * 7
			if abs(global_position - flee_position).length() < .1:
				state = "idl"
			
		"taunt":
			self.look_at(anakin.global_position - Vector3(0,anakin.global_position.y,0))
			$youngling/AnimationTree.set("parameters/tease_blend/blend_amount", 1)
			
			var direction_to_anakin :Vector3 = abs(anakin.global_position - global_position)

			if direction_to_anakin.length() < 4:
				
				flee_position = Pick_point()
				if abs(anakin.global_position - flee_position).length() < 2:
					# pick a new point 
					
					flee_position = Pick_point()
				else:
					state = "flee"
			
			if random_ting:
				print("go back to idle")
				var random_number :int = randi() % 2
				print(random_number)
				if random_number == 1:
					state = "idl"
				random_ting = false

		"attack":
			print("attacking ")
			t += delta * 0.001 
			self.look_at(anakin.global_position)
			global_position += ((anakin.global_position - Vector3(0,anakin.global_position.y,0)) - global_position).normalized() * delta * 7
			if abs(global_position - anakin.global_position).length() < 4:
				print("go back to flee ")
				
				flee_position = Pick_point()
				if abs(anakin.global_position - flee_position).length() < 2:
					flee_position = Pick_point()
				else:
					state = "flee"
		"die":
			
			if bool_die:
				$youngling/AnimationTree.active = false
				$youngling/Armature/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
				print("simulation started")
				bool_die = false
		"idl":
			$youngling/AnimationTree.set("parameters/idle/blend_amount", 1)
			$youngling/AnimationTree.set("parameters/Blend2/blend_amount", 0)
			$youngling/AnimationTree.set("parameters/tease_blend/blend_amount", 0)
			var direction_to_anakin :Vector3 = abs(anakin.global_position - global_position)
			var distance = direction_to_anakin.length()
			if direction_to_anakin.length() < 4:
				
				flee_position = Pick_point()
				if abs(anakin.global_position - flee_position).length() < 2:
					flee_position = Pick_point()
				else:
					state = "flee"
					
			# also randomly do something else 
			if random_ting:
				
				var random_number :int = randi() % 3
				
				if random_number == 1:
					state = "taunt"
				if random_number == 2:
					state = "attack"
				random_ting = false
			
			
	

		
		
func Pick_point() ->Vector3:
	
	var mark_1_handle :Marker3D = get_node("../Marker3D")
	var pos_1 :Vector3 = mark_1_handle.global_position
	
	var mark_2_handle :Marker3D = get_node("../Marker3D2")
	var pos_2 :Vector3 = mark_2_handle.global_position
	
	var mark_3_handle :Marker3D = get_node("../Marker3D3")
	var pos_3 :Vector3 = mark_3_handle.global_position
	
	var new_point_z :float = randf_range(pos_1.z,pos_2.z)
	var new_point_x :float = randf_range(pos_2.x,pos_3.x)
	var new_point = Vector3(new_point_x,.5,new_point_z)
	
	return new_point
	


func _on_area_3d_area_entered(area: Area3D) -> void:
	
	health -= 5
	if health < 0:
		state = "die"
		


func _on_random_decision_timeout() -> void:
	random_ting = true

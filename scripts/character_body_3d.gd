extends CharacterBody3D

const SPEED = 8
const JUMP_VELOCITY = 4.5

@onready var pivot :Node3D = $camera_origin
@export var sens :float = 0.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# attack stuff
var attack_inrementer = 0
var go_to_idle = false
var transiton :float = 0 
@onready var ligh_saber :MeshInstance3D = get_node("Node3D/anikin/Armature/Skeleton3D/BoneAttachment3D/Node3D/MeshInstance3D")

# sounds 
var whirr :Resource 
var swing1 :Resource
var swing2 :Resource 
var swing3 :Resource 
var extinguish :Resource
var Audio_bool :bool = true
var Audio_bool_2 :bool = true
@onready var audio_close :AudioStreamPlayer = get_node("AudioStreamPlayer")
var sizzle :Resource

# particles 
var smoke :Resource
var smoke_instance :Node3D 

func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_setup_audio()
	_load_smoke()

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		# clamps the Y rotation 
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		

func _physics_process(delta: float) -> void:
	
	_set_smoke_position()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
		
		
		
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


	move_and_slide()
	
	character_state(input_dir,delta)
	
	
func character_state(direction :Vector2,delta :float):
	var anikin_rotation :Node3D = get_node("Node3D")
	var animations :AnimationPlayer = get_node("Node3D/anikin/AnimationPlayer")
	var anim_tre :AnimationTree = get_node("Node3D/AnimationTree")
	var one_shot :bool = true
	
	var attack_Vecotr

	
	match direction:
		Vector2(0,0):
			
			if one_shot:
				anikin_rotation.rotation_degrees = Vector3(0,90,0)
				anim_tre.set("parameters/run_blend/blend_amount", 0)
				one_shot = false
		Vector2(1,0):
			one_shot = true
			if one_shot:
				anikin_rotation.rotation_degrees = Vector3(0,0,0)
				anim_tre.set("parameters/run_blend/blend_amount", 1)
				
				one_shot = false

		Vector2(-1,0):
			one_shot = true
			if one_shot:
				anikin_rotation.rotation_degrees = Vector3(0,180,0)
				anim_tre.set("parameters/run_blend/blend_amount", 1)
				
				one_shot = false
		Vector2(0,-1):
			one_shot = true
			if one_shot:
				anikin_rotation.rotation_degrees = Vector3(0,90,0)
				anim_tre.set("parameters/run_blend/blend_amount", 1)
				
				one_shot = false
	if Input.is_action_just_pressed("attack"):
		go_to_idle = false
		ligh_saber.scale.y = 6.4
		ligh_saber.show()
		audio_close.stream = whirr
		audio_close.play()
		attack_inrementer += 1
	
		match  attack_inrementer:
			1:
				attack_Vecotr = Vector2(-1,0)
				audio_close.stream = swing1
				audio_close.play()
				Audio_bool = true # this is for the extinguish, this is bad code
			2:
				attack_Vecotr = Vector2(0,1)
				audio_close.stream = swing2
				audio_close.play()
			3:
				attack_Vecotr = Vector2(1,0)
				audio_close.stream = swing3
				audio_close.play()
				attack_inrementer = 0
		
		anim_tre.set("parameters/Blend2/blend_amount", 0)
		anim_tre.set("parameters/blend_attack/blend_position",attack_Vecotr)
		anim_tre.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		$Timer.start()

	if go_to_idle:
		
		if Audio_bool:
			audio_close.stream = extinguish
			audio_close.play()
			Audio_bool = false
		transiton += delta * .8
		var final_value = clamp(transiton,0,1)
		anim_tre.set("parameters/Blend2/blend_amount", final_value)
		ligh_saber.scale.y -= 5 * delta
		
		if final_value == 1 and ligh_saber.scale.y < 0:
			go_to_idle =false
			ligh_saber.hide()
			transiton = 0 
			final_value = 0
		


func _on_timer_timeout() -> void:
	print("go_to_idle")
	go_to_idle = true
	
	
func _setup_audio():
	whirr = load("res://sounds/hum.wav")
	
	swing1 = load("res://sounds/swing1.wav")
	swing1.set_name("swing1")
	swing2 = load("res://sounds/swing2.wav")
	swing2.set_name("swing2")
	swing3 = load("res://sounds/swing3.wav")
	swing3.set_name("swing3")
	
	extinguish = load("res://sounds/pwroff2.wav")
	extinguish.set_name("extinguish")
	
	sizzle = load("res://sounds/sizzle.wav")
	$AudioStreamPlayer2.stream = sizzle
	pass


func _on_audio_stream_player_finished() -> void:
	var current_stream :AudioStream = $AudioStreamPlayer.get_stream()
	
	if current_stream.get_name().contains("swing"):
		audio_close.stream = whirr
		audio_close.play()
		
	if ligh_saber.scale.y < 0:
		
		go_to_idle = false
		Audio_bool = true
		
		
func _load_smoke():
	
	smoke = load("res://scenes/smoke.tscn")
	smoke.set_name("smoke")
	smoke_instance = smoke.instantiate()
	smoke_instance.global_position = Vector3(0,0,0)
	add_sibling.call_deferred(smoke_instance)
	
func _set_smoke_position():
	var ray_handle :RayCast3D = get_node("Node3D/anikin/Armature/Skeleton3D/BoneAttachment3D/Node3D/RayCast3D")
	#print(ray_handle.collide_with_bodies)
	# audio handle 
	var audio_handle2 :AudioStreamPlayer = get_node("AudioStreamPlayer2")
	
	if ray_handle.is_colliding():
		
		if Audio_bool_2:
			
			audio_handle2.play()
			Audio_bool_2 = false
		
		var smoke_position :Vector3 = ray_handle.get_collision_point()
		smoke_instance.global_position = smoke_position
		
	else:
		
		Audio_bool_2 = true
		audio_handle2.stop()
		#print("wne into other condition ")
		smoke_instance.global_position = Vector3(0,-100,0)

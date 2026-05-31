extends VehicleBody3D

@onready var cam_traseira: Camera3D = $Perseg
@onready var cam_capo: Camera3D = $Capo
@onready var sound: AudioStreamPlayer3D = $Motor
@onready var velocimetro: Label = $Hud/Veloci

# Valores de comportamento
@export var MAX_ENGINE_FORCE: float = 500.0
@export var MAX_BRAKE_FORCE: float = 5.0
@export var MAX_STEER_ANGLE: float = 0.5
@export var steer_speed: float = 5.0
@export var MAX_SPEED_KMH: float = 260.0 # <-- Nossa nova variável de limite

var steer_target: float = 0.0
var steer_angle: float = 0.0
var switch_cam: bool = true

func handleSound():
	var newVal = (linear_velocity.length() / 52.0) + 0.5
	sound.set_pitch_scale(newVal)

func _ready() -> void:
	sound.play()

func _physics_process(delta: float) -> void:
	handleSound()
	
	var steer_val = Input.get_axis("ui_right", "ui_left") 
	var throttle_val = Input.get_action_strength("ui_up")
	var brake_val = Input.get_action_strength("ui_down")
	
	# 1. Calculamos a velocidade atual primeiro
	var speed_ms = linear_velocity.length()
	var speed_kmh = speed_ms * 3.6
	
	# 2. Atualizamos o velocímetro na tela
	velocimetro.text = "%d KM/H" % speed_kmh
	
	# 3. Lógica do Freio
	brake = brake_val * MAX_BRAKE_FORCE
	
	# 4. Lógica de Aceleração com Limite de Velocidade
	if speed_kmh < MAX_SPEED_KMH:
		# Se estiver abaixo do limite, acelera normalmente
		engine_force = throttle_val * MAX_ENGINE_FORCE
	else:
		# Se bater 260 km/h, corta a aceleração do motor (não freia, apenas para de acelerar)
		engine_force = 0.0 
	
	# 5. Lógica da Direção
	steer_target = steer_val * MAX_STEER_ANGLE
	steer_angle = move_toward(steer_angle, steer_target, steer_speed * delta)
	steering = steer_angle

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_V and event.pressed and not event.echo:
		
		switch_cam = !switch_cam
		
		if switch_cam:
			cam_traseira.make_current()
		else:
			cam_capo.make_current()

extends RigidBody2D

#padrao é 500 para tracao dianteira
export var torque := 650
#padrao é 25.0 para tracao dianteira
var rotacaoMotor := 25.0
#1 - Tracao dianteira / 2 - Tracao traseira / 3 - 4X4
var tipoTracao := 1
#padrao é 0.4 p/ qualquer tipo de tracao
#var taxaFriccaoRoda := 0.5

const inclinacaoDianteira = Vector2(-1, 1)
const inclinacaoTraseira = Vector2(1, 1)
const CONST_DE_INCLINACAO = 6.5

func _ready():
	pass
#	$RodaFrente.friction = taxaFriccaoRoda
#	$RodaTras.friction = taxaFriccaoRoda

func _process(delta):
	
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("TracaoDianteira"):
		tipoTracao = 1
	elif Input.is_action_just_pressed("TracaoTraseira"):
		tipoTracao = 2
	elif Input.is_action_just_pressed("4x4"):
		tipoTracao = 3
	
	if Input.is_action_pressed("ui_right"):
		
		if $RodaFrente.angular_velocity < rotacaoMotor and $RodaTras.angular_velocity < rotacaoMotor:
			if tipoTracao == 1:
				$RodaFrente.apply_torque_impulse(torque)
#				print($RodaFrente.angular_velocity)
				
			elif tipoTracao == 2:
				$RodaTras.apply_torque_impulse(torque)
#				print($RodaTras.angular_velocity)
				
			elif tipoTracao == 3:
				$RodaFrente.apply_torque_impulse(torque/2)
				$RodaTras.apply_torque_impulse(torque/2)
				
#				if $RodaFrente.angular_velocity > $RodaTras.angular_velocity:
#					print($RodaFrente.angular_velocity)
#				else:
#					print($RodaTras.angular_velocity)
		
		$RodaTras.apply_impulse(inclinacaoTraseira, inclinacaoTraseira * CONST_DE_INCLINACAO)
		
	elif Input.is_action_pressed("ui_left"):
		
		if $RodaFrente.angular_velocity > -rotacaoMotor and $RodaTras.angular_velocity > -rotacaoMotor:
			if tipoTracao == 1:
				$RodaFrente.apply_torque_impulse(-torque)
#				print($RodaFrente.angular_velocity)
				
			elif tipoTracao == 2:
				$RodaTras.apply_torque_impulse(-torque)
#				print($RodaTras.angular_velocity)
				
			elif tipoTracao == 3:
				$RodaFrente.apply_torque_impulse(-torque/2)
				$RodaTras.apply_torque_impulse(-torque/2)
				
#				if $RodaFrente.angular_velocity > $RodaTras.angular_velocity:
#					print($RodaFrente.angular_velocity)
#				else:
#					print($RodaTras.angular_velocity)
			
		$RodaFrente.apply_impulse(inclinacaoDianteira, inclinacaoDianteira * CONST_DE_INCLINACAO)

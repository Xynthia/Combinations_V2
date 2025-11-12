extends CharacterBody2D
class_name Player

const SPEED = 200.0
const DASH = 750.0
const JUMP_VELOCITY = -500
const PUSH_FORCE = 1.3

@onready var red = %Red
@onready var blue = %Blue
@onready var green = %Green



@onready var body : CollisionShape2D = $body

@onready var combiTimer = $Sprites/combiChar/Timer

@onready var dash_timer : Timer = $DashTimer

@onready var shield_icon = $Sprites/Shield
@onready var shield_timer = $Sprites/Shield/Timer

@onready var actionLabel = $actionLabel

@onready var charsNode = $Sprites/Chars
@onready var charPositionNode = $Sprites/charPosition

@onready var animation : AnimationPlayer = $Sprites/AnimationPlayer
@onready var attackBeam = $Sprites/AttackBeam/Sprite2D

@onready var push_area: Area2D = $pushArea

var red_color : Color = Color.RED
var green_color : Color = Color.GREEN
var blue_color : Color = Color.BLUE
var purple : Color = Color.PURPLE
var cyan : Color = Color.CYAN
var orange : Color = Color.ORANGE

var attackAnimation : Animation 

var charWorldPositions : Array
var charPositions : Array 
var allChars : Array
var current_char
var last_char

var canCombo : bool = true
var canAttack : bool = true
var can_be_hit : bool = true
var attacking : bool = false

var enemy_attacked : Enemy

var dashVolocity : float = 0.0
var tween : Tween
var dashing : bool = false



var direction

var health : int = 5


var pushableObjects : Array 




func _ready() -> void:
	GameManager.player = self
	
	for char in charsNode.get_children():
		allChars.push_back(char)
	
	for charPos in charPositionNode.get_children():
		charWorldPositions.push_back(charPos.global_position)
	
	for charSlot in charPositionNode.get_children():
		charPositions.push_back(charSlot)
	
	setCharPos(red, 0)
	setCharPos(blue, 1)
	setCharPos(green, 2)
	
	
	updateSprite()
	set_default_color()

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("moveLeft", "moveRight")
	
	if Input.is_action_just_pressed("switchChar"):
		changeCharToPos(1, 2)
		updateSprite()
		
	if Input.is_action_just_pressed("combination") and canCombo == true:
		changeCharToPos(0, 2)
		updateSprite()
		combination()
	
	if Input.is_action_just_pressed("action") and is_on_floor():
		action()
	
	if Input.is_action_just_pressed("reload"):
		died()
	
	if health == 0:
		died()
	
	move()



func change_group_layout():
	if Input.is_action_just_pressed("moveLeft"):
		charPositionNode.layout_direction = Control.LayoutDirection.LAYOUT_DIRECTION_LTR
		red.flip_h = true
		green.flip_h = true
		for sprite in blue.get_children():
			sprite.flip_h = true
	if Input.is_action_just_pressed("moveRight") :
		charPositionNode.layout_direction = Control.LayoutDirection.LAYOUT_DIRECTION_RTL
		red.flip_h = false
		green.flip_h = false
		for sprite in blue.get_children():
			sprite.flip_h = false
	

func setCharPos(color, index):
	charPositions[index] = color

func changeCharToPos(setCharIndex, positionIndex: int) -> void:
	var newPosChar = charPositions[positionIndex]
	var oldPosChar = charPositions[setCharIndex]
	charPositions[setCharIndex] = newPosChar
	charPositions[positionIndex] = oldPosChar
	

func updateSprite() -> void:
	for charIndex in charPositions.size():
		charPositions[charIndex].reparent(charPositionNode.get_children()[charIndex], true)
	
	
	red.position.x = 0
	red.position.y = 0
	blue.position.x = 0
	blue.position.y = 0
	green.position.x = 0
	green.position.y = 0


func combination():
	current_char = charPositions[0]
	last_char = charPositions[2]
	
	canCombo = false
	
	if (last_char == red and current_char == blue or last_char == blue and current_char == red):
		backStab()
		current_char.modulate = purple
	if (last_char == red and current_char == green or last_char == green and current_char == red):
		parry()
		current_char.modulate = orange
	if (last_char == green and current_char == blue or last_char == blue and current_char == green):
		pushBack()
		current_char.modulate = cyan
	
	charPositions[2].visible = false
	combiTimer.start()


func action():
	current_char = charPositions[0]
	
	if (current_char == blue):
		jump()
	if (current_char == red):
		attack()
	if (current_char == green):
		shield()
	

func takeDamage():
	if can_be_hit == true:
		health -= 1
		
		GameManager.ui.update_healh_points()
	

func reset_health():
	health = 5;

func died():
	GameManager.ui.center_container_3.visible = false
	get_tree().reload_current_scene()

func jump():
	velocity.y = JUMP_VELOCITY

func attack():
	if canAttack == true:
		canAttack == false
		
		if direction == 0 or direction == 1:
			play_attack_animation()
		elif direction == -1:
			play_left_attack_animation()
		
		if attacking == true:
			if enemy_attacked:
				GameManager.damage_enemy(enemy_attacked)
		

func play_attack_animation():
	animation.play("PlayerAnimation/attack")

func play_left_attack_animation():
	animation.play("PlayerAnimation/attackLeft")

func shield():
	shield_icon.visible = true
	can_be_hit = false
	
	shield_timer.start()

func move():
	if direction:
		velocity.x = direction * (SPEED + dashVolocity)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	change_group_layout()
	
	move_and_slide()

func dash():
	if dashing == false:
		dashing = true
		set_collision_mask_value(3, false)
		can_be_hit = false
		
		dash_timer.start()
		dashVolocity = DASH
	
	if tween:
		tween.stop()
	tween = create_tween()
	tween.tween_property(self, "dashVolocity", 0, 0.3).set_ease(Tween.EASE_OUT)


func parry():
	shield()
	attack()

func pushBack():
	shield()
	
	if pushableObjects != null:
		for object  in pushableObjects:
			if object.is_in_group("Enemy"):
				var shape : Shape2D =  push_area.get_child(0).shape
				var max_range = shape.get_rect().size.x / 2
				
				object.push(position.x, max_range)
			else:
				var impulse : Vector2
				impulse.x = -200
				impulse.y = -500
				object.apply_central_impulse(impulse)


	

func backStab():
	dash()
	
	change_group_layout()
	if charPositionNode.layout_direction == Control.LayoutDirection.LAYOUT_DIRECTION_LTR:
		charPositionNode.layout_direction = Control.LayoutDirection.LAYOUT_DIRECTION_RTL
	elif charPositionNode.layout_direction == Control.LayoutDirection.LAYOUT_DIRECTION_RTL:
		charPositionNode.layout_direction = Control.LayoutDirection.LAYOUT_DIRECTION_LTR
	
	attack()



func _on_timer_timeout() -> void:
	shield_icon.visible = false
	can_be_hit = true

func set_default_color():
	red.modulate = red_color
	blue.modulate = blue_color
	green.modulate = green_color

func _on_combi_timer_timeout() -> void:
	set_default_color()
	
	for char in charPositions:
		if char.visible == false:
			char.visible = true
	
	canCombo = true

func _on_push_area_body_entered(body: Node2D) -> void:	
	if body.is_in_group("PushableOpbject"):
		pushableObjects.push_back(body)

func _on_push_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("PushableOpbject"):
		pushableObjects.erase(body)


func _on_dash_timer_timeout() -> void:
	set_collision_mask_value(3, true)
	can_be_hit = true
	dashing = false


func _on_attack_beam_area_body_entered(body: Node2D) -> void:
	var enemy : Enemy = body
	
	if enemy.is_in_group("Enemy"):
		attacking = true
		enemy_attacked = enemy


func _on_attack_beam_area_body_exited(body: Node2D) -> void:
	var enemy : Enemy = body
	
	if enemy.is_in_group("Enemy"):
		attacking = false


func _on_attack_timer_timeout() -> void:
	canAttack = true

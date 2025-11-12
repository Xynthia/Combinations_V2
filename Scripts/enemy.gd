extends CharacterBody2D
class_name Enemy

const SPEED : float = 100
const JUMP_VELOCITY : float = -200
const MIN_PUSH_FORCE : float = 2
const MAX_PUSH_FORCE : float = 15


@onready var ray_cast_right : RayCast2D = $RayCastRight
@onready var ray_cast_left : RayCast2D = $RayCastLeft
@onready var view_range : Area2D = $ViewRange

@onready var attack_node: Control = $Attack
@onready var attack_beam: ColorRect = $Attack/AttackBeam
@onready var attack_cooldown_timer : Timer = $Attack/AttackBeam/AttackCooldownTimer

@onready var animation : AnimationPlayer = $Attack/AnimationPlayer

@onready var sprite : AnimatedSprite2D = $Sprite

@onready var push_timer: Timer = $PushTimer

var attack_animation : Animation 

var health_state_color_5 : Color = Color(0.0, 0.0, 0.0)
var health_state_color_4 : Color = Color(0.0, 0.0, 0.0, 0.835)
var health_state_color_3 : Color = Color(0.0, 0.0, 0.0, 0.667)
var health_state_color_2 : Color = Color(0.0, 0.0, 0.0, 0.502)
var health_state_color_1 : Color = Color(0.576, 0.576, 0.576, 0.333)

var can_attack : bool = true
var can_attack_player : bool = false
var attacking : bool = false

var pushed : bool = false

var direction : float = 1
var movement : Vector2
var vector_enemy_to_player : Vector2
var player_in_view_range : bool = false

var health : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.enemies.push_back(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_on_floor() && pushed == false:
		velocity += get_gravity() * delta
	
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	
	if pushed == false:
		velocity.x = direction * SPEED 
	
	if can_attack == true && player_in_view_range == true && can_attack_player == true:
		attack()
	
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h  = false
	
	update_health_points()
	
	move_and_slide()
	

func play_animation_attack() -> void:
	animation.play("EnemyAnimation/attack")

func play_animation_attack_left() -> void:
	animation.play("EnemyAnimation/attackLeft")


func attack():
	can_attack = false
	attack_cooldown_timer.start()
	
	if direction == 1 and vector_enemy_to_player.x >= 0.5:
		play_animation_attack()
	
	if direction == -1 and vector_enemy_to_player.x <= -0.5:
		play_animation_attack_left()
	

	
	if attacking == true:
		GameManager.player.takeDamage()
		attacking = false

func take_damage():
	health -= 1

func push(player_x: float, max_range: float):
	push_timer.start()
	pushed = true
	
	var distance = (position.x - player_x)
	
	var multiplier = MAX_PUSH_FORCE - (distance / max_range) * (MAX_PUSH_FORCE - MIN_PUSH_FORCE)
	
	velocity.x = (position.x - player_x) *  multiplier
	
	if velocity.x > 0:
		direction = 1
	elif velocity.x < 0:
		direction = -1
	
	
	velocity.y = JUMP_VELOCITY

func update_health_points():
	match health:
		5:
			sprite.modulate = health_state_color_5
		4:
			sprite.modulate  = health_state_color_4
		3:
			sprite.modulate  = health_state_color_3
		2:
			sprite.modulate  = health_state_color_2
		1:
			sprite.modulate = health_state_color_1
		0: 
			queue_free()


func _on_view_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_view_range = true

func _on_view_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_view_range = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player : Player = body
		
		vector_enemy_to_player = (body.position - self.position).normalized()
		
		for child in player.get_children():
			if child == player.body:
				can_attack_player = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player : Player = body
		
		for child in player.get_children():
			if child == player.body:
				can_attack_player = false

func _on_attack_beam_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		attacking = true
		vector_enemy_to_player = (body.position - self.position).normalized()


func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true


func _on_push_timer_timeout() -> void:
	pushed = false

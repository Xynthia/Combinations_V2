extends CanvasLayer
class_name UI

@onready var health_points_node = $MarginContainer/CenterContainer/HealtPoints

@onready var health_point_1 : ColorRect = $MarginContainer/CenterContainer/HealtPoints/Health1
@onready var health_point_2 : ColorRect = $MarginContainer/CenterContainer/HealtPoints/Health2
@onready var health_point_3 : ColorRect = $MarginContainer/CenterContainer/HealtPoints/Health3
@onready var health_point_4 : ColorRect = $MarginContainer/CenterContainer/HealtPoints/Health4
@onready var health_point_5 : ColorRect = $MarginContainer/CenterContainer/HealtPoints/Health5

@onready var center_container_2: CenterContainer = $MarginContainer/CenterContainer2
@onready var label_enemies : Label = $MarginContainer/CenterContainer2/Label

@onready var center_container_3: CenterContainer = $MarginContainer/CenterContainer3
@onready var timer: Timer = $MarginContainer/CenterContainer3/Timer





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.ui = self



func update_label(enemies_left : int):
	label_enemies.visible = true
	label_enemies.text = "Enemies left: " + str(enemies_left)
	

func update_won_screen():
	center_container_3.visible = true

func update_healh_points():
	var player : Player = GameManager.player
	
	match player.health:
		5:
			health_point_1.visible = true
			health_point_2.visible = true
			health_point_3.visible = true
			health_point_4.visible = true
			health_point_5.visible = true
		4:
			health_point_1.visible = true
			health_point_2.visible = true
			health_point_3.visible = true
			health_point_4.visible = true
			health_point_5.visible = false
		3:
			health_point_1.visible = true
			health_point_2.visible = true
			health_point_3.visible = true
			health_point_4.visible = false
			health_point_5.visible = false
		2:
			health_point_1.visible = true
			health_point_2.visible = true
			health_point_3.visible = false
			health_point_4.visible = false
			health_point_5.visible = false
		1:
			health_point_1.visible = true
			health_point_2.visible = false
			health_point_3.visible = false
			health_point_4.visible = false
			health_point_5.visible = false
		0:
			health_point_1.visible = false
			health_point_2.visible = false
			health_point_3.visible = false
			health_point_4.visible = false
			health_point_5.visible = false


func _on_timer_timeout() -> void:
	GameManager.player.died()


func _on_center_container_3_visibility_changed() -> void:
	timer.start()

extends Node

var enemies : Array

var player : Player
var ui : UI

var area_1_check
var arena_box_1 
var arena_box_2 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	check_enemies_left()

func damage_enemy(body : Enemy):
	for enemy : Enemy in enemies:
		if enemy == body:
			enemy.take_damage()
			
			if enemy.health == 0:
				enemies.remove_at(enemy.get_index())
	

func check_enemies_left():
	if area_1_check:
		ui.update_label(enemies.size())
		
		if enemies.size() == 4:
			if arena_box_1 != null and arena_box_2 != null:
				arena_box_1.queue_free()
				arena_box_2.queue_free()
		
		if enemies.size() == 2:
			for enemy : Enemy in enemies:
				enemy.set_collision_mask_value(5, false)
		
		if enemies.size() == 0:
			ui.update_won_screen()

extends Node2D


@onready var moveble_block_3: RigidBody2D = $MovebleBlock3
@onready var moveble_block_4: RigidBody2D = $MovebleBlock4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.arena_box_1 = moveble_block_3
	GameManager.arena_box_2 = moveble_block_4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

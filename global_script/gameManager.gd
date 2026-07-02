class_name gameManager
extends Node

var current_enemy={}

var player_stats:Dictionary = {
	"hp": 100,
	"money": 10,
}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	pass

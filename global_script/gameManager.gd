class_name gameManager
extends Node

var current_enemy={}

var player_stats:Dictionary = {
	"hp": 100,
	"money": 10,
	"damage": 10,
	"accuracy": 90,
	"effectivity": 90,
	"buff": 0,
	"debuff": 0
}

var player_body:Dictionary = {
	"rArm": true,
	"lArm": true,
	"Eye": true,
}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	current_enemy = {
		"name": "test",
		"sprite": load("res://icon.svg"),
		"hp": 100
	}

func _process(delta: float) -> void:
	pass

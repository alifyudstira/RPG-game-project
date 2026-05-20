extends Area2D

var playerEnter:bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if playerEnter and Input.is_action_just_pressed("ui_accept"):
			print("enter store")
			get_tree().change_scene_to_file("res://store/store_ui.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body is player:
		print("player enter")
		playerEnter = true

func _on_body_exited(body: Node2D) -> void:
	if body is player:
		print("player enter")
		playerEnter = false

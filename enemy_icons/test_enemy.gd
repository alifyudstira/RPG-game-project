extends Area2D

@export var enemy_name: String
@export var enemy_sprite: Texture2D
@export var hp: int

func _on_body_entered(body: Node2D) -> void:
	if body is player:
		print("player detected")
		GameManager.current_enemy = {
			"name": enemy_name,
			"sprite": enemy_sprite,
			"hp": hp
		}
		get_tree().change_scene_to_file("res://arena/arena.tscn")

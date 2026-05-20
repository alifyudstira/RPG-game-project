extends Area2D

@export var enemy_name: String
@export var enemy_sprite: Texture2D
@export var hp: int

func _on_body_entered(body: Node2D) -> void:
	if body is player:
		body.set_physics_process(false)
		GameManager.current_enemy = {
			"name": enemy_name,
			"sprite": enemy_sprite,
			"hp": hp
		}
		
		var camera = get_tree().get_first_node_in_group("camera")
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", Vector2(10, 10), 0.5)
		await tween.finished
		get_tree().change_scene_to_file("res://arena/arena.tscn")

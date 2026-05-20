extends Node2D

@onready var hpBar = $enemyLoc/ProgressBar
@onready var panelArrow = $CanvasLayer/Panel2
@onready var arrowBox = $CanvasLayer/Panel2/HBoxContainer
@onready var arrows = $CanvasLayer/Panel2/HBoxContainer.get_children()
@onready var qteTimer = $qteTimer
@onready var qteTimerBar = $CanvasLayer/Panel2/qteBar
@onready var arrow_texture = {
	"ui_up" : preload("res://arena/arrows/ui_up.svg"),
	"ui_down" : preload("res://arena/arrows/ui_down.svg"),
	"ui_left" : preload("res://arena/arrows/ui_left.svg"),
	"ui_right" : preload("res://arena/arrows/ui_right.svg")
}

var enemyHp:int
var sequence:Array = []
var current_index:int = 0
var mistakes:int = 0
var actions:Array = ["ui_up", "ui_down", "ui_left", "ui_right"]
var finish:bool = false

func _ready() -> void:
	panelArrow.visible = false
	var enemy = GameManager.current_enemy
	$enemyLoc/enemyTexture.texture = enemy["sprite"]
	$enemyLoc/enemyName.text = enemy["name"]
	hpBar.max_value = enemy["hp"]
	enemyHp = enemy["hp"]
	
	setup_timer()

func _process(delta: float) -> void:
	hpBar.value = enemyHp
	
	if Input.is_action_just_pressed("ui_accept"):
		generate_sequence()
	
	qteTimerBar.value = qteTimer.time_left
	
	qte_input()
	
	if hpBar.value < 1:
		get_tree().change_scene_to_file("res://world/world.tscn")

func setup_timer():
	qteTimerBar.max_value = qteTimer.wait_time
	qteTimerBar.value = qteTimerBar.max_value

func generate_sequence():
	qteTimer.start()
	panelArrow.visible = true
	for arrow in arrows:
		arrow.self_modulate = Color8(255, 255, 255, 255)
	sequence.clear()
	for i in range(arrows.size()):
		sequence.append(actions[randi() % actions.size()])
	print(sequence)
	proceed_ui()

func proceed_ui():
	for i in range(arrows.size()):
		arrows[i].texture = arrow_texture[sequence[i]]

func qte_input():
	if sequence.is_empty():
		return
	
	if Input.is_action_just_pressed(sequence[current_index]):
		arrows[current_index].self_modulate = Color8(255, 255, 255, 150)
		current_index += 1
		print("correct")
		if current_index >= sequence.size():
			finish_qte()
	else:
		for action in actions:
			if Input.is_action_just_pressed(action):
				arrows[current_index].self_modulate = Color8(255, 30, 30, 150)
				shake()
				print("wrong")
				mistakes += 1
				current_index += 1
				if current_index >= sequence.size():
					finish_qte()
				break

func shake():
	var tween = create_tween()
	var original_position = arrows[current_index].position
	var shake_amount = 5
	
	for i in range(6):
		var target = original_position
		target.x += randf_range(-shake_amount, shake_amount)
		target.y += randf_range(-shake_amount, shake_amount)
		tween.tween_property(arrows[current_index], "position", target, 0.05)
	
	tween.tween_property(arrows[current_index], "position", original_position, 0.05)

func finish_qte():
	print("clear")
	print(hpBar.value)
	panelArrow.visible = false
	sequence.clear()
	mistakes = 0
	current_index = 0

func _on_qte_timer_timeout() -> void:
	finish_qte()

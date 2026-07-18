extends Node2D

@onready var hpBar = $enemyLoc/ProgressBar
@onready var panelArrow = $CanvasLayer/Panel2
@onready var arrowBox = $CanvasLayer/Panel2/HBoxContainer
@onready var arrows = $CanvasLayer/Panel2/HBoxContainer.get_children()
@onready var qteTimer = $qteTimer
@onready var qteTimerBar = $CanvasLayer/Panel2/qteBar
@onready var ui_ctrl = $ui_ctrl
@onready var arrow_texture = {
	"ui_up" : preload("res://arena/arrows/ui_up.svg"),
	"ui_down" : preload("res://arena/arrows/ui_down.svg"),
	"ui_left" : preload("res://arena/arrows/ui_left.svg"),
	"ui_right" : preload("res://arena/arrows/ui_right.svg")
}

var dmgDealed:int
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
	
	if Input.is_action_just_pressed("debug"):
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
		if current_index >= sequence.size():
			hit_or_miss()
			finish_qte()
	else:
		for action in actions:
			if Input.is_action_just_pressed(action):
				arrows[current_index].self_modulate = Color8(255, 30, 30, 150)
				shake()
				mistakes += 1
				current_index += 1
				if current_index >= sequence.size():
					hit_or_miss()
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
	print(hpBar.value)
	panelArrow.visible = false
	sequence.clear()
	mistakes = 0
	current_index = 0

func _on_qte_timer_timeout() -> void:
	finish_qte()

#==========================================================================
#execution pipeline
#==========================================================================
func hit_or_miss():
	var value = randi_range(1, 100)
	
	if value > GameManager.player_stats["accuracy"]:
		print("Miss")
	else:
		execute_attack()

func execute_attack():
	var normalDmg = GameManager.player_stats["damage"]
	var reduction = float(mistakes * 5) / 100.0 * normalDmg
	dmgDealed = normalDmg - int(round(reduction))
	dmgDealed = max(dmgDealed, 0)
	enemyHp -= dmgDealed
	print("Damage dealed: ", dmgDealed)
	ui_ctrl.dmg_dealed_ui(dmgDealed)

#==========================================================================
#sacrifice
#==========================================================================
func _on_arm_pressed() -> void:
	if GameManager.player_body["rArm"]:
		GameManager.player_body["rArm"] = false
		$CanvasLayer/Debug/rArm.text = "R. Arm = 0"
		
		GameManager.player_stats["effectivity"] -= 10
		
	elif GameManager.player_body["lArm"]:
		GameManager.player_body["lArm"] = false
		$CanvasLayer/Debug/lArm.text = "L. Arm = 0"
		
		GameManager.player_stats["effectivity"] -= 10
		
	else:
		print("No arm left")

func _on_eye_pressed() -> void:
	if GameManager.player_body["Eye"]:
		GameManager.player_body["Eye"] = false
	else:
		print("Unable to commit attack")

#==========================================================================
#attack
#==========================================================================
func _on_attk_pressed() -> void:
	generate_sequence()

#==========================================================================
#item
#==========================================================================
func _on_item_pressed() -> void:
	ui_ctrl.change_ui("item")

#==========================================================================
#defend
#==========================================================================
func _on_defend_pressed() -> void:
	pass # Replace with function body.

extends Control

@export var item_btn:PackedScene
@export var dialogue_json_path: String = "res://json/Toko.json"
@export var dialogue_start_id: String = "Start"

var storeItemDb = StoreItems.testStore
var playerInv = InvManager.inv
var playerStats = GameManager.player_stats
var leftBarState:String = "options"
var leftBarChildren:Array

@onready var itemList = $leftBar/MarginContainer/itemBar/itemList
@onready var itemBar = $leftBar/MarginContainer/itemBar
@onready var options = $leftBar/MarginContainer/options
@onready var optionList = $leftBar/MarginContainer/options/optionList
@onready var talkBar = $leftBar/MarginContainer/talkBar
@onready var talkList = $leftBar/MarginContainer/talkBar/talkList
@onready var itemInfo = $descPanel/MarginContainer/VBoxContainer/itemInfo
@onready var descPanelName = $descPanel/MarginContainer/VBoxContainer/itemInfo/name
@onready var descPanelDesc = $descPanel/MarginContainer/VBoxContainer/itemInfo/desc
@onready var descPanelPrice = $descPanel/MarginContainer/VBoxContainer/itemInfo/price
@onready var dialoguePanel = $descPanel/MarginContainer/VBoxContainer/dialogPanel
@onready var playerMoneyUi = $money/playerMoney
@onready var dialogBox = $dialogBox

func _ready() -> void:
	left_bar_state_ctrl("options")
	
	itemInfo.visible = false
	
	dialoguePanel.text = "Hello Stranger, what a nice day to take a walk. May you interested to buy or sell something?"
	
	DialogManager.dialogue_updated.connect(_on_dialogue_updated)
	DialogManager.options_presented.connect(_on_options_presented)
	DialogManager.dialogue_ended.connect(_on_dialogue_ended)
	
	optionList.get_node("talk").pressed.connect(_on_talk_pressed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		left_bar_state_ctrl("options")
	
	_on_dialogue()
	focus_ctrl()
	money_update()

func money_update():
	playerMoneyUi.text = "$ " + str(playerStats["money"])

func focus_ctrl():
	var focusedNode = get_viewport().gui_get_focus_owner()
	
	if focusedNode:
		match leftBarState:
			"buy":
				var key = focusedNode.get_parent().name
				for item in storeItemDb:
					if item.name == key:
						descPanelName.text = item.name
						descPanelDesc.text = item.desc
						descPanelPrice.text = str(item.buyPrice) + "$"
						break
			"sell":
				var key = focusedNode.get_parent().name
				for entry_key in playerInv:
					var item = playerInv[entry_key]["resource"]
					if item.name == key:
						descPanelName.text = item.name
						descPanelDesc.text = item.desc
						descPanelPrice.text = str(item.sellPrice) + "$"
						break
	else:
		if  Input.is_action_just_pressed("ui_down"):
			match leftBarState:
				"buy":
					itemList.get_child(0).find_child("itemButton").grab_focus()
				"sell":
					itemList.get_child(0).find_child("itemButton").grab_focus()
				"options":
					optionList.get_child(0).grab_focus()
				"talk":
					talkList.get_child(0).grab_focus()

func populate_list(mode:String):
	for child in itemList.get_children():
		child.free()
	
	match mode:
		"buy":
			for item in storeItemDb:
				print(item)
				var row = item_btn.instantiate()
				row.name = item.name
				row.find_child("name").text = item.name
				row.find_child("price").text = str(item.buyPrice)
				itemList.add_child(row)
		"sell":
			for key in playerInv:
				var item = playerInv[key]["resource"]
				var quantity = playerInv[key]["quantity"]
				var row = item_btn.instantiate()
				row.name = item.name
				row.find_child("name").text = "%s x%d" % [item.name, quantity]
				row.find_child("price").text = str(item.sellPrice)
				itemList.add_child(row)
	
	leftBarChildren = $leftBar.get_children()

func left_bar_state_ctrl(new_state:String):
	leftBarState = new_state
	
	match leftBarState:
		"buy":
			leftBarState = "buy"
			
			itemBar.visible = true
			options.visible = false
			talkBar.visible = false
			itemInfo.visible = true
			dialoguePanel.visible = false
			populate_list("buy")
		"sell":
			leftBarState = "sell"
			
			itemBar.visible = true
			options.visible = false
			talkBar.visible = false
			itemInfo.visible = true
			dialoguePanel.visible = false
			populate_list("sell")
		"options":
			leftBarState = "options"
			
			itemBar.visible = false
			options.visible = true
			talkBar.visible = false
		"talk":
			leftBarState = "talk"
			
			itemBar.visible = false
			options.visible = false
			talkBar.visible = true
		_:
			pass

func _on_buy_pressed() -> void:
	get_viewport().gui_release_focus()
	left_bar_state_ctrl("buy")

func _on_sell_pressed() -> void:
	get_viewport().gui_release_focus()
	left_bar_state_ctrl("sell")

func _on_talk_pressed() -> void:
	get_viewport().gui_release_focus()
	left_bar_state_ctrl("talk")
	DialogManager.start_dialogue(dialogue_json_path, "Start")

#============================================
# Dialog Manager
#============================================

func _on_dialogue():
	# Input hanya diproses jika dialog box aktif DAN talkList tidak punya tombol pilihan
	if dialogBox.visible and talkList.get_child_count() == 0:
		if Input.is_action_just_pressed("ui_accept"):
			DialogManager.advance()

func _on_dialogue_updated(node_data: Dictionary):
	dialogBox.visible = true
	dialogBox.display(node_data.get("character", ""), node_data.get("text", ""))
	
	# Bersihkan tombol opsi lama setiap kali pindah node.
	# Kalau node ini punya options baru, _on_options_presented akan
	# mengisi ulang talkList setelah ini.
	for child in talkList.get_children():
		child.queue_free()

func _on_options_presented(option: Array):
	var full_dialogue = DialogManager.dialogue_data
	
	for optionID in option:
		var clyde_text = ""
		for node in full_dialogue:
			if node.get("id") == optionID:
				clyde_text = node.get("text", "")
				break
		
		if clyde_text == "":
			clyde_text = optionID
			
		var btn = Button.new()
		btn.name = optionID
		btn.text = clyde_text
		btn.focus_mode = Control.FOCUS_ALL
		
		btn.pressed.connect(_on_dialogue_option_selected.bind(optionID))
		
		talkList.add_child(btn)
	
	await get_tree().process_frame
	if talkList.get_child_count() > 0:
		talkList.get_child(0).grab_focus()

func _on_dialogue_option_selected(option_id: String):
	dialogBox.visible = true
	get_viewport().gui_release_focus()
	DialogManager.select_option(option_id)

func _on_dialogue_ended():
	dialogBox.visible = false

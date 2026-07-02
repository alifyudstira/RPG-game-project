extends Control

@export var item_btn:PackedScene

var storeItemDb = StoreItems.testStore
var playerInv = InvManager.inv
var playerStats = GameManager.player_stats
var leftBarState:String = "options"
var leftBarChildren:Array

@onready var itemList = $leftBar/itemBar/itemList
@onready var itemBar = $leftBar/itemBar
@onready var options = $leftBar/options
@onready var optionList = $leftBar/options/optionlList
@onready var talkBar = $leftBar/talkBar
@onready var talkList = $leftBar/talkBar/talkList
@onready var itemInfo = $descPanel/VBoxContainer/itemInfo
@onready var descPanelName = $descPanel/VBoxContainer/itemInfo/name
@onready var descPanelDesc = $descPanel/VBoxContainer/itemInfo/desc
@onready var descPanelPrice = $descPanel/VBoxContainer/itemInfo/price
@onready var dialoguePanel = $descPanel/VBoxContainer/dialogue
@onready var playerMoneyUi = $money/playerMoney

func _ready() -> void:
	left_bar_state_ctrl("options")
	
	itemInfo.visible = false
	
	dialoguePanel.text = "Hello Stranger, what a nice day to take a walk. May you interested to buy or sell something?"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		left_bar_state_ctrl("options")
	
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

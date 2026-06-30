extends Control

@export var item_btn:PackedScene

var storeItemDb = StoreItems.testStore
var playerInv = InvManager.inv
var leftBarState:String = "options"
var leftBarChildren = $leftBar.get_children()

@onready var itemBar = $leftBar/itemBar/itemList
@onready var option = $leftBar/sellItem/optionList
@onready var descPanelName = $descPanel/VBoxContainer/Control/name
@onready var descPanelDesc = $descPanel/VBoxContainer/Control/desc
@onready var descPanelPrice = $descPanel/VBoxContainer/Control/price
@onready var dialoguePanel = $descPanel/VBoxContainer/dialogue

func _ready() -> void:
	leftBarState = "options"
	for node in leftBarChildren:
		if node.name != "options":
			node.visible = false
	
	$descPanel/VBoxContainer/Control.visible = false
	
	dialoguePanel.text = "Hello Stranger, what a nice day to take a walk. May you interested to buy or sell something"
	
	populate_list()

func _process(delta: float) -> void:
	focus_ctrl()

func focus_ctrl():
	var focusedNode = get_viewport().gui_get_focus_owner()
	
	
	if focusedNode:
		if leftBarState == "buy":
			var key = focusedNode.get_parent().name
			for item in storeItemDb:
				if item.name == key:
					descPanelName.text = item.name
					descPanelDesc.text = item.desc
					descPanelPrice.text = str(item.buyPrice) + "$"
					break
	else:
		if  Input.is_action_just_pressed("ui_down"):
			itemBar.get_child(0).find_child("itemButton").grab_focus()

func populate_list():
	for child in itemBar.get_children():
		child.free()
	
	for item in storeItemDb:
		print(item)
		var row = item_btn.instantiate()
		row.name = item.name
		row.find_child("name").text = item.name
		row.find_child("price").text = str(item.buyPrice)
		itemBar.add_child(row)

func left_bar_state_ctrl(leftBarState:String):
	match leftBarState:
		"buy":
			for node in leftBarChildren:
				pass

func _on_buy_pressed() -> void:
	left_bar_state_ctrl("buy")

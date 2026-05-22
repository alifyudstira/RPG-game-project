extends Control

@export var inv_row:PackedScene

@onready var items = InvManager.inv
@onready var itemList = $HBoxContainer/ScrollContainer/itemList
@onready var itemLabel:Label = $HBoxContainer/Panel/VBoxContainer/itemName
@onready var itemDesc:Label = $HBoxContainer/Panel/VBoxContainer/itemDesc

var lastRow:int = 0

func _ready() -> void:
	populate_list()

func _process(delta: float) -> void:
	var focusedNode = get_viewport().gui_get_focus_owner()
	
	if focusedNode:
		var key = focusedNode.get_parent().name
		if InvManager.inv.has(key):
			var rows = itemList.get_children()
			for i in range(rows.size()):
				if rows[i].name == key:
					lastRow = i
					break
			itemDesc.text = InvManager.inv[key]["resource"].desc
			itemLabel.text = key
	
	#ini untuk test
	if Input.is_action_just_pressed("ui_accept"):
		InvManager.add_to_inv(load("res://item/tres/apple.tres"), 3)
		populate_list()
	if Input.is_action_just_pressed("ui_right"):
		InvManager.add_to_inv(load("res://item/tres/stone.tres"), 2)
		populate_list()
	if Input.is_action_just_pressed("ui_left"):
		InvManager.add_to_inv(load("res://item/tres/key.tres"), 1)
		populate_list()

func populate_list():
	for child in itemList.get_children():
		child.free()
	
	for key in items.keys():
		var data = InvManager.inv[key]
		var row = inv_row.instantiate()
		row.name = key
		row.find_child("name").text = data["resource"].name
		row.find_child("quant").text = str(data["quantity"])
		itemList.add_child(row)
	
	var rows = itemList.get_children()
	for i in range(rows.size()):
		var btn = rows[i].find_child("Button")
		if i > 0:
			btn.focus_neighbor_top = rows[i-1].find_child("Button").get_path()
		if i < rows.size() - 1:
			btn.focus_neighbor_bottom = rows[i+1].find_child("Button").get_path()
	
	if rows.is_empty():
		return
	
	rows[lastRow].find_child("Button").grab_focus()
	

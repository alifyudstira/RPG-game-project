extends Control

@export var item_btn:PackedScene

var itemDb = StoreItems.testStore

@onready var itemList:VBoxContainer = $itemList

func _ready() -> void:
	pass

func populate_list():
	for child in itemList.get_children():
		child.free()
	
	for item in itemDb.keys():
		var row = item_btn.instantiate()
		row.find_child("nama").text = item.name
		row.find_child("price").text = str(itemDb[item])
		itemList.add_child(row)

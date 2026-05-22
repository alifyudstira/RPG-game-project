extends Control

@export var item_btn:PackedScene

var itemDb = StoreItems.testStore

var itemList:VBoxContainer = $itemList

func _ready() -> void:
	

func populate_list():
	for child in itemList.get_children():
		child.free()
	
	for item in itemDb:
		

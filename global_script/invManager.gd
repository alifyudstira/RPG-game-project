class_name invManager
extends Node

var inv:Dictionary = {}

func _ready() -> void:
	add_to_inv(load("res://item/tres/apple.tres"), 3)

func _process(delta: float) -> void:
	pass

func add_to_inv(item:itemData, quantity:int):
	if inv.has(item.name):
		inv[item.name]["quantity"] += quantity
	else:
		inv[item.name] = {
			"resource" = item,
			"quantity" = quantity
		}

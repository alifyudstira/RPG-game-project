extends Control

@onready var panel = $"../CanvasLayer/Panel"
@onready var mainUi = $"../CanvasLayer/Panel/main"
@onready var sacrificeUi = $"../CanvasLayer/Panel/sacrifice"
@onready var accuracy = $"../CanvasLayer/Debug2/accuracy"
@onready var effectivity = $"../CanvasLayer/Debug2/effectivity"
@onready var dmgDealedUi = $"../CanvasLayer/dmgDealed"
@onready var messageUi = $"../CanvasLayer/messages"
@onready var itemList = $"../CanvasLayer/itemView/itemPanel/MarginContainer/itemList"
@onready var itemPanel = $"../CanvasLayer/itemView/itemPanel"
@onready var infoPanel = $"../CanvasLayer/itemView/infoPanel"
@onready var itemInfo = $"../CanvasLayer/itemView/infoPanel/MarginContainer/itemInfo"
@onready var itemView = $"../CanvasLayer/itemView"

var seePlayerInv = InvManager.inv
var uiState:String

func _ready() -> void:
	change_ui("main")

func _process(delta: float) -> void:
	accuracy.text = "Accuracy: " + str(GameManager.player_stats["accuracy"])
	effectivity.text = "Effectivity: " + str(GameManager.player_stats["effectivity"])
	
	if uiState == "item":
		info_update()

func change_ui(state:String):
	match state:
		"main":
			mainUi.visible = true
			sacrificeUi.visible = false
			itemView.visible = false
			
			mainUi.get_child(0).grab_focus()
		"sacrifice":
			mainUi.visible = false
			sacrificeUi.visible = true
			itemView.visible = false
			
			sacrificeUi.get_child(0).grab_focus()
		"item":
			mainUi.visible = false
			sacrificeUi.visible = false
			itemView.visible = true
			
			populate_item()
			itemList.get_child(0).grab_focus()
	
	uiState = state

func _on_sacrifice_pressed() -> void:
	change_ui("sacrifice")

func dmg_dealed_ui(dmg:int):
	dmgDealedUi.visible = true
	dmgDealedUi.text = "Dmg Dealed : " + str(dmg)
	await get_tree().create_timer(2).timeout
	dmgDealedUi.visible = false

func message_ui(message:String):
	pass

func populate_item():
	for item in seePlayerInv:
		var data = InvManager.inv[item]
		if data["resource"].itemType == "heal":
			var button = Button.new()
			button.name = item
			button.text = data["resource"].name
			itemList.add_child(button)

func info_update():
	var focusedNode = get_viewport().gui_get_focus_owner()
	
	if focusedNode:
		var info = InvManager.inv[focusedNode.name]["resource"].desc
		itemInfo.text = info

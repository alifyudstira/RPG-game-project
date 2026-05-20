extends Control

@onready var vMenu = $Panel/VMenu.get_children()

func _ready() -> void:
	vMenu[0].grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func menu_switch():
	var focusedMenu = get_viewport().gui_get_focus_owner()
	

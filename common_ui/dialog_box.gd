extends PanelContainer

@onready var name_label = $MarginContainer/VBoxContainer/name
@onready var text_label = $MarginContainer/VBoxContainer/dialog
 
## Panggil dari luar untuk menampilkan dialog
func display(character: String, text: String) -> void:
	print("[DialogBox] display() dipanggil -> character:", character, " text:", text)
	name_label.text = character
	text_label.text = text

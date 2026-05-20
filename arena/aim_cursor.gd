extends CharacterBody2D

var current_loc:Vector2
var newLocation:Vector2
@export var speed:int = 10

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	moveToward(newLocation)

func new_loc():
	var newLocationX = randi_range(100, 1048)
	var newLocationY = randi_range(80, 380)
	newLocation = Vector2(newLocationX, newLocationY)

func moveToward(newLocation):
	global_position = global_position.lerp(newLocation, speed)
	if global_position == newLocation:
		new_loc()

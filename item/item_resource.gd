sclass_name itemData
extends Resource

@export var texture:Texture2D = AtlasTexture.new()
@export var name:String = ""
@export var sellPrice:int
@export var buyPrice:int
@export var desc:String = ""
@export_enum("heal", "buff", "item", "weapon") var itemType:String

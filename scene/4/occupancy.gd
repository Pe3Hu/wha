extends "res://scene/3/token.gd"


#region vars
var current = null
var slash = null
#endregion



func _ready() -> void:
	var hbox = get_node("Numbers/HBox")
	#custom_minimum_size = Vector2(Global.vec.size.occupancy)
	limit.custom_minimum_size = Vector2()
	limit.size = Vector2()
	
	var input = {}
	input.type = "number"
	input.subtype = 0
	
	current = Global.scene.icon.instantiate()
	hbox.add_child(current)
	current.set_attributes(input)
	current.custom_minimum_size = Vector2()
	current.size = Vector2()
	
	input.type = "string"
	input.subtype = "/"
	
	slash = Global.scene.icon.instantiate()
	hbox.add_child(slash)
	slash.set_attributes(input)
	slash.custom_minimum_size = Vector2()
	slash.size = Vector2()
	
	hbox.move_child(limit, 2)

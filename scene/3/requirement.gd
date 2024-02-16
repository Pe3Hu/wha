extends "res://scene/3/token.gd"


var current = null


func _ready() -> void:
	add_current_icon()


func add_current_icon() -> void:
	var input = {}
	input.type = "number"
	input.subtype = 0

	current = Global.scene.icon.instantiate()
	add_child(current)
	current.set_attributes(input)
	current.set("size_flags_horizontal", SIZE_SHRINK_BEGIN)
	current.set("size_flags_vertical", SIZE_SHRINK_BEGIN)
	current.custom_minimum_size = Vector2(Global.vec.size.limit)


#region current treatment
func get_current() -> Variant:
	return current.get_number()


func change_current(value_: Variant) -> void:
	current.change_number(value_)


func set_current(value_: Variant) -> void:
	current.set_number(value_)
#endregion

extends "res://scene/3/requirement.gd"


var increment = null


func _ready() -> void:
	add_current_icon()
	add_increment_icon()
	limit.visible = false


func add_increment_icon() -> void:
	var input = {}
	input.type = "number"
	input.subtype = 1

	increment = Global.scene.icon.instantiate()
	add_child(increment)
	increment.set_attributes(input)
	increment.set("size_flags_horizontal", SIZE_SHRINK_BEGIN)
	increment.set("size_flags_vertical", SIZE_SHRINK_END)
	increment.custom_minimum_size = Vector2(Global.vec.size.limit)


#region increment treatment
func get_increment() -> Variant:
	return increment.get_number()


func change_increment(value_: Variant) -> void:
	increment.change_number(value_)


func set_increment(value_: Variant) -> void:
	increment.set_number(value_)
#endregion


#region current treatment
func get_current() -> Variant:
	return current.get_number()


func change_current(value_: Variant) -> void:
	current.change_number(value_)
	#
	#if value_ > 0:
		#var score = proprietor.get_score_based_on_subtype(subtype)
		#
		#if score != null:
			#var demand = score.get_token_based_on_subtype("demand")
			#var value = min(value_, demand.get_limit())
			#demand.change_limit(-value_)


func set_current(value_: Variant) -> void:
	current.set_number(value_)
#endregion


func apply_increment() -> void:
	var value = get_increment()
	
	if value > 0:
		change_current(value)

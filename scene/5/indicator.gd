extends MarginContainer


#region vars
@onready var bar = $ProgressBar

var core = null
var type = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	type = input_.type
	
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	bar.max_value = input_.max
	set_colors()
	custom_minimum_size = Vector2(Global.vec.size.bar)


func set_colors() -> void:
	var keys = ["fill", "background"]
	
	match type:
		"health":
			bar.value = bar.max_value
		"endurance":
			bar.value = 0
		"barrier":
			bar.value = bar.max_value
	
	for key in keys:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Global.color.indicator[type][key]
		var path = "theme_override_styles/" + key
		bar.set(path, style_box)


func update_value(value_: String, shift_: int) -> void:
	match value_:
		"current":
			bar.value += shift_
			
			if bar.value < bar.min_value:
				bar.value = bar.min_value
		"maximum":
			bar.max_value += shift_
	
	if type == "health" and bar.value == 0:
		core.knockout()


func get_percentage() -> int:
	return floor(bar.value * 100 / bar.max_value)


func reset() -> void:
	bar.value = bar.max_value
#endregion

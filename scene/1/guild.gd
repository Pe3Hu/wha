extends MarginContainer


#region vars
@onready var collectors = $Collectors

var cradle = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	cradle = input_.cradle
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_collectors()



func init_collectors() -> void:
	for _i in 1:
		var input = {}
		input.guild = self
	
		var collector = Global.scene.collector.instantiate()
		collectors.add_child(collector)
		collector.set_attributes(input)
#endregion

extends MarginContainer


#region vars
@onready var expositions = $Expositions

var wildlands = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	wildlands = input_.wildlands
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_expositions()



func init_expositions() -> void:
	for _i in 1:
		var input = {}
		input.museum = self
	
		var exposition = Global.scene.exposition.instantiate()
		expositions.add_child(exposition)
		exposition.set_attributes(input)
#endregion

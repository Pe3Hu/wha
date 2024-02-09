extends MarginContainer


#region vars
@onready var exhibits = $Exhibits

var exposition = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	exposition = input_.exposition
	
	init_basic_setting()


func init_basic_setting() -> void:
	add_exhibit()


func add_exhibit() -> void:
	var input = {}
	input.gallery = self
	
	var exhibit = Global.scene.exhibit.instantiate()
	exhibits.add_child(exhibit)
	exhibit.set_attributes(input)
#endregion

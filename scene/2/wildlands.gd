extends MarginContainer


#region vars
@onready var museums = $Museums

var sketch = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	
	init_museums()


func init_museums() -> void:
	for _i in 1:
		var input = {}
		input.wildlands = self
	
		var museum = Global.scene.museum.instantiate()
		museums.add_child(museum)
		museum.set_attributes(input)
#endregion

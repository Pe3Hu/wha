extends MarginContainer


#region vars
@onready var galleries = $HBox/Galleries

var museum = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	museum = input_.museum
	
	init_basic_setting()


func init_basic_setting() -> void:
	add_gallery()


func add_gallery() -> void:
	var input = {}
	input.exposition = self
	
	var gallery = Global.scene.gallery.instantiate()
	galleries.add_child(gallery)
	gallery.set_attributes(input)
#endregion

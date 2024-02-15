extends MarginContainer


#region vars
@onready var vbox = $VBox
@onready var acquisitions = $VBox/Acquisitions
@onready var utilizations = $VBox/Utilizations

var colletor = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	colletor = input_.colletor
	
	init_basic_setting()


func init_basic_setting() -> void:
	var separation = Global.vec.size.token.x - Global.vec.size.exhibit.x
	#vbox.set("theme_override_constants/separation", separation)
	acquisitions.set("theme_override_constants/separation", separation)
	#separation = Global.vec.size.utilization#Global.vec.size.token.y - Global.vec.size.exhibit.y
	utilizations.set("theme_override_constants/separation", separation)
	
	custom_minimum_size = Vector2(Global.vec.size.exhibit) + Vector2(0, Global.vec.size.utilization.y)


func add_exhibit_as_purpose(exhibit_: MarginContainer, purpose_: String) -> void:
	var box = get(purpose_+"s")
	exhibit_.gallery.exhibits.remove_child(exhibit_)
	box.add_child(exhibit_)
	exhibit_.set_purpose(purpose_)
	
	var n = max(acquisitions.get_child_count() + 2, utilizations.get_child_count())
	custom_minimum_size.x = n * Global.vec.size.token.x
#endregion


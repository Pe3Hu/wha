extends MarginContainer


#region vars
@onready var hBox = $HBox
@onready var acquisitions = $HBox/Acquisitions
@onready var utilizations = $HBox/Utilizations
@onready var fertilizations = $HBox/Fertilizations

var collector = null
var workshop = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	collector = input_.collector
	
	init_basic_setting()


func init_basic_setting() -> void:
	workshop = collector.workshop
	var separation = Global.vec.size.token.x - Global.vec.size.exhibit.x
	#HBox.set("theme_override_constants/separation", separation)
	acquisitions.set("theme_override_constants/separation", separation)
	#separation = Global.vec.size.utilization#Global.vec.size.token.y - Global.vec.size.exhibit.y
	#utilizations.set("theme_override_constants/separation", separation)
	custom_minimum_size = Vector2(Global.vec.size.exhibit) + Vector2(Global.vec.size.token.x, 0)


func add_exhibit_as_purpose(exhibit_: MarginContainer, purpose_: String) -> void:
	var box = get(purpose_+"s")
	exhibit_.gallery.exhibits.remove_child(exhibit_)
	
	match purpose_:
		"acquisition":
			box.add_child(exhibit_)
			exhibit_.set_purpose(purpose_)
		"utilization":
			while exhibit_.essenceSacrifices.get_child_count() > 0:
				var token = exhibit_.essenceSacrifices.get_child(0)
				exhibit_.essenceSacrifices.remove_child(token)
				box.add_child(token)
				exhibit_.queue_free()
		"fertilization":
			box.add_child(exhibit_)
	
	var n = 2 + acquisitions.get_child_count() + utilizations.columns#max(acquisitions.get_child_count() + 2, utilizations.get_child_count())
	custom_minimum_size.x = n * Global.vec.size.token.x
#endregion


func filling_of_exhibit_requirements() -> void:
	for exhibit in acquisitions.get_children():
		for requirement in exhibit.essenceRequirements.get_children():
			var storage = workshop.get_storage_based_on_element(requirement.subtype)
			
			if storage.get_current() > 0:
				var arrear = requirement.get_limit() - requirement.get_current()
			
				if arrear > 0:
					var repayment = min(storage.get_current(), arrear)
					storage.change_current(-repayment)
					requirement.change_current(repayment)
					exhibit.completion_check()

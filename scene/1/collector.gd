extends MarginContainer


#region vars
@onready var workshop = $VBox/Workshop
@onready var domain = $VBox/Domain

var guild = null
var exposition = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	guild = input_.guild
	
	init_basic_setting()


func init_basic_setting() -> void:
	var input = {}
	input.colletor = self
	workshop.set_attributes(input)
	domain.set_attributes(input)
#endregion


#region init
func score_gallery(gallery_: MarginContainer) -> void:
	for exhibit in gallery_.exhibits.get_children():
		score_exhibit(exhibit)


func score_exhibit(exhibit_: MarginContainer) -> void:
	var subtypes = ["input", "utilization", "output"]
	
	for subtype in subtypes:
		var token = exhibit_.score.get_token_based_on_subtype(subtype)
		token.set_limit(0)
		
		match subtype:
			"input":
				for essence in exhibit_.essenceRequirements.get_children():
					token.change_limit(-essence.get_limit())
					var storage = workshop.get_token_based_on_type_and_element("storage", essence.subtype)
					token.change_limit(storage.get_limit())
			"utilization":
				for essence in exhibit_.essenceSacrifices.get_children():
					var score = workshop.get_score_based_on_element(essence.subtype)
					var supply = score.get_token_based_on_subtype("supply")
					var value = (1 - supply.get_limit()) * essence.get_limit()
					token.change_limit(value)
					
					var demand = score.get_token_based_on_subtype("demand")
					value = demand.get_limit() * essence.get_limit()
					token.change_limit(value)
			"output":
				for essence in exhibit_.essenceProductions.get_children():
					var value = (Global.dict.relevance["production"] * Global.dict.relevance["essence"] - 0.0) * essence.get_limit()
					token.change_limit(value)
				
				for effect in exhibit_.effectProductions.get_children():
					var value = (Global.dict.relevance["production"] * Global.dict.relevance[effect.type] - 0.0) * effect.get_limit()
					token.change_limit(value)


func pick_gallery() -> void:
	var options = []
	options.append_array(exposition.galleries.get_children())
	var gallery = options.front()
	exposition.galleries.remove_child(gallery)
	
	while gallery.exhibits.get_child_count() > 0:
		var exhibit = gallery.exhibits.get_child(0)
		var purpose = null
		
		if gallery.exhibits.get_child_count() == 3:
			purpose = "acquisition"
		else:
			purpose = "utilization"
		
		domain.add_exhibit_as_purpose(exhibit, purpose)
	
	gallery.queue_free()
#endregion

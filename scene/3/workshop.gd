extends MarginContainer


#region vars
@onready var productions = $VBox/Productions
@onready var storages = $VBox/Storages
@onready var scores = $VBox/Scores

var colletor = null
var affinity = null
var repulsion = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	colletor = input_.colletor
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()
	roll_affinity()
	essence_all_production()
	update_scores()


func init_tokens() -> void:
	var keys = ["productions", "storages"]
	
	for key in keys:
		var hbox = get(key)
		
		for element in Global.arr.element:
			var input = {}
			input.proprietor = self
			input.type = "essence"
			input.subtype = element
			
			var token = Global.scene.token.instantiate()
			hbox.add_child(token)
			token.set_attributes(input)
			token.custom_minimum_size = Vector2(Global.vec.size.score * 2)
			
			#if key == "storages":
			#	token.set_limit(0)
	
	for element in Global.arr.element:
		var input = {}
		input.proprietor = self
		input.type = "workshop"
		input.subtype = element
		
		var score = Global.scene.score.instantiate()
		scores.add_child(score)
		score.set_attributes(input)


func roll_affinity() -> void:
	var options = []
	options.append_array(Global.arr.element)
	affinity = options.pick_random()
	options.erase(affinity)
	repulsion = options.pick_random()
	
	for token in productions.get_children():
		if token.subtype == affinity:
			token.change_limit(2)
		
		if token.subtype == repulsion:
			token.change_limit(-1)


func get_token_based_on_type_and_element(type_: String, element_: String) -> MarginContainer:
	var hbox = get(type_+"s")
	var index = Global.arr.element.find(element_)
	return hbox.get_child(index)


func get_score_based_on_element(element_: String) -> MarginContainer:
	var index = Global.arr.element.find(element_)
	return scores.get_child(index)


func essence_all_production() -> void:
	for production in productions.get_children():
		var value = production.get_limit()
		
		if value > 0:
			var storage = get_token_based_on_type_and_element("storage", production.subtype)
			storage.change_limit(value)


func update_scores() -> void:
	var supplies = []
	
	for element in Global.arr.element:
		var storage = get_token_based_on_type_and_element("storage", element)
		supplies.append(storage.get_limit())
	
	supplies.sort()
	
	for element in Global.arr.element:
		var score = get_score_based_on_element(element)
		var storage = get_token_based_on_type_and_element("storage", element)
		var value = float(storage.get_limit()) - supplies.front()
		value /= (supplies.back() - supplies.front())
		var token = score.get_token_based_on_subtype("supply")
		token.set_limit(value)
		
		token = score.get_token_based_on_subtype("demand")
		token.set_limit(0)
#endregion

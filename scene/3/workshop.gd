extends MarginContainer


#region vars
@onready var productions = $VBox/Productions
@onready var storages = $VBox/Storages

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


func init_tokens() -> void:
	var keys = ["productions", "storages"]
	
	for key in keys:
		var hbox = get(key)
		
		for element in Global.arr.element:
			var input = {}
			input.proprietor = self
			input.type = "element"
			input.subtype = element
			
			var token = Global.scene.token.instantiate()
			hbox.add_child(token)
			token.set_attributes(input)
			
			#if key == "storages":
			#	token.set_limit(0)


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


func get_token_based_on_type_and_subtype(type_: String, subtype_: String) -> Variant:
	var hbox = get(type_+"s")
	
	for token in hbox.get_children():
		if token.subtype == subtype_:
			return token
	
	return null


func essence_all_production() -> void:
	for production in productions.get_children():
		var value = production.get_limit()
		
		if value > 0:
			var storage = get_token_based_on_type_and_subtype("storage", production.subtype)
			storage.change_limit(value)
#endregion

extends MarginContainer


#region vars
@onready var occupancies = $Occupancies/Occupancies
@onready var productions = $Productions/Productions
@onready var sacrifices = $Sacrifices/Sacrifices
@onready var gifts = $Gifts/Gifts
@onready var effects = $Gifts/Effects
@onready var threats = $Gifts/Threats

var gallery = null
var rank = null
var type = null
var subtype = null
var elements = null
var effect = null
var count = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	for key in input_:
		set(key, input_[key])
	
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	custom_minimum_size = Vector2(Global.vec.size.exhibit)
	init_occupancies(input_)
	init_gifts(input_)
	init_sacrifices()
	init_productions()


func init_occupancies(input_: Dictionary) -> void:
	var types = ["field", "beast", "ritual", "enchantment"]
	
	if types.has(type):
		for _i in input_.inputs.size():
			var input = {}
			input.proprietor = self
			input.type = "element"
			input.subtype = elements[_i]
			input.limit = input_.inputs[_i]
			
			var occupancy = Global.scene.occupancy.instantiate()
			occupancies.add_child(occupancy)
			occupancy.set_attributes(input)


func init_gifts(input_: Dictionary) -> void:
	var types = ["beast", "ritual"]
	
	if types.has(type):
		var inverse_elements = Global.get_inverse_elements(elements)
		
		for _i in input_.outputs.size():
			var input = {}
			input.proprietor = self
			var token = null
			
			match type:
				"beast":
					input.type = "element"
					input.subtype = inverse_elements[_i]
					token = Global.scene.token.instantiate()
					gifts.add_child(token)
				"ritual":
					input.type = subtype
					input.subtype = effect
					token = Global.scene.effect.instantiate()
					effects.add_child(token)
					
			
			input.limit = input_.outputs[_i]
			token.set_attributes(input)
			
			if type == "ritual":
				token.set_bg_color(Global.color.role[subtype])
				
				if count != null:
					token.count.set_number(count)
				


func init_sacrifices() -> void:
	var input = {}
	input.proprietor = self
	input.type = "element"
	
	if !elements.is_empty():
		input.subtype = elements.pick_random()
	else:
		input.subtype = Global.arr.element.pick_random()
	
	var token = Global.scene.token.instantiate()
	sacrifices.add_child(token)
	token.set_attributes(input)
	
	match type:
		"treasure":
			token.set_limit(rank * 2)


func init_productions() -> void:
	var types = ["field", "enchantment"]
	
	if types.has(type):
		var input = {}
		input.proprietor = self
		var token = Global.scene.token.instantiate()
		
		match type:
			"field":
				input.type = "element"
				input.subtype = elements.front()
			"enchantment":
				input.type = subtype
				input.subtype = effect
				token = Global.scene.effect.instantiate()
		
		productions.add_child(token)
		token.set_attributes(input)
		
		if type == "enchantment":
			token.set_bg_color(Global.color.role[subtype])
			
			if count != null:
				token.count.set_number(count)
#endregion

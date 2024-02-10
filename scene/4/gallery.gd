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
	roll_exhibits()


func roll_exhibits() -> void:
	var types = {}
	#types["field"] = 9
	#types["beast"] = 5
	#types["treasure"] = 1
	#types["ritual"] = 1
	types["enchantment"] = 1
	
	for _i in 5:
		var input = {}
		input.type = Global.get_random_key(types)
		add_exhibit(input)


func add_exhibit(input_: Dictionary) -> void:
	input_.gallery = self
	input_.rank = 1
	input_.inputs = []
	input_.elements = []
	var options = []
	var description = null
	
	match input_.type:
		"field":
			options = Global.dict.field.rank[input_.rank]
			input_.inputs = Global.get_random_key(options)
		"beast":
			options = Global.dict.beast.rank[input_.rank].input
			input_.inputs = options.pick_random()
			options = Global.dict.beast.rank[input_.rank].output
			input_.outputs = options.pick_random()
		"ritual":
			input_.subtype = "offense"
			options = Global.dict.ritual.role[input_.subtype]
			input_.index = options.pick_random()
			description = Global.dict.ritual.index[input_.index]
			input_.inputs = [description.input.limit]
			input_.outputs = [description.output.limit]
			input_.effect = description.output.type
			
			if Global.arr.element.has(description.input.type):
				input_.elements.append(description.input.type)
			
			if description.output.has("count"):
				input_.count = description.output.count
		"enchantment":
			input_.subtype = "offense"
			options = Global.dict.enchantment.limit[input_.rank][input_.subtype]
			description = options.pick_random()
			input_.inputs.append_array(description.limits)
			#input_.power = int(description.power)
			options = Global.dict.enchantment.effect[input_.rank][input_.subtype]
			description = options.pick_random()
			input_.effect = description.effect
			input_.outputs = [description.limit]
			input_.count = int(description.count)
			input_.elements = Global.get_random_elements(input_.inputs.size())
			
			if input_.elements.has(description.element):
				input_.elements.erase(description.element)
			else:
				input_.elements.pop_front()
			
			input_.elements.push_front(description.element)
	
	if input_.elements.is_empty():
		input_.elements = Global.get_random_elements(input_.inputs.size())
	
	var exhibit = Global.scene.exhibit.instantiate()
	exhibits.add_child(exhibit)
	exhibit.set_attributes(input_)
#endregion

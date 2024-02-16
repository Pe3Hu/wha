extends MarginContainer


#region vars
@onready var bg = $BG
@onready var exhibits = $Exhibits

var exposition = null
var criterion = null
var specialization = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	exposition = input_.exposition
	
	init_basic_setting()


func init_basic_setting() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	bg.set("theme_override_styles/panel", style)
	add_pack()


func add_pack() -> void:
	var datas = {}
	
	for gallery in exposition.galleries.get_children():
		if gallery != self:
			if !datas.has(gallery.criterion):
				datas[gallery.criterion] = []
		
			datas[gallery.criterion].append(gallery.specialization)
	
	roll_specialization(datas)
	var input = {}
	input[criterion] = specialization
	var options = Global.dict.pack[criterion][input[criterion]]
	#print([criterion, input[criterion]])
	var n = 3
	
	while exhibits.get_child_count() < n:
		var description = Global.get_random_key(options)
		#print(description)
		for key in description:
			input[key] = description[key]
		
		add_exhibit(input)


func roll_specialization(datas_: Dictionary) -> void:
	if datas_.keys().is_empty():
		criterion = Global.dict.criterion.keys().pick_random()
		var options = Global.dict.criterion[criterion]
		specialization = Global.get_random_key(options)
		return
	
	#criterion = datas_.keys().front()
	#specialization = datas_[criterion].front()
	var flag = true
	
	while flag:
		criterion = Global.dict.criterion.keys().pick_random()
		var options = Global.dict.criterion[criterion]
		specialization = Global.get_random_key(options)
		flag = datas_.has(criterion)
		
		if flag:
			flag = datas_[criterion].has(specialization)


func add_exhibit(input_: Dictionary) -> void:
	input_.gallery = self
	input_.rank = 1
	input_.inputs = []
	
	if input_.element == "any":
		input_.element = Global.arr.element.pick_random()
	
	input_.elements = [input_.element]
	var options = []
	var description = null
	
	#if input_.type == "any":
	#	mat
	
	match input_.type:
		"field":
			options = Global.dict.field.rank[input_.rank]
			input_.inputs = Global.get_random_key(options)
			Global.add_field_elements_based_on_subtype(input_.elements, input_.inputs.size(), input_.subtype)
		"beast":
			options = Global.dict.beast.rank[input_.rank].input
			input_.inputs = options.pick_random()
			options = Global.dict.beast.rank[input_.rank].output
			input_.outputs = options.pick_random()
		"ritual":
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
			options = Global.dict.enchantment.limit[input_.rank][input_.subtype]
			description = options.pick_random()
			input_.inputs.append_array(description.limits)
			#input_.power = int(description.power)
			options = Global.dict.enchantment.effect[input_.rank][input_.subtype][input_.element]
			description = options.pick_random()
			input_.effect = description.effect
			input_.outputs = [description.limit]
			input_.count = int(description.count)
	
	if input_.elements.size() == 1:
		Global.add_random_elements(input_.elements, input_.inputs.size())
	
	var exhibit = Global.scene.exhibit.instantiate()
	exhibits.add_child(exhibit)
	exhibit.set_attributes(input_)
	duplicate_recycling()


func duplicate_recycling() -> void:
	if exhibits.get_child_count() == 1:
		return
	
	var child = exhibits.get_child(exhibits.get_child_count() - 1)
	var parents = []
	parents.append_array(exhibits.get_children())
	parents.erase(child)
	
	for parent in parents:
		if !child.duplicate_check(parent):
			exhibits.remove_child(child)
			child.queue_free()
			return


func pair_up() -> Array:
	var pairs = []
	var types = [["total", "utilization"], ["utilization", "total"]]
	var constituents = Global.get_all_constituents(exhibits.get_children())
	
	for constituent in constituents[2]:
		for _types in types:
			var pair = {}
			pair.score = 0
			
			for _i in 2:
				var type = _types[_i]
				var exhibit = constituent[_i]
				pair[type] = exhibit
				var token = exhibit.score.get_token_based_on_subtype(type)
				pair.score += token.get_limit()
			
			pairs.append(pair)
	
	pairs.sort_custom(func(a, b): return a.score > b.score)
	
	for _i in range(pairs.size()-1, -1, -1):
		var pair = pairs[_i]
		
		if pair.score != pairs.front().score:
			pairs.erase(pair)
	
	return pairs
#endregion

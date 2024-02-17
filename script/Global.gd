extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var num = {}
var vec = {}
var color = {}
var dict = {}
var flag = {}
var node = {}
var scene = {}


func _ready() -> void:
	init_arr()
	init_num()
	init_vec()
	init_color()
	init_dict()
	init_node()
	init_scene()


func init_arr() -> void:
	arr.element = ["aqua", "wind", "fire", "earth"]
	arr.essence = []
	arr.essence.append_array(arr.element)
	arr.field = ["ore", "seed", "gas"]
	arr.enchantment = ["defense", "offense"]
	arr.phase = ["growing", "preparing", "picking", "filling"]


func init_num() -> void:
	num.index = {}


func init_dict() -> void:
	init_neighbor()
	init_inverse()
	init_ritual()
	init_enchantment()
	init_beast()
	init_field()
	init_pack()
	init_level()
	init_exihibit()


func init_neighbor() -> void:
	dict.neighbor = {}
	dict.neighbor.linear3 = [
		Vector3( 0, 0, -1),
		Vector3( 1, 0,  0),
		Vector3( 0, 0,  1),
		Vector3(-1, 0,  0)
	]
	dict.neighbor.linear2 = [
		Vector2( 0,-1),
		Vector2( 1, 0),
		Vector2( 0, 1),
		Vector2(-1, 0)
	]
	dict.neighbor.diagonal = [
		Vector2( 1,-1),
		Vector2( 1, 1),
		Vector2(-1, 1),
		Vector2(-1,-1)
	]
	dict.neighbor.zero = [
		Vector2( 0, 0),
		Vector2( 1, 0),
		Vector2( 1, 1),
		Vector2( 0, 1)
	]
	dict.neighbor.hex = [
		[
			Vector2( 1,-1), 
			Vector2( 1, 0), 
			Vector2( 0, 1), 
			Vector2(-1, 0), 
			Vector2(-1,-1),
			Vector2( 0,-1)
		],
		[
			Vector2( 1, 0),
			Vector2( 1, 1),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2( 0,-1)
		]
	]


func init_inverse() -> void:
	dict.element = {}
	dict.element.inverse = {}
	var n = arr.element.size()
	var unuseds = []
	
	for element in arr.element:
		var index = (arr.element.find(element) + n / 2) % n
		dict.element.inverse[element] = arr.element[index]
	
	
	dict.relevance = {}
	dict.relevance["offense"] = 4
	dict.relevance["defense"] = 2
	dict.relevance["purpose"] = 1
	dict.relevance["essence"] = 1
	dict.relevance["production"] = 3
	dict.relevance["gift"] = 1


func init_ritual() -> void:
	dict.ritual = {}
	dict.ritual.index = {}
	dict.ritual.role = {}
	
	var path = "res://asset/json/wha_ritual.json"
	var array = load_data(path)
	
	for ritual in array:
		var data = {}
		
		for key in ritual:
			if typeof(ritual[key]) == TYPE_FLOAT:
				ritual[key] = int(ritual[key])
			
			if key != "index":
				var words = key.split(" ")
				
				if words.size() > 1:
					if !data.has(words[0]):
						data[words[0]] = {}
					
					data[words[0]][words[1]] = ritual[key]
				else:
					data[key] = ritual[key]
		
		if !dict.ritual.role.has(ritual.role):
			dict.ritual.role[ritual.role] = []
		
		dict.ritual.role[ritual.role].append(ritual.index)
		dict.ritual.index[ritual.index] = data


func init_enchantment() -> void:
	dict.enchantment = {}
	dict.enchantment.limit = {}
	dict.enchantment.effect = {}
	
	var exceptions = ["index", "role", "rank", "element"]
	var path = "res://asset/json/wha_enchantment_limit.json"
	var array = load_data(path)
	
	for enchantment in array:
		var data = {}
		
		for key in enchantment:
			if typeof(enchantment[key]) == TYPE_FLOAT:
				enchantment[key] = int(enchantment[key])
			
			if !exceptions.has(key):
				data[key] = enchantment[key]
				
				if key == "limits":
					data.limits = []
				
					match typeof(enchantment[key]):
						TYPE_FLOAT:
							data.limits.append(int(enchantment[key]))
						TYPE_INT:
							data.limits.append(enchantment[key])
						TYPE_STRING:
							for limit in enchantment[key].split(","):
								data.limits.append(int(limit))
		
		if !dict.enchantment.limit.has(enchantment.rank):
			dict.enchantment.limit[enchantment.rank] = {}
		
		if !dict.enchantment.limit[enchantment.rank].has(enchantment.role):
			dict.enchantment.limit[enchantment.rank][enchantment.role] = []
		
		dict.enchantment.limit[enchantment.rank][enchantment.role].append(data)
	
	path = "res://asset/json/wha_enchantment_effect.json"
	array = load_data(path)
	
	for enchantment in array:
		var data = {}
		
		for key in enchantment:
			if typeof(enchantment[key]) == TYPE_FLOAT:
				enchantment[key] = int(enchantment[key])
			
			if !exceptions.has(key):
				data[key] = enchantment[key]
		
		if !dict.enchantment.effect.has(enchantment.rank):
			dict.enchantment.effect[enchantment.rank] = {}
		
		if !dict.enchantment.effect[enchantment.rank].has(enchantment.role):
			dict.enchantment.effect[enchantment.rank][enchantment.role] = {}
		
		if !dict.enchantment.effect[enchantment.rank].has(enchantment.element):
			dict.enchantment.effect[enchantment.rank][enchantment.role][enchantment.element] = []
		
		dict.enchantment.effect[enchantment.rank][enchantment.role][enchantment.element].append(data)


func init_beast() -> void:
	dict.beast = {}
	dict.beast.rank = {}
	
	var path = "res://asset/json/wha_beast_limit.json"
	var array = load_data(path)
	
	for beast in array:
		var limits = []
		beast.rank = int(beast.rank)
		
		for limit in beast.limits.split(","):
			limits.append(int(limit))
		
		if !dict.beast.rank.has(beast.rank):
			dict.beast.rank[beast.rank] = {}
			
		if !dict.beast.rank[beast.rank].has(beast.type):
			dict.beast.rank[beast.rank][beast.type] = []
		
		dict.beast.rank[beast.rank][beast.type].append(limits)


func init_field() -> void:
	dict.field = {}
	dict.field.rank = {}
	
	var path = "res://asset/json/wha_field_limit.json"
	var array = load_data(path)
	
	for field in array:
		field.rank = int(field.rank)
		var limits = []
		
		for limit in field.limits.split(","):
			limits.append(int(limit))
		
		if !dict.field.rank.has(field.rank):
			dict.field.rank[field.rank] = {}
		
		dict.field.rank[field.rank][limits] = field.weight


func init_pack() -> void:
	dict.pack = {}
	dict.pack.type = {}
	dict.pack.element = {}
	
	for element in arr.element:
		dict.pack.element[element] = {}
	
	#for key in dict.pack:
	#	dict.pack[key]["any"] = {}
	
	var path = "res://asset/json/wha_pack.json"
	var array = load_data(path)
	
	for pack in array:
		for key in pack:
			if typeof(pack[key]) == TYPE_FLOAT:
				pack[key] = int(pack[key])
		
		
		if !dict.pack.type.has(pack.type):
			dict.pack.type[pack.type] = {}
		
		for element in arr.element:
			#if !dict.pack.element[element].has(pack.type):
				#dict.pack.element[element][pack.type] = {}
			var data = {}
			data.type = pack.type
			data.subtype = pack.subtype
			dict.pack.element[element][data] = pack[element]
			#dict.pack.element["any"][data] = pack[element]
			
			data = {}
			data.element = element
			data.subtype = pack.subtype
			dict.pack.type[pack.type][data] = pack[element]
			#dict.pack.type["any"][data] = pack[element]
	
	dict.criterion = {}
	dict.criterion.type = {}
	#dict.criterion.type["any"] = 5
	dict.criterion.type["field"] = 3
	dict.criterion.type["enchantment"] = 2
	
	dict.criterion.element = {}
	#dict.criterion.element["any"] = 4
	dict.criterion.element["aqua"] = 1
	dict.criterion.element["wind"] = 1
	dict.criterion.element["fire"] = 1
	dict.criterion.element["earth"] = 1


func init_level() -> void:
	dict.level = {}
	dict.level.rank = {}
	dict.level.income = {}
	
	var path = "res://asset/json/wha_level.json"
	var array = load_data(path)
	
	for level in array:
		dict.level.rank[int(level.index)] = {}
		
		for key in level:
			level[key] = int(level[key])
			var words = key.split(" ")
			
			if words.has("rank"):
				dict.level.rank[level.index][int(words[1])] = level[key]
		
		dict.level.income[level.index] = level.income


func init_exihibit() -> void:
	var ranks = [1, 2, 3]
	var types = ["field", "enchantment"]
	dict.exihibit = {}
	dict.exihibit.rank = {}
	
	for rank in ranks:
		dict.exihibit.rank[rank] = []
		
		for type in types:
			for subtype in arr[type]:
				match type:
					"field":
						for inputs in dict.field.rank[rank]:
							var constituents = get_all_elements_constituents_based_on_size(inputs.size())
							
							for elements in constituents:
								var data = {}
								data.inputs = inputs
								data.elements = elements
								data.type = type
								data.subtype = subtype
								#var weight = dict.field.rank[rank][inputs]
								#dict.exihibit.rank[rank][data] = weight
								dict.exihibit.rank[rank].append(data)
					"enchantment":
						var limits = []
						var options = Global.dict.enchantment.limit[rank][subtype]
						
						for option in options:
							limits.append(option.limits)
						
						
						for inputs in limits:
							var constituents = get_all_elements_constituents_based_on_size(inputs.size())
							
							for elements in constituents:
									var data = {}
									data.inputs = inputs
									data.elements = elements
									data.type = type
									data.subtype = subtype
									#var weight = dict.field.rank[rank][inputs]
									#dict.exihibit.rank[rank][data] = weight
									
									options = Global.dict.enchantment.effect[rank][subtype][elements.front()]
									
									for option in options:
										data.effect = option.effect
										data.outputs = [option.limit]
										data.count = int(option.count)
									
									dict.exihibit.rank[rank].append(data)


func init_node() -> void:
	node.game = get_node("/root/Game")


func init_scene() -> void:
	scene.icon = load("res://scene/0/icon.tscn")
	
	scene.guild = load("res://scene/1/guild.tscn")
	scene.collector = load("res://scene/1/collector.tscn")
	
	scene.museum = load("res://scene/2/museum.tscn")
	scene.exposition = load("res://scene/2/exposition.tscn")
	
	scene.token = load("res://scene/3/token.tscn")
	scene.requirement = load("res://scene/3/requirement.tscn")
	scene.storage = load("res://scene/3/storage.tscn")
	
	scene.gallery = load("res://scene/4/gallery.tscn")
	scene.exhibit = load("res://scene/4/exhibit.tscn")
	scene.effect = load("res://scene/4/effect.tscn")
	scene.score = load("res://scene/4/score.tscn")


func init_vec():
	vec.size = {}
	vec.size.letter = Vector2(20, 20)
	vec.size.icon = Vector2(32, 32)
	vec.size.number = Vector2(5, 32)
	vec.size.sixteen = Vector2(16, 16)
	
	vec.size.bar = Vector2(120, 12)
	vec.size.limit = Vector2(vec.size.sixteen)
	vec.size.token = Vector2(vec.size.limit * 3.5)
	vec.size.exhibit = Vector2(vec.size.token.x * 3, vec.size.token.y * 6)
	vec.size.utilization = Vector2(vec.size.token.x, vec.size.token.y * 2)
	vec.size.score = Vector2(vec.size.token * 0.75)
	
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	var h = 360.0
	var s = 0.3
	var v = 0.9
	
	color.element = {}
	color.element.fire = Color.from_hsv(0, s, v)
	color.element.earth = Color.from_hsv(30 / h, s, v)
	color.element.wind = Color.from_hsv(150 / h, s, v)
	color.element.aqua = Color.from_hsv(220 / h, s, v)
	#color.element.fire = {}
	#color.element.fire.fill = Color.from_hsv(0, s, v)
	#color.element.fire.background = Color.from_hsv(0, 0.5, 0.9)
	#color.element.wind = {}
	#color.element.wind.fill = Color.from_hsv(160 / h, s, v)
	#color.element.wind.background = Color.from_hsv(160 / h, 0.5, 0.9)
	#color.element.aqua = {}
	#color.element.aqua.fill = Color.from_hsv(210 / h, s, v)
	#color.element.aqua.background = Color.from_hsv(210 / h, 0.5, 0.9)
	#color.element.earth = {}
	#color.element.earth.fill = Color.from_hsv(30 / h, s, v)
	#color.element.earth.background = Color.from_hsv(30 / h, 0.5, 0.9)
	
	color.indicator = {}
	color.indicator.health = {}
	color.indicator.health.fill = Color.from_hsv(0, 1, 0.9)
	color.indicator.health.background = Color.from_hsv(0, 0.25, 0.9)
	
	s = 0.0
	v = 0.5
	color.role = {}
	color.role.offense = Color.from_hsv(0, s, v - 0.25)
	color.role.purpose = Color.from_hsv(270/ h, s, v)
	color.role.defense = Color.from_hsv(130/ h, s, v + 0.25)


func save(path_: String, data_: String):
	var path = path_ + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_)


func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var parse_err = json_object.parse(text)
	return json_object.get_data()


func get_random_key(dict_: Dictionary):
	if dict_.keys().size() == 0:
		print("!bug! empty array in get_random_key func")
		return null
	
	var total = 0
	
	for key in dict_.keys():
		total += dict_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in dict_.keys():
		var weight = float(dict_[key])
		index += weight/total
		
		if index > index_r:
			#if dict_.keys().size() == 3 and !arr.element.has(key):
			#	print([total, index_r, key])
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null


func get_random_elements(count_: int) -> Array:
	var result = []
	
	if count_ == Global.arr.element.size():
		result.append_array(Global.arr.element)
		result.shuffle()
		return result
	
	var options = []
	options.append_array(Global.arr.element)
	
	for _i in count_:
		var element = options.pick_random()
		options.erase(element)
		result.append(element)
	
	return result


func get_inverse_elements(elements_: Array) -> Array:
	var result = []
	result.append_array(elements_)
	result.reverse()
	
	for element in result:
		var inverse = dict.element.inverse[element]
		
		if !result.has(inverse):
			result.push_front(inverse)
	
	for element in arr.element:
		if !result.has(element):
			result.push_front(element)
	
	return result


func add_random_elements(elements_: Array, count_: int) -> void:
	if count_ > elements_.size():
		var options = []
		options.append_array(Global.arr.element)
		
		for element in elements_:
			options.erase(element)
		
		while count_ > elements_.size():
			var element = options.pick_random()
			options.erase(element)
			elements_.append(element)


func add_field_elements_based_on_subtype(elements_: Array, count_: int, subtype_: String) -> void:
	if count_ > elements_.size():
		var options = {}
		
		for element in arr.element:
			if !elements_.has(element):
				var data = {}
				data.element = element
				data.subtype = subtype_
				options[element] = dict.pack.type["field"][data]
		
		while count_ > elements_.size():
			var element = get_random_key(options)
			options.erase(element)
			elements_.append(element)


func get_all_elements_constituents_based_on_size(size_: int) -> Array:
	var constituents = get_all_constituents(arr.element)
	constituents = constituents[size_]
	
	for _i in constituents.size():
		for _j in size_ - 1:
			var constituent = []
			constituent.append_array(constituents[_i])
			
			for _l in _j + 1:
				var element = constituent.pop_front()
				constituent.append(element)
			
			constituents.append(constituent)
	return constituents


func get_all_substitutions(array_: Array) -> Array:
	var result = [[]]
	
	for _i in array_.size():
		var slot_options = array_[_i]
		var next = []
		
		for arr_ in result:
			for option in slot_options:
				var pair = []
				pair.append_array(arr_)
				pair.append(option)
				next.append(pair)
		
		result = next
		
		for _j in range(result.size()-1,-1,-1):
			if result[_j].size() < _i+1:
				result.erase(result[_j])
	
	return result


func get_all_permutations(array_: Array) -> Array:
	var result = []
	permutation(result, array_, 0)
	return result


func permutation(result_: Array, array_: Array, l_: int) -> void:
	if l_ >= array_.size():
		var array = []
		array.append_array(array_)
		result_.append(array)
		return
	
	permutation(result_, array_, l_+1)
	
	for _i in range(l_+1,array_.size(),1):
		swap(array_, l_, _i)
		permutation(result_, array_, l_+1)
		swap(array_, l_, _i)


func swap(array_: Array, i_: int, j_: int) -> void:
	var temp = array_[i_]
	array_[i_] = array_[j_]
	array_[j_] = temp


func get_all_constituents(array_: Array) -> Dictionary:
	var constituents = {}
	constituents[0] = []
	constituents[1] = []
	
	for child in array_:
		constituents[0].append(child)
		constituents[1].append([child])
	
	for _i in array_.size()-2:
		set_constituents_based_on_size(constituents, _i+2)
	
	constituents[array_.size()] = [constituents[0]]
	constituents.erase(0)
	return constituents


func set_constituents_based_on_size(constituents_: Dictionary, size_: int) -> void:
	var parents = constituents_[size_-1]
	var indexs = []
	constituents_[size_] = []
	
	for parent in parents:
		for child in constituents_[0]:
			if !parent.has(child):
				var constituent = []
				constituent.append_array(parent)
				constituent.append(child)
				constituent.sort_custom(func(a, b): return constituents_[0].find(a) < constituents_[0].find(b))
				
				if !constituents_[size_].has(constituent):
					constituents_[size_].append(constituent)

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


func init_num() -> void:
	num.index = {}


func init_dict() -> void:
	init_neighbor()
	init_ritual()
	init_enchantment()
	init_beast()
	init_field()


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


func init_ritual() -> void:
	dict.ritual = {}
	dict.ritual.index = {}
	
	var path = "res://asset/json/wha_ritual.json"
	var array = load_data(path)
	
	for ritual in array:
		var data = {}
		
		for key in ritual:
			if key != "index":
				var words = key.split(" ")
				
				if words.size() > 1:
					if !data.has(words[0]):
						data[words[0]] = {}
					
					data[words[0]][words[1]] = ritual[key]
				else:
					data[key] = ritual[key]
		
		dict.ritual.index[ritual.index] = data


func init_enchantment() -> void:
	dict.enchantment = {}
	dict.enchantment.index = {}
	dict.enchantment.index.limit = {}
	dict.enchantment.index.effect = {}
	
	var path = "res://asset/json/wha_enchantment_limit.json"
	var array = load_data(path)
	
	for enchantment in array:
		var data = {}
		
		for key in enchantment:
			if key != "index":
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
		
		dict.enchantment.index.limit[enchantment.index] = data
	
	path = "res://asset/json/wha_enchantment_effect.json"
	array = load_data(path)
	
	for enchantment in array:
		var data = {}
		
		for key in enchantment:
			if key != "index":
				data[key] = enchantment[key]
		
		dict.enchantment.index.effect[enchantment.index] = data


func init_beast() -> void:
	dict.beast = {}
	dict.beast.rank = {}
	
	var path = "res://asset/json/wha_beast_limit.json"
	var array = load_data(path)
	
	for beast in array:
		var limits = []
		
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
		var limits = []
		
		for limit in field.limits.split(","):
			limits.append(int(limit))
		
		if !dict.field.rank.has(field.rank):
			dict.field.rank[field.rank] = {}
		
		dict.field.rank[field.rank][limits] = field.weight


func init_node() -> void:
	node.game = get_node("/root/Game")


func init_scene() -> void:
	scene.icon = load("res://scene/0/icon.tscn")
	
	scene.guild = load("res://scene/1/guild.tscn")
	scene.collector = load("res://scene/1/collector.tscn")
	
	scene.museum = load("res://scene/2/museum.tscn")
	scene.exposition = load("res://scene/2/exposition.tscn")
	
	scene.token = load("res://scene/3/token.tscn")
	
	scene.gallery = load("res://scene/4/gallery.tscn")
	scene.exhibit = load("res://scene/4/exhibit.tscn")
	scene.occupancy = load("res://scene/4/occupancy.tscn")
	


func init_vec():
	vec.size = {}
	vec.size.letter = Vector2(20, 20)
	vec.size.icon = Vector2(32, 32)
	vec.size.number = Vector2(5, 32)
	vec.size.sixteen = Vector2(16, 16)
	
	vec.size.bar = Vector2(120, 12)
	vec.size.token = Vector2(40, 40)
	vec.size.occupancy = Vector2(vec.size.token)
	vec.size.exhibit = Vector2(vec.size.token.x * 3, vec.size.token.y * 8)
	
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	var h = 360.0
	
	color.element = {}
	color.element.fire = Color.from_hsv(0, 0.3, 0.9)
	color.element.earth = Color.from_hsv(30 / h, 0.3, 0.9)
	color.element.wind = Color.from_hsv(150 / h, 0.3, 0.9)
	color.element.aqua = Color.from_hsv(220 / h, 0.3, 0.9)
	#color.element.fire = {}
	#color.element.fire.fill = Color.from_hsv(0, 0.3, 0.9)
	#color.element.fire.background = Color.from_hsv(0, 0.5, 0.9)
	#color.element.wind = {}
	#color.element.wind.fill = Color.from_hsv(160 / h, 0.3, 0.9)
	#color.element.wind.background = Color.from_hsv(160 / h, 0.5, 0.9)
	#color.element.aqua = {}
	#color.element.aqua.fill = Color.from_hsv(210 / h, 0.3, 0.9)
	#color.element.aqua.background = Color.from_hsv(210 / h, 0.5, 0.9)
	#color.element.earth = {}
	#color.element.earth.fill = Color.from_hsv(30 / h, 0.3, 0.9)
	#color.element.earth.background = Color.from_hsv(30 / h, 0.5, 0.9)


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
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null

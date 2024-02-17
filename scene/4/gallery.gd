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
	init_exhibits()


func init_exhibits() -> void:
	var datas = {}
	
	for gallery in exposition.galleries.get_children():
		if gallery != self:
			if !datas.has(gallery.criterion):
				datas[gallery.criterion] = []
		
			datas[gallery.criterion].append(gallery.specialization)
	
	roll_specialization(datas)
	var input = {}
	var n = 3
	
	for _i in  n:
		add_exhibit()


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


func add_exhibit() -> void:
	var input = {}
	input[criterion] = specialization
	var level = exposition.collector.core.level.get_number()
	input.gallery = self
	Global.rng.randomize()
	input.rank = int(Global.get_random_key(Global.dict.level.rank[level]))
	var datas = []
	var a = Global.dict.exihibit.rank[input.rank]
	
	for data in Global.dict.exihibit.rank[input.rank]:
		var flag = true
		
		match criterion:
			"type":
				flag = data[criterion] == specialization
			"element":
				flag = data.elements.front() == specialization
		
		if flag:
			datas.append(data)
	
	var data = datas.pick_random()
	
	for key in data:
		input[key] = data[key]
	
	var exhibit = Global.scene.exhibit.instantiate()
	exhibits.add_child(exhibit)
	exhibit.set_attributes(input)


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

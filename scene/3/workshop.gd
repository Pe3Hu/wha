extends MarginContainer


#region vars
@onready var storages = $VBox/Storages
@onready var scores = $VBox/Scores

var collector = null
var domain = null
var affinity = null
var repulsion = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	collector = input_.collector
	
	init_basic_setting()


func init_basic_setting() -> void:
	domain = collector.domain
	init_storages()
	roll_affinity()


func init_storages() -> void:
	for element in Global.arr.element:
		var input = {}
		input.proprietor = self
		input.type = "essence"
		input.subtype = element
		
		var storage = Global.scene.storage.instantiate()
		storages.add_child(storage)
		storage.set_attributes(input)
		storage.custom_minimum_size = Vector2(Global.vec.size.score * 2)
		storage.change_current(1)
		
		input.type = "workshop"
		input.subtype = element
		
		var score = Global.scene.score.instantiate()
		scores.add_child(score)
		score.set_attributes(input)
		
		var token = score.get_token_based_on_subtype("demand")
		token.set_limit(0)


func roll_affinity() -> void:
	var options = []
	options.append_array(Global.arr.element)
	affinity = options.pick_random()
	options.erase(affinity)
	repulsion = options.pick_random()
	
	for storage in storages.get_children():
		if storage.subtype == affinity:
			storage.change_increment(2)
		
		if storage.subtype == repulsion:
			storage.change_increment(-1)


func get_storage_based_on_subtype(subtype_: String) -> Variant:
	for storage in storages.get_children():
		if storage.subtype == subtype_:
			return storage
	
	return null


func get_score_based_on_subtype(subtype_: String) -> Variant:
	for score in scores.get_children():
		if score.subtype == subtype_:
			return score
	
	return null
#endregion


#region score
func get_essence_from_increment() -> void:
	for storage in storages.get_children():
		storage.apply_increment()
	
	update_scores()


func update_scores() -> void:
	update_supplies()
	update_demands()


func update_supplies() -> void:
	var supplies = []
	
	for element in Global.arr.element:
		var storage = get_storage_based_on_subtype(element)
		supplies.append(storage.get_current())
	
	supplies.sort()
	
	for element in Global.arr.element:
		var score = get_score_based_on_subtype(element)
		var storage = get_storage_based_on_subtype(element)
		var value = float(storage.get_current()) - supplies.front()
		value /= (supplies.back() - supplies.front())
		var supply = score.get_token_based_on_subtype("supply")
		supply.set_limit(value)


func reset_demands() -> void:
	for score in scores.get_children():
		var demand = score.get_token_based_on_subtype("demand")
		var storage = get_storage_based_on_subtype(score.subtype)
		var value = -storage.get_current()
		demand.set_limit(value)
	
	for token in domain.utilizations.get_children():
		var _score = collector.workshop.get_score_based_on_subtype(token.subtype)
		var demand = _score.get_token_based_on_subtype("demand")
		var value = -token.get_limit()
		demand.change_limit(value)


func update_demands() -> void:
	reset_demands()
	
	for exhibit in domain.acquisitions.get_children():
		for requirement in exhibit.essenceRequirements.get_children():
			var arrear = requirement.get_limit() - requirement.get_current()
			
			if arrear > 0:
				var score = get_score_based_on_subtype(requirement.subtype)
				var demand = score.get_token_based_on_subtype("demand")
				demand.change_limit(arrear)
	
	for score in scores.get_children():
		var demand = score.get_token_based_on_subtype("demand")
		var value = max(0, demand.get_limit())
		demand.set_limit(value)


func get_essence_from_sacrifice() -> void:
	while domain.utilizations.get_child_count() > 0:
		var token = domain.utilizations.get_child(0)
		var storage = get_storage_based_on_subtype(token.subtype)
		var value = token.get_limit()
		storage.change_current(value)
		domain.utilizations.remove_child(token)
		token.queue_free()
#endregion

extends MarginContainer


#region vars
@onready var hBox = $HBox
@onready var acquisitions = $HBox/Acquisitions
@onready var utilizations = $HBox/Utilizations
@onready var fertilizations = $HBox/Fertilizations

var collector = null
var workshop = null
var capacity = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	collector = input_.collector
	
	init_basic_setting()


func init_basic_setting() -> void:
	workshop = collector.workshop
	capacity = 3
	var separation = Global.vec.size.token.x - Global.vec.size.exhibit.x
	#HBox.set("theme_override_constants/separation", separation)
	acquisitions.set("theme_override_constants/separation", separation)
	#separation = Global.vec.size.utilization#Global.vec.size.token.y - Global.vec.size.exhibit.y
	#utilizations.set("theme_override_constants/separation", separation)
	custom_minimum_size = Vector2(Global.vec.size.exhibit) + Vector2(Global.vec.size.token.x * 7, 0)


func add_exhibit_as_purpose(exhibit_: MarginContainer, purpose_: String) -> void:
	var box = get(purpose_+"s")
	exhibit_.gallery.exhibits.remove_child(exhibit_)
	exhibit_.collector = collector
	
	match purpose_:
		"acquisition":
			box.add_child(exhibit_)
			exhibit_.set_purpose(purpose_)
		"utilization":
			while exhibit_.essenceSacrifices.get_child_count() > 0:
				var token = exhibit_.essenceSacrifices.get_child(0)
				exhibit_.essenceSacrifices.remove_child(token)
				
				var parent = null
				
				for _parent in box.get_children():
					if _parent.subtype == token.subtype:
						parent = _parent
						break
				
				if parent == null:
					box.add_child(token)
				else:
					var value = token.get_limit()
					parent.change_limit(value)
				
				exhibit_.queue_free()
		"fertilization":
			box.add_child(exhibit_)
	
	#var n = 2 + acquisitions.get_child_count() + utilizations.columns#max(acquisitions.get_child_count() + 2, utilizations.get_child_count())
	#custom_minimum_size.x = n * Global.vec.size.token.x
#endregion


func organize_exhibits() -> void:
	var length = 1
	var datas = {}
	datas[length] = []
	var exhibits = []
	
	while acquisitions.get_child_count() > 0:
		var exhibit = acquisitions.get_child(0)
		acquisitions.remove_child(exhibit)
		exhibits.append(exhibit)
	
	var essences = workshop.get_current_essences()
	var continuations = []
	
	for exhibit in exhibits:
		var data = {}
		data.essences = exhibit.spend_essences_to_completion(essences)
		
		if data.essences != null:
			data.exhibits = [exhibit]
			exhibit.apply_gifts_to_essences_after_completion(data.essences)
			data.weight = 0
		
			match exhibit.type:
				"beast":
					data.weight = exhibit.rank * Global.dict.organize[exhibit.type]
				"field":
					data.weight += exhibit.rank * Global.dict.organize[exhibit.type]
				"enchantment":
					data.weight += exhibit.power * Global.dict.organize[exhibit.type]
			
			continuations.append(data)
	
	datas[length].append_array(continuations)
	
	while !continuations.is_empty():
		continuations = []
		
		for data in datas[length]:
			var _data = {}
			
			for exhibit in exhibits:
				if !data.exhibits.has(exhibit):
					_data.essences = exhibit.spend_essences_to_completion(essences)
					
					if _data.essences != null:
						_data.exhibits = [exhibit]
						_data.exhibits.append_array(data.exhibits)
						exhibit.apply_gifts_to_essences_after_completion(_data.essences)
						_data.weight = int(data.weight)
					
						match exhibit.type:
							"beast":
								_data.weight = exhibit.rank * Global.dict.organize[exhibit.type]
							"field":
								_data.weight += exhibit.rank * Global.dict.organize[exhibit.type]
							"enchantment":
								_data.weight += exhibit.power * Global.dict.organize[exhibit.type]
						
						continuations.append(_data)
		
		length += 1
		datas[length] = []
		datas[length].append_array(continuations)
	
	var options = []
	
	for _length in datas:
		for data in datas[_length]:
			options.append(data)
	
	if !options.is_empty():
		options.sort_custom(func(a, b): return a.weight > b.weight)
		var option = options.front()
		
		for exhibit in option.exhibits:
			acquisitions.add_child(exhibit)
			exhibits.erase(exhibit)
	
	exhibits.sort_custom(func(a, b): return a.get_estimate() < b.get_estimate())
	
	while !exhibits.is_empty():
		var exhibit = exhibits.pop_front()
		acquisitions.add_child(exhibit)


func organize_exhibits_old() -> void:
	var datas = []
	
	while acquisitions.get_child_count() > 0:
		var data = {}
		data.exhibit = acquisitions.get_child(0)
		data.availability = 0
		data.urgency = 0
		data.gift = 0
		data.weight = 0
		acquisitions.remove_child(data.exhibit)
		
		for requirement in data.exhibit.essenceRequirements.get_children():
			var storage = workshop.get_storage_based_on_subtype(requirement.subtype)
			var presence = storage.get_limit() - requirement.get_limit()
			
			if presence < 0:
				var multiplier = 1
				
				if requirement.subtype == workshop.repulsion:
					multiplier = 0.5
				if requirement.subtype == workshop.affinity:
					multiplier = 1.5
				
				data.availability += presence * multiplier
		
		match data.exhibit.type:
			"field":
				for production in data.exhibit.essenceProductions.get_children():
					var value = production.get_limit() * Global.dict.organize[data.exhibit.type]
					var score = collector.workshop.get_score_based_on_subtype(production.subtype)
					var demand = score.get_token_based_on_subtype("demand")
					
					if demand.get_limit() > 0:
						var supply = score.get_token_based_on_subtype("supply")
						value += demand.get_limit() / (supply.get_limit() + 1)
					
					data.urgency += value
			"enchantment":
				var value = data.exhibit.power * Global.dict.organize[data.exhibit.type]
				var mirror = Global.dict.mirror[data.exhibit.subtype]
				data.urgency += collector.opponent.forge.powers[mirror] + value
			"beast":
				for gift in data.exhibit.essenceGifts.get_children():
					var value = gift.get_limit() * Global.dict.organize[data.exhibit.type]
					var score = collector.workshop.get_score_based_on_subtype(gift.subtype)
					var demand = score.get_token_based_on_subtype("demand")
					
					if demand.get_limit() > 0:
						var supply = score.get_token_based_on_subtype("supply")
						value += demand.get_limit() / (supply.get_limit() + 1)
					
					data.urgency += value
					var multiplier = 1
				
					if gift.subtype == workshop.repulsion:
						multiplier = 1.5
					if gift.subtype == workshop.affinity:
						multiplier = 0.5
					
					data.gift += gift.get_limit() * multiplier
		
		if data.availability == 0:
			data.weight = int(data.urgency)
		
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.weight > b.weight)
	
	var weight = int(datas.front().weight)
	
	if weight != 0:
		while !datas.is_empty() and datas.front().weight == weight:
			var data = datas.pop_front()
			acquisitions.add_child(data.exhibit)
	
	datas.sort_custom(func(a, b): return a.availability > b.availability)
	
	while !datas.is_empty():
		var data = datas.pop_front()
		acquisitions.add_child(data.exhibit)


func filling_of_exhibit_requirements() -> void:
	for exhibit in acquisitions.get_children():
		for requirement in exhibit.essenceRequirements.get_children():
			var storage = workshop.get_storage_based_on_subtype(requirement.subtype)
			
			if storage.get_current() > 0:
				var arrear = requirement.get_limit() - requirement.get_current()
			
				if arrear > 0:
					var repayment = min(storage.get_current(), arrear)
					storage.change_current(-repayment)
					requirement.change_current(repayment)
					
					if exhibit.completion_check():
						var type = str(exhibit.type)
						exhibit.closure()
						
						#if type == "beast":
							#organize_exhibits()
							#filling_of_exhibit_requirements()
							#return
					#var score = collector.workshop.get_score_based_on_subtype(requirement.subtype)
					#var token = score.get_token_based_on_subtype("demand")
					#token.change_limit(-repayment)
	
	while acquisitions.get_child_count() > capacity:
		var exhibit = acquisitions.get_child(acquisitions.get_child_count() - 1)
		acquisitions.remove_child(exhibit)
		exhibit.refund()

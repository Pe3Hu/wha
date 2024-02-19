extends MarginContainer


#region vars
@onready var hBox = $HBox
@onready var acquisitions = $HBox/Acquisitions
@onready var utilizations = $HBox/Utilizations
@onready var fertilizations = $HBox/Fertilizations

var collector = null
var workshop = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	collector = input_.collector
	
	init_basic_setting()


func init_basic_setting() -> void:
	workshop = collector.workshop
	var separation = Global.vec.size.token.x - Global.vec.size.exhibit.x
	#HBox.set("theme_override_constants/separation", separation)
	acquisitions.set("theme_override_constants/separation", separation)
	#separation = Global.vec.size.utilization#Global.vec.size.token.y - Global.vec.size.exhibit.y
	#utilizations.set("theme_override_constants/separation", separation)
	custom_minimum_size = Vector2(Global.vec.size.exhibit) + Vector2(Global.vec.size.token.x, 0)


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
				box.add_child(token)
				exhibit_.queue_free()
		"fertilization":
			box.add_child(exhibit_)
	
	var n = 2 + acquisitions.get_child_count() + utilizations.columns#max(acquisitions.get_child_count() + 2, utilizations.get_child_count())
	custom_minimum_size.x = n * Global.vec.size.token.x
#endregion


func organize_exhibits() -> void:
	var datas = []
	
	while acquisitions.get_child_count() > 0:
		var data = {}
		data.exhibit = acquisitions.get_child(0)
		data.availability = 0
		data.urgency = 0
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
						
						if type == "beast":
							organize_exhibits()
							filling_of_exhibit_requirements()
							return
					#var score = collector.workshop.get_score_based_on_subtype(requirement.subtype)
					#var token = score.get_token_based_on_subtype("demand")
					#token.change_limit(-repayment)

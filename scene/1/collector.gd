extends MarginContainer


#region vars
@onready var workshop = $VBox/Workshop
@onready var domain = $VBox/HBox/Domain
@onready var core = $VBox/Core
@onready var forge = $VBox/HBox/Forge

var guild = null
var exposition = null
var opponent = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	guild = input_.guild
	
	init_basic_setting()


func init_basic_setting() -> void:
	var input = {}
	input.collector = self
	workshop.set_attributes(input)
	domain.set_attributes(input)
	core.set_attributes(input)
	forge.set_attributes(input)
#endregion


#region score
func prepare_galleries() -> void:
	exposition.rolls_galleries()
	
	for gallery in exposition.galleries.get_children():
		score_gallery(gallery)


func pick_gallery() -> void:
	var preferences = []
	
	for gallery in exposition.galleries.get_children():
		var preference = {}
		preference.pairs = gallery.pair_up()
		preference.score = preference.pairs.front().score
		preference.gallery = gallery
		preferences.append(preference)
	
	preferences.sort_custom(func(a, b): return a.score > b.score)
	
	for _i in range(preferences.size()-1, -1, -1):
		var preference = preferences[_i]
		
		if preference.score != preferences.front().score:
			preferences.erase(preference)
	
	var _preference = preferences.pick_random()
	var pair = _preference.pairs.pick_random()
	var purposes = {}
	purposes["utilization"] = "utilization"
	purposes["total"] = "acquisition"
	
	for type in purposes:
		var exhibit = pair[type]
		var purpose = purposes[type]
		domain.add_exhibit_as_purpose(exhibit, purpose)


func score_gallery(gallery_: MarginContainer) -> void:
	for exhibit in gallery_.exhibits.get_children():
		score_exhibit(exhibit)


func score_exhibit(exhibit_: MarginContainer) -> void:
	var subtypes = ["input", "utilization", "output", "total"]
	
	for subtype in subtypes:
		var token = exhibit_.score.get_token_based_on_subtype(subtype)
		token.set_limit(0)
		
		match subtype:
			"input":
				for requirement in exhibit_.essenceRequirements.get_children():
					var storage = workshop.get_storage_based_on_subtype(requirement.subtype)
					var value = min(storage.get_current() -requirement.get_limit(), 0)
					token.change_limit(value)
			"utilization":
				for sacrifice in exhibit_.essenceSacrifices.get_children():
					var score = workshop.get_score_based_on_subtype(sacrifice.subtype)
					var supply = score.get_token_based_on_subtype("supply")
					var value = (1 - supply.get_limit()) * sacrifice.get_limit()
					token.change_limit(value)
					
					var demand = score.get_token_based_on_subtype("demand")
					value = demand.get_limit() * sacrifice.get_limit()
					token.change_limit(value)
			"output":
				match exhibit_.type:
					"field":
						for production in exhibit_.essenceProductions.get_children():
							var value = Global.dict.relevance["essence"] * Global.dict.relevance["production"]
						
							value *= production.get_limit() 
							token.change_limit(value)
							var multiplier = 1
							
							if production.subtype == workshop.repulsion:
								multiplier = 1.25
							if production.subtype == workshop.affinity:
								multiplier = 0.75
							
							token.multiply_limit(multiplier)
					"enchantment":
						var value = float(forge.priorities[exhibit_.subtype]) / exhibit_.power
						
						if value > 0:
							if exhibit_.effectProductions.get_child_count() > 0:
								value *= Global.dict.relevance["production"]
							
							token.change_limit(value)
					#for effect in exhibit_.effectProductions.get_children():
						#var value = (Global.dict.relevance["production"] * Global.dict.relevance[effect.type] - 0.0) * effect.get_limit()
						#
						#if hazards.is_empty() and effect.type == "defense":
							#value = 0
						#
						#token.change_limit(value)
					"beast":
						for gift in exhibit_.essenceGifts.get_children():
							var value = Global.dict.relevance["essence"] * Global.dict.relevance["gift"]
							value *= gift.get_limit() 
							token.change_limit(value)
							var multiplier = 1
							
							if gift.subtype == workshop.repulsion:
								multiplier = 1.25
							if gift.subtype == workshop.affinity:
								multiplier = 0.75
							
							token.multiply_limit(multiplier)
			"total":
				for requirement in exhibit_.essenceRequirements.get_children():
					var value = 1
					var score = workshop.get_score_based_on_subtype(requirement.subtype)
					var demand = score.get_token_based_on_subtype("demand")
					
					if demand.get_limit() > 0:
						value -= demand.get_limit()
					
					value *= requirement.get_limit()
					token.change_limit(value)
				
				var minus = exhibit_.score.get_token_based_on_subtype("input").get_limit()
				token.change_limit(minus)
				var multiplier = exhibit_.score.get_token_based_on_subtype("output").get_limit()
				
				if multiplier != 0:
					multiplier = 1.0 / multiplier
					token.multiply_limit(multiplier)
				else:
					token.change_limit(-99)
				
				for production in exhibit_.essenceProductions.get_children():
					var score = workshop.get_score_based_on_subtype(production.subtype)
					var demand = score.get_token_based_on_subtype("demand")
					
					if demand.get_limit() > 0:
						var value = Global.dict.relevance["essence"] * Global.dict.relevance["production"]
						value *= demand.get_limit() * (production.get_limit() - workshop.pits[production.subtype])
						token.change_limit(value)
				
				for gift in exhibit_.essenceGifts.get_children():
					var score = workshop.get_score_based_on_subtype(gift.subtype)
					var demand = score.get_token_based_on_subtype("demand")
					
					if demand.get_limit() > 0:
						var value = Global.dict.relevance["essence"] * Global.dict.relevance["gift"]
						value *= demand.get_limit() * gift.get_limit()
						token.change_limit(value)
#endregion

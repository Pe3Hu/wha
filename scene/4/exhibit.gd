extends MarginContainer


#region vars
@onready var bg = $BG
@onready var essenceRequirements = $Requirements/Essences
@onready var essenceProductions = $Productions/VBox/Essences
@onready var effectProductions = $Productions/VBox/Effects
@onready var essenceSacrifices = $Sacrifices/VBox/Essences
@onready var threatSacrifices = $Sacrifices/VBox/Threats
@onready var essenceGifts = $Gifts/VBox/Essences
@onready var effectGifts = $Gifts/VBox/Effects
@onready var score = $Score
@onready var criterionTag = $Tags/Icons/Criterion
@onready var rankTag = $Tags/Icons/Rank
@onready var subtypeTag = $Tags/Icons/Subtype

var gallery = null
var collector = null
var rank = null
var type = null
var subtype = null
var elements = null
var effect = null
var count = null
var limit = null
var power = null
var purpose = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	for key in input_:
		set(key, input_[key])
	
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	custom_minimum_size = Vector2(Global.vec.size.exhibit)
	
	init_bg_color()
	init_requirements(input_)
	init_gifts(input_)
	init_sacrifices()
	init_productions()
	init_score()
	init_tags()


func init_score() -> void:
	var input = {}
	input.proprietor = self
	input.type = "exhibit"
	input.subtype = null
	score.set_attributes(input)


func init_bg_color() -> void:
	var style = StyleBoxFlat.new()
	Global.rng.randomize()
	var s = Global.rng.randf_range(0.5, 0.9)
	var v = Global.rng.randf_range(0.4, 0.9)
	style.bg_color = Color.from_hsv(gallery.hue, s, v)
	bg.set("theme_override_styles/panel", style)


func init_requirements(input_: Dictionary) -> void:
	var types = ["field", "beast", "ritual", "enchantment"]
	
	if types.has(type):
		for _i in input_.inputs.size():
			var input = {}
			input.proprietor = self
			input.type = "essence"
			input.subtype = elements[_i]
			input.limit = input_.inputs[_i]
			
			var token = Global.scene.requirement.instantiate()
			essenceRequirements.add_child(token)
			token.set_attributes(input)


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
					input.type = "essence"
					input.subtype = inverse_elements[_i]
					token = Global.scene.token.instantiate()
					essenceGifts.add_child(token)
				"ritual":
					input.type = subtype
					input.subtype = effect
					token = Global.scene.effect.instantiate()
					effectGifts.add_child(token)
					
			
			input.limit = input_.outputs[_i]
			token.set_attributes(input)
			
			if type == "ritual":
				token.set_bg_color(Global.color.role[subtype])
				
				if count != null:
					token.count.set_number(count)


func init_sacrifices() -> void:
	var input = {}
	input.proprietor = self
	input.type = "essence"
	
	if !elements.is_empty():
		input.subtype = elements.pick_random()
	else:
		input.subtype = Global.arr.element.pick_random()
	
	var token = Global.scene.token.instantiate()
	essenceSacrifices.add_child(token)
	token.set_attributes(input)
	token.set_limit(rank)
	
	match type:
		"treasure":
			token.set_limit(rank * 2)
		"curse":
			token.set_limit(rank * 2 + 1)
			
			input.type = "threat"
			input.subtype = "curse"
			
			token = Global.scene.token.instantiate()
			threatSacrifices.add_child(token)
			token.set_attributes(input)


func init_productions() -> void:
	var types = ["field", "enchantment"]
	
	if types.has(type):
		var input = {}
		input.proprietor = self
		var token = Global.scene.token.instantiate()
		
		match type:
			"field":
				input.type = "essence"
				input.subtype = elements.front()
				essenceProductions.add_child(token)
			"enchantment":
				input.type = subtype
				input.subtype = effect
				token = Global.scene.effect.instantiate()
				effectProductions.add_child(token)
		
		token.set_attributes(input)
	
		match type:
			"field":
				token.set_limit(rank)
			"enchantment":
				token.set_bg_color(Global.color.role[subtype])
				token.set_limit(limit)
				
				if count != null:
					token.count.set_number(count)


func init_tags() -> void:
	var input = {}
	input.type = "tag"
	input.subtype = gallery.specialization
	criterionTag.set_attributes(input)
	criterionTag.custom_minimum_size = Vector2(Global.vec.size.token * 0.5) 
	
	input.subtype = rank
	rankTag.set_attributes(input)
	rankTag.custom_minimum_size = Vector2(Global.vec.size.token * 0.5) 
	
	input.subtype = subtype
	subtypeTag.set_attributes(input)
	subtypeTag.custom_minimum_size = Vector2(Global.vec.size.token * 0.5) 
#endregion


func set_purpose(purpose_: String) -> void:
	purpose = purpose_
	
	match purpose:
			"acquisition":
				var node = get_node("Sacrifices")
				node.visible = false
				
				#for requirement in essenceRequirements.get_children():
					#var _score = collector.workshop.get_score_based_on_subtype(requirement.subtype)
					#var token = _score.get_token_based_on_subtype("demand")
					#var value = requirement.get_limit()
					#token.change_limit(value)
				
				if type == "enchantment":
					collector.forge.powers[subtype] += power
					collector.forge.update_priorities()
					collector.opponent.forge.update_priorities()
			#"utilization":
				#for sacrifice in essenceSacrifices.get_children():
					#var _score = collector.workshop.get_score_based_on_subtype(sacrifice.subtype)
					#var token = _score.get_token_based_on_subtype("demand")
					#var value = sacrifice.get_limit()
					#token.change_limit(value)


func completion_check() -> bool:
	for requirement in essenceRequirements.get_children():
		var arrear = requirement.get_limit() - requirement.get_current()
	
		if arrear != 0:
			return false
	
	return true


func closure() -> void:
	for token in essenceProductions.get_children():
		var storage = collector.workshop.get_storage_based_on_subtype(token.subtype)
		var value = token.get_limit()
		storage.change_increment(value)
	
	for token in effectGifts.get_children():
		var storage = collector.workshop.get_storage_based_on_subtype(token.subtype)
		var value = token.get_limit()
		storage.change_current(value)
	
	collector.core.level_up()
	
	while effectProductions.get_child_count() > 0:
		var token = effectProductions.get_child(0)
		effectProductions.remove_child(token)
		collector.forge.add_effect(token)
	
	if type == "beast":
		collector
	
	collector.domain.acquisitions.remove_child(self)
	queue_free()

extends MarginContainer


#region vars
@onready var permanentOffenses = $HBox/Permanents/Offenses
@onready var permanentDefenses = $HBox/Permanents/Defenses
@onready var singleOffenses = $HBox/Singles/Offenses
@onready var singleDefenses = $HBox/Singles/Defenses
#@onready var threats = $HBox/permanents/Threats

var collector = null
var workshop = null
var powers = {}
var priorities = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	collector = input_.collector
	
	init_basic_setting()


func init_basic_setting() -> void:
	workshop = collector.workshop
	
	for subtype in Global.arr.enchantment:
		powers[subtype] = 0
	
	#update_priorities()


func update_priorities() -> void:
	var level = collector.core.level.get_number()
	
	for subtype in powers:
		var base = Global.dict.level.power[level][subtype]
		base -= powers[subtype]
		priorities[subtype] = max(0, base)
	
	if collector.opponent != null:
		var opponent_offense = collector.opponent.forge.powers["offense"]
		
		if opponent_offense == 0:
			priorities["defense"] = 0
#endregion


func add_effect(kind_: String, token_: MarginContainer) -> void:
	var box = get(kind_ + token_.type.capitalize() + "s")
	var parent = null
	
	for _parent in box.get_children():
		if _parent.identical_check(token_):
			parent = _parent
			break
	
	if parent != null:
		var value = token_.get_count()
		parent.change_count(value)
	else:
		var input = {}
		input.proprietor = self
		input.type = token_.type
		input.subtype = token_.subtype
		input.limit = token_.get_limit()
		input.count = token_.get_count()
		
		var token = Global.scene.effect.instantiate()
		box.add_child(token)
		token.set_attributes(input)
		
		token.set_bg_color(Global.color.role[kind_][input.type])
		token.set_limit(input.limit)
		
		if input.count != null:
			token.count.set_number(input.count)


func fabricate_single_effects() -> void:
	for type in Global.arr.enchantment:
		var box = get("permanent" + type.capitalize() + "s")
		
		for token in box.get_children():
			match type:
				"offense":
					collector.opponent.forge.add_effect("single", token)
				"defense":
					add_effect("single", token)


func single_effects_reaction() -> void:
	while singleOffenses.get_child_count() > 0:
		var token = singleOffenses.get_child(0)
		singleOffenses.remove_child(token)
		apply_offense_token(token) 


func apply_offense_token(token_: MarginContainer) -> void:
	for _i in token_.get_count():
		var damage = token_.get_limit()
		collector.core.get_damage(damage)
	
	token_.queue_free()

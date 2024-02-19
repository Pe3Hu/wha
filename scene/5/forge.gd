extends MarginContainer


#region vars
@onready var offenses = $HBox/Enchantments/Offenses
@onready var defenses = $HBox/Enchantments/Defenses
@onready var threats = $HBox/Enchantments/Threats

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


func add_effect(token_: MarginContainer) -> void:
	var vbox = get(token_.type+"s")
	vbox.add_child(token_)

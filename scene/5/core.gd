extends MarginContainer


#region vars
@onready var level = $VBox/HBox/Level
@onready var health = $VBox/HBox/Health

var collector = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	collector = input_.collector
	
	init_basic_setting()


func init_basic_setting() -> void:
	var input = {}
	input.core = self
	input.type = "health"
	input.max = 100
	health.set_attributes(input)
	
	input.type = "number"
	input.subtype = 0
	level.set_attributes(input)


func knockout() -> void:
	#var shrine = collector.sanctuary.shrines.get_child(0)
	#var side = shrine.sides[collector]
	#var winner = shrine.get_collector_based_on_side(Global.dict.side.opposite[side])
	#collector.sanctuary.winner = winner
	#collector.sanctuary.end = true
	pass


func level_up() -> void:
	var sum = 0
	
	for storage in collector.workshop.storages.get_children():
		sum += storage.get_increment()
	
	var next_level = level.get_number() + 1
	
	if Global.dict.level.income[next_level] <= sum:
		level.set_number(next_level)
		#level_up()
#endregion

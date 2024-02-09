extends MarginContainer


#region vars
@onready var occupancies = $Occupancies/Occupancies
@onready var productions = $Productions/Productions
@onready var sacrifices = $Sacrifices/Sacrifices
@onready var gifts = $Gifts/Gifts
@onready var threats = $Gifts/Threats


var gallery = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	gallery = input_.gallery
	
	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Vector2(Global.vec.size.exhibit)
	init_occupancies()


func init_occupancies() -> void:
	var plurals = {}
	plurals["occupancy"] = "occupancies"
	plurals["production"] = "productions"
	plurals["sacrifice"] = "sacrifices"
	plurals["gift"] = "gifts"
	
	for key in plurals:
		var hbox = get(plurals[key])
		
		for _i in 3:
			var input = {}
			input.proprietor = self
			input.type = "element"
			input.subtype = Global.arr.element.pick_random()
			
			var scene = Global.scene.token.instantiate()
			
			match key:
				"occupancy":
					input.limit = 3
					scene = Global.scene.occupancy.instantiate()
			
			hbox.add_child(scene)
			scene.set_attributes(input)

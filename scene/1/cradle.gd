extends MarginContainer


#region vars
@onready var guilds = $Guilds

var sketch = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	
	init_guilds()


func init_guilds() -> void:
	for _i in 1:
		var input = {}
		input.cradle = self
	
		var guild = Global.scene.guild.instantiate()
		guilds.add_child(guild)
		guild.set_attributes(input)
#endregion

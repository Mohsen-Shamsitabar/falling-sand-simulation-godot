extends ColorRect


@export var value: int = 0

func _ready():
	pass


func _process(_delta):
	if(value):
		color = Color8(value,value,value,255)
	else:
		# color = Color8(135,230,115,255)
		color = Color8(0,0,0,255)

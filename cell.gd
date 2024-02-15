extends ColorRect


@export var value: float = -1

func _ready():
	pass


func _process(_delta):
	if(value >= 0):
		color = Color.from_hsv(value / 359.0, 0.75, 1.0)
	else:
		color = Color8(0,0,0,255)

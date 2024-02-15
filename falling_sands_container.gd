extends Container

const cell_scene: PackedScene = preload("res://cell.tscn")
var rng = RandomNumberGenerator.new()

@onready var container = get_node(".")

@export var container_width = 2000
@export var container_height = 2000
@export var cell_width = 25
var cell_size = Vector2(cell_width,cell_width)
# @export var pen_size = Vector2(3,3)

var color_code: int = 50
var reverse: bool = false
var cells: Array = []
var values: Array = []

# =============================================== #


func make_matrix(row: int, col: int):
	var matrix = []
	for i: float in range(0, row):
		var temp_row: Array = []
		
		for j: float in range(0, col):
			temp_row.append(0)
		
		matrix.append(temp_row)

	return matrix


func IX(vector: Vector2):
	return Vector2(ceil(vector.x / cell_size.x), ceil(vector.y / cell_size.y))


func _ready():
	for i: float in range(0, container_height, cell_size.y):
	
		var cells_row: Array[ColorRect] = []
		var values_row: Array[float] = []
		
		for j: float in range(0, container_width, cell_size.x):
			var point: Vector2 = Vector2(j, i)
			var cell: ColorRect = cell_scene.instantiate()
			
			cell.global_position = point
			cell.size = cell_size
			container.add_child(cell)
			cells_row.append(cell)
			values_row.append(cell.value)
		
		cells.append(cells_row)
		values.append(values_row)
		


func handle_click():
	if(Input.is_action_pressed("click")):
		var mouse_position: Vector2 = get_global_mouse_position()
		mouse_position.x = clamp(mouse_position.x, 0, container_width)
		mouse_position.y = clamp(mouse_position.y, 0, container_height)
		var clicked_cell_position: Vector2 = IX(mouse_position)
		var clicked_cell_value: float = values[clicked_cell_position.y - 1][clicked_cell_position.x - 1]
		
		if(clicked_cell_value == 0):
			values[clicked_cell_position.y - 1][clicked_cell_position.x - 1] = color_code
			update_cells()

			if(color_code >= 255):
				reverse = true
			elif(color_code <= 50):
				reverse = false

			if(reverse):
				color_code = clampi(color_code-1, 50, 255)
			else:
				color_code = clampi(color_code+1, 50, 255)
		


func update_cells():
	for i in range(0, len(values)):
		for j in range(0, len(values[0])):
			cells[i][j].value = values[i][j]



func print_col(array: Array, col: int, err: bool):
	for i in range(0, len(array)):
		if(err):
			printerr(array[i][col])
		else:
			print(array[i][col])



func update_values():
	
	var new_values: Array = values.duplicate(true)
	
	for i in range(0, len(values)):

		for j in range(0, len(values[0])):

			var value: float = values[i][j]
			
			if(value == 0):
				# value is 0
				continue
			
			if(i + 1 >= len(values)):
				# on ground
				continue
			
			var value_below: float = values[i+1][j]
			
			if(value_below == 0):
				# value_below is 0
				new_values[i][j] = 0
				new_values[i+1][j] = color_code
			else:
				# value_below is 1
				if(j+1 >= len(values[0])):
					if(values[i+1][j-1] == 0):
						new_values[i][j] = 0
						new_values[i+1][j-1] = color_code

					continue
				elif(j-1 < 0):
					if(values[i+1][j+1] == 0):
						new_values[i][j] = 0
						new_values[i+1][j+1] = color_code

					continue
				
				var right_value: float = values[i+1][j+1]
				var left_value: float = values[i+1][j-1]
				var rng_number = rng.randi_range(0,1)
				
				if(rng_number == 0 and right_value == 0):
					new_values[i][j] = 0
					new_values[i+1][j+1] = color_code
				elif(rng_number == 1 and left_value == 0):
					new_values[i][j] = 0
					new_values[i+1][j-1] = color_code
			
	values = new_values
	update_cells()
				

			
func _process(_delta):
	handle_click()
	update_values()

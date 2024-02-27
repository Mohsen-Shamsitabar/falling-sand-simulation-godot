extends Control


@onready var container: Control = get_node(".")
@onready var tileMap: TileMap = get_node("TileMap")
@onready var background: ColorRect = get_node("Background")

@export var container_size = 2000
@export var cell_size = 10
# @export var pen_size = Vector2(3,3)

var grid_size: int = container_size / cell_size
var color_code: float = 0
var empty_value: float = -1
var cells: Array = []
var values: Array = []

# =============================================== #

func _ready():
	tileMap.tile_set.tile_size = Vector2i(cell_size, cell_size)
	background.size = Vector2(container_size, container_size)

	for x in grid_size:

		var cells_row: Array = []
		var values_row: Array[float] = []

		for y in grid_size:

			cells_row.append(null)
			values_row.append(empty_value)
		
		cells.append(cells_row)
		values.append(values_row)
		

func is_clicked_cell_in_bounds(cell_position: Vector2i):
	return (
		cell_position.x >= 0 
		and 
		cell_position.x < grid_size 
		and 
		cell_position.y >= 0 
		and 
		cell_position.y < grid_size
	)


func handle_click():
	if(Input.is_action_pressed("click")):
		var clicked_cell: Vector2i = tileMap.local_to_map(get_global_mouse_position())

		if(not is_clicked_cell_in_bounds(clicked_cell)):
			printerr("out")
			return
		
		var clicked_cell_value: float = values[clicked_cell.x][clicked_cell.y]

		if(clicked_cell_value == empty_value):
			values[clicked_cell.x][clicked_cell.y] = color_code
			# render_cells()

			if(color_code >= 359):
				color_code = 0
			
			color_code = clampf(color_code + 0.25, 0, 359)		


func render_cells():

	for x in grid_size:

		for y in grid_size:

			var value: float = values[x][y]

			if(value >= 0):

				if(cells[x][y] != null):
					continue

				var cell = ColorRect.new()

				cell.global_position = tileMap.map_to_local(Vector2i(x, y))
				cell.size = Vector2(cell_size, cell_size)
				cell.color = Color.from_hsv(value / 359.0, 0.75, 1.0)

				container.add_child(cell)
				cells[x][y] = cell
			else:
				if(cells[x][y] == null):
					continue

				cells[x][y].queue_free()


func update_values():
	
	var new_values: Array = values.duplicate(true)

	for x in grid_size:

		for y in grid_size:

			var value: float = values[x][y]
			
			if(value == empty_value):
				# value is empty_value
				continue
			
			if(y + 1 >= grid_size):
				# on ground
				continue
			
			var value_below: float = values[x][y+1]
			
			if(value_below == empty_value):
				# value_below is empty_value
				new_values[x][y] = empty_value
				new_values[x][y+1] = color_code
			else:
				# value_below is 1
				if(x+1 >= grid_size):
					# right is full
					if(values[x-1][y+1] == empty_value):
						new_values[x][y] = empty_value
						new_values[x-1][y+1] = color_code

					continue
				elif(x-1 < 0):
					# left is full
					if(values[x+1][y+1] == empty_value):
						new_values[x][y] = empty_value
						new_values[x+1][y+1] = color_code

					continue
				
				var right_value: float = values[x+1][y+1]
				var left_value: float = values[x-1][y+1]

				if(right_value == empty_value):
					new_values[x][y] = empty_value
					new_values[x+1][y+1] = color_code
					continue
				elif(left_value == empty_value):
					new_values[x][y] = empty_value
					new_values[x-1][y+1] = color_code
					continue

	values = new_values
	render_cells()				

			
func _process(_delta):
	handle_click()
	update_values()

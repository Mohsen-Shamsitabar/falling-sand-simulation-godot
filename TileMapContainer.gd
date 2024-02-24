extends TileMap


@onready var tileMap: TileMap = get_node(".")

@export var containerSize: int = 1024
@export var cellSize: int = 16

var gridSize: int = containerSize / cellSize
var cells: Dictionary = {}
var colorCode: float = 1.0
var emptyValue: float = 0.0


func _ready():
	tileMap.tile_set.tile_size = Vector2i(cellSize, cellSize)
	tileMap.rendering_quadrant_size = containerSize / cellSize

	for x in gridSize:
		for y in gridSize:
			if(x == 10 and y == 10):
				cells[str(Vector2i(x,y))] = colorCode
				# tileMap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)
			else:
				cells[str(Vector2i(x,y))] = emptyValue
				# tileMap.set_cell(0, Vector2i(x, y), 1, Vector2i(0, 0), 0)

	renderCells()


func isClickedCellInBounds(hoveredTile: Vector2i):
	return (
		hoveredTile.x >= 0 
		and 
		hoveredTile.x < gridSize 
		and 
		hoveredTile.y >= 0 
		and 
		hoveredTile.y < gridSize
	)


func renderCells():
	for x in gridSize:

		for y in gridSize:

			var selectedCell: Vector2i = Vector2i(x, y)
			var value: float = cells[str(selectedCell)]

			if(value == 1) :
				tileMap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)
			else:
				tileMap.set_cell(0, Vector2i(x, y), 1, Vector2i(0, 0), 0)


func handleClick():
	if(Input.is_action_pressed("click")):
		var clickedCell: Vector2i = tileMap.local_to_map(get_global_mouse_position())

		if(not isClickedCellInBounds(clickedCell)):
			return
		
		
		var clickedCellValue: float = cells[str(clickedCell)]

		printerr(clickedCell,"   " ,clickedCellValue)
		if(clickedCellValue == emptyValue):
			cells[str(clickedCell)] = colorCode
			renderCells()


func _process(_delta):
	# print(_delta)
	# str(point): colorCode
	
	
	handleClick()

	# =============
	
	var newCells = cells.duplicate()
	
	for x in gridSize:
		
		for y in gridSize:
		
			var selectedCell: Vector2i = Vector2i(x, y)
			var value: float = cells[str(selectedCell)]
			
			if(value == emptyValue):
				# value is emptyValue
				continue
			
			if(y + 1 >= gridSize):
				# on ground
				continue
			
			var valueBelow: float = cells[str(Vector2i(x, y + 1))]
			
			if(valueBelow == emptyValue):
				# valueBelow is emptyValue
				newCells[str(selectedCell)] = emptyValue
				newCells[str(Vector2i(x, y + 1))] = colorCode
			else:
				# valueBelow is 1
				if(x + 1 >= gridSize):
					# bottomLeft
					if(cells[str(Vector2i(x - 1, y + 1))] == emptyValue):
						newCells[str(selectedCell)] = emptyValue
						newCells[str(Vector2i(x - 1, y + 1))] = colorCode
					
					continue
				elif(x - 1 < 0):
					# bottomRight
					if(cells[str(Vector2i(x + 1, y + 1))] == emptyValue):
						newCells[str(selectedCell)] = emptyValue
						newCells[str(Vector2i(x + 1, y + 1))] = colorCode
					
					continue
				
				var rightValue: float = cells[str(Vector2i(x + 1, y + 1))]
				var leftValue: float = cells[str(Vector2i(x - 1, y + 1))]
				
				if(rightValue == emptyValue):
					newCells[str(selectedCell)] = emptyValue
					newCells[str(Vector2i(x + 1, y + 1))] = colorCode
				elif(leftValue == emptyValue):
					newCells[str(selectedCell)] = emptyValue
					newCells[str(Vector2i(x - 1, y + 1))] = colorCode
	
	cells = newCells
	renderCells()
	

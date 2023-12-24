extends Node2D

@export var notes: Array

# Setup component references, play area
@export var tilemap: TileMap
@export var gameHeight: int
@export var gameWidth: int
@export var clickArea: CollisionShape2D
@export var timer: Timer
@export var soundFirst: AudioStreamPlayer
@export var soundSecond: AudioStreamPlayer
@export var soundThird: AudioStreamPlayer
@export var beatTimer: Timer

# used for map editing and play rate
var stepSpeed: float
var drawPressed: bool = false

# we use 2 maps and switch between them.
# this allows us to determine the cell life before applying the results
var mapData = {}
var switchData = {}

var playMusic: bool = false
var playNoteOne: bool = false
var playNoteTwo: bool = false
var playNoteThree: bool = false

var players = []

# Set the play area to be blank, and set up the clickable area
func _ready() -> void:
	players.append(soundFirst)
	players.append(soundSecond)
	players.append(soundThird)
	Reset()
	clickArea.shape.extents = Vector2(gameWidth * 16 * 0.5, gameHeight * 16 * 0.5)
	clickArea.position += Vector2(gameWidth * 8 + 16, gameHeight * 8 + 16)

# Just wipes the map for a fresh canvas
func Reset() -> void:
	for y in gameHeight:
		for x in gameWidth:
			tilemap.set_cell(0, Vector2i(x+1,y+1),0, Vector2i(0,0))
			mapData[Vector2i(x + 1,y + 1)] = 0
			switchData[Vector2i(x + 1,y + 1)] = 0
	
	

# Left click adds a cell, right click removes a cell
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# First we need to know what cell the mouse is on
	var mousetile = GetMouseTile()
	# This lets us switch between adding/removing cells - adds by default
	var switchCell: int = 1
	# Left click just means draw
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		drawPressed = true
	# Right click means draw (but with an "eraser")
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		drawPressed = true
		# Set switchCell to 0 to make it an "eraser"
		switchCell = 0
	else:
		# If the input event wasn't a click, we don't need to draw
		drawPressed = false

	# Check if the mouse is actually on the canvas, and a button is pressed
	if TileExists(mousetile) and drawPressed == true:
		# Our atlas has 2 tiles: white (represented as "0,0") and
		# black (represented as "1,0"). This is where our switchCell
		# variable comes in handy.
		tilemap.set_cell(0, mousetile,0, Vector2i(switchCell,0))
		# now that we've picked a colour, we store the new data in our map 
		#mapData[mousetile] = switchCell
		switchData[mousetile] = switchCell
	

# our cells are 16 by 16. so to get the tile the mouse is on, we just
# take our mouse position and divide it by 16.
func GetMouseTile() -> Vector2i:
	return get_local_mouse_position() / 16
	

# This is what updates our cells. Each time this function is called, it goes
# through every cell and checks whether it lives or dies.
func Step():
	for cell in mapData:
		var liveState = mapData[cell]
		var alives = GetNumAliveNeighbours(cell)
		var newState = DoesCellLive(liveState, alives)
		TryPlayNote(liveState, alives)
		if mapData[cell] != newState:
			tilemap.set_cell(0,cell,0,Vector2i(newState,0))
			switchData[cell] = newState
	
	# Once we've determined which cells should be alive or dead, we can apply
	# the results to our datamap
	mapData = switchData.duplicate()


# This takes a cell, and checks it's 8 surrounding cells.
# It then returns the number of living neighbours
func GetNumAliveNeighbours(cell: Vector2i) -> int:
	var count: int = 0
	for y in range(cell.y - 1, cell.y + 2):
		for x in range(cell.x - 1, cell.x + 2):
			var neighbour: Vector2i = Vector2i(x,y)
			if TileExists(neighbour):
				if neighbour != cell and mapData[neighbour] == 1:
					count += 1
	return count

# This is just to make sure we're not trying to do stuff outside
# the canvas area
func TileExists(coord: Vector2i) -> bool:
	if coord.x > 0 and coord.x <= gameWidth:
		if coord.y > 0 and coord.y <= gameHeight:
			return true
	
	return false

# This is what determines whether a cell lives or dies.
# State will always be either 1(alive) or 0(dead).
func DoesCellLive(state: int, aliveNeighbours: int) -> int:
	if aliveNeighbours < 2 and state == 1:
		return 0
	if aliveNeighbours > 1 and aliveNeighbours < 4 and state == 1:
		return 1
	if aliveNeighbours > 3 and state == 1:
		return 0
	if state == 0 and aliveNeighbours == 3:
		return 1
	
	return 0

func TryPlayNote(state: int, aliveNeighbours: int):
	if state == 1 and aliveNeighbours > 0 and aliveNeighbours < 8:
		if soundFirst.playing == false or soundFirst.get_playback_position() > 0.4:
			if playNoteOne:
				DoPlayNote(soundFirst, aliveNeighbours - 1)
		elif soundSecond.playing == false or soundSecond.get_playback_position() > 0.4:
			if playNoteTwo:
				DoPlayNote(soundSecond, GetRightNote(aliveNeighbours - 1, 2))
		elif soundThird.playing == false or soundThird.get_playback_position() > 0.4:
			if playNoteThree:
				DoPlayNote(soundThird, GetRightNote(aliveNeighbours - 1, 4))
		

func GetRightNote(note: int, harmony: int) -> int:
	if note + harmony < 7:
		return note + harmony
	
	return (note + harmony) - 6

func DoPlayNote(player: AudioStreamPlayer, note: int):
	if note != -1:
		player.stream = notes[note]
	player.play()

func StopAllMusic():
	soundFirst.stop()
	soundSecond.stop()
	soundThird.stop()

func _on_btn_step_pressed() -> void:
	Step()

# Every time our timer runs out, we update the game
func _on_timer_timeout() -> void:
	Step()


# Starts the timer
func _on_btn_play_pressed() -> void:
	playMusic = true
	timer.start()

# Stops the timer
func _on_btn_stop_pressed() -> void:
	timer.stop()
	playMusic = false


# this takes what was typed in the "speed" option and converts it into a float.
# If what was typed is valid, we can change the speed of the simulation.
func _on_txt_speed_text_changed(new_text: String) -> void:
	stepSpeed = float(new_text)
	if stepSpeed > 0:
		timer.wait_time = stepSpeed


func _on_btn_reset_pressed() -> void:
	Reset()


func _on_note_timer_timeout() -> void:
	playNoteOne = randi_range(0,1)
	playNoteTwo = randi_range(0,1)
	playNoteThree = randi_range(0,1)
	
#	if soundFirst.stream != null:
#		soundFirst.play()


func _on_beat_timer_timeout() -> void:
	if stepSpeed != 0:
		beatTimer.wait_time = stepSpeed
	if playMusic:
		DoPlayNote(players[randi_range(0,1)], -1)
	else:
		StopAllMusic()

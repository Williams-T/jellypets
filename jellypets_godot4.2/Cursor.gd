extends Node2D

# Cursors
@export var cursor_default : Texture2D
@export var cursor_pointing : Texture2D
@export var cursor_tapping : Texture2D
@export var cursor_petting : Texture2D
@export var cursor_grabbing : Texture2D
@export var cursor_none : Texture2D

enum states{IDLE, POINTING, PETTING, GRABBING}
@export var color1 : Color
@export var color2 : Color
@export var color3 : Color
@export var color4 : Color
@export var color5 : Color
@export var color6 : Color
var colors = []
var current_color
var last_color
@export var cursor_scale_factor = 1.0

@export var move_speed := 0.3
var tweened = true

var l_clickstate = false
var r_clickstate = false
var hovering = false
var focus : Node
var last_pos : Vector2i
var spr

var hold_l = 0.0
var hold_r = 0.0
var last_hold = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	#if not Engine.is_editor_hint():
	#	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	spr = $Sprite2D
	spr.texture = cursor_default
	spr.scale = Vector2(cursor_scale_factor, cursor_scale_factor)
	pass # Replace with function body.

func _input(event):
	var pos = spr.global_position
	if event.is_action_pressed("left_click"):
		spr.texture = cursor_grabbing
		hold_l = 0.1
	elif event.is_action_released("left_click"):
		spr.texture = cursor_default
		last_hold.x = hold_l
		hold_l = 0.0
		print(last_hold)
	elif event.is_action_pressed("right_click"):
		spr.texture = cursor_pointing
		hold_r = 0.1
	elif event.is_action_released("right_click"):
		spr.texture = cursor_grabbing
		last_hold.y = hold_r
		hold_r = 0.0
		print(last_hold)
	if pos.y < 80:
		pass
	elif pos.y >86 and pos.y < 271:
		var closeness = ((pos.y - 81.0)/90.0)+1.0
		cursor_scale(closeness)

func cursor_scale(scale):
	var min = 0.7
	var max = 4.0
	if scale < min:
		scale = min
	if scale > max:
		scale = max
	spr.scale = Vector2(scale, scale)
	cursor_scale_factor = scale

func change():
	var colors = [color1, color2, color3, color4, color5, color6]
	if tweened == true:
		tweened = false
		randomize()
		var tween := create_tween().set_loops(1)
		tween.tween_property(spr, "rotation", randf_range(spr.rotation-0.3, spr.rotation+0.3), randf_range(0.3, 1.7)).from_current()
		var temp = randi_range(0,5)
		current_color=colors[temp]
		tween.tween_property(self, "modulate", current_color, randf_range(0.3, 1.5)).from_current()
		tweened = true

func get_scale_factor():
	return cursor_scale_factor

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spr.global_position = spr.get_global_mouse_position()
	if hold_l > 0:
		hold_l += delta
	
	if hold_r > 0:
		hold_r += delta

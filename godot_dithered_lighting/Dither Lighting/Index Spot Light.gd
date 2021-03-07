tool
extends SpotLight

export var index := 0 setget set_index, get_index
export var palette_size := 16 setget set_palette_size, get_palette_size

func get_point_on_unit_circle(x):
	return sqrt(1 - (x*x))

func set_index(i):
	index = i
	
	var r = float(index) / float(palette_size - 1)
	var g = get_point_on_unit_circle(r)
	
	light_color = Color(r, g, 0.0)

func get_index():
	return index

func set_palette_size(size):
	palette_size = size

func get_palette_size():
	return palette_size

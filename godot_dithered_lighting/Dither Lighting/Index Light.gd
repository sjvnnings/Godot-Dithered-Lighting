tool
extends DirectionalLight

export var index := 0 setget set_index, get_index
export var palette_size := 16 setget set_palette_size, get_palette_size

func get_point_on_unit_circle(x):
	return sqrt(1 - (x*x))

#The lighting model uses the R value of the normalized light color as a texture index. This automatically configures
#the light color accordingly.
func set_index(i):
	index = i
	
	var r = float(index) / float(palette_size)
	
	#We set G to be a point on the unit circle so when we normalize the color in the shader, we can get the correct R value.
	var g = get_point_on_unit_circle(r)
	
	light_color = Color(r, g, 0.0)

func get_index():
	return index

func set_palette_size(size):
	palette_size = size

func get_palette_size():
	return palette_size

func _ready():
	#Make sure that the index has been correctly set before play. Not doing so may result in incorrect lighting.
	set_index(index)

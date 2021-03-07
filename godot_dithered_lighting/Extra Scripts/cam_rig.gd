extends Spatial

const MOUSE_SENSITIVITY = 0.1

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(20.0 * event.relative.x * MOUSE_SENSITIVITY))

extends Camera3D
@export var source_camera_path: NodePath
var source_camera: Camera3D
func _ready():
	source_camera = get_node(source_camera_path)
func _process(_dt):
	if source_camera:
		global_transform = source_camera.global_transform
		fov = source_camera.fov
		far = source_camera.far
		near = source_camera.near

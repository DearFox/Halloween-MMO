extends SubViewport

@onready var root_window: Window = get_tree().root

func _ready() -> void:
    _sync_size()
    if root_window:
        root_window.size_changed.connect(_sync_size)

func _exit_tree() -> void:
    if root_window and root_window.size_changed.is_connected(_sync_size):
        root_window.size_changed.disconnect(_sync_size)

func _sync_size() -> void:
    if not root_window:
        return
    size = root_window.content_scale_size

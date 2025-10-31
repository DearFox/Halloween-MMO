extends MeshInstance3D


@export var textures: Array[Texture2D] = []

func _ready():
    if textures.is_empty():
        push_warning("Массив textures пуст — добавь текстуры в инспекторе.")
        print("No textures available to pick from.")
        return

    # Получаем случайную текстуру
    var random_texture = textures.pick_random()

    # Копируем текущий материал, чтобы не менять оригинальный ресурс
    var mat = get_active_material(0)
    if mat == null:
        push_warning("Нет материала в слоте 0")
        print("No material found in slot 0.")
        return

    # Делаем дубликат, чтобы изменения не затрагивали другие объекты
    var new_mat = mat.duplicate()
    if new_mat is BaseMaterial3D:
        new_mat.albedo_texture = random_texture
    else:
        push_warning("Материал типа %s не поддерживает albedo_texture" % [new_mat.get_class()])
        return

    # Применяем новый материал
    if material_override != null:
        material_override = new_mat
    else:
        set_surface_override_material(0, new_mat)
    print("Random texture applied: ", random_texture)
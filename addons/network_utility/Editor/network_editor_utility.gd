@tool
class_name NetworkEditorUtility
extends Control


var add_mode:bool


signal dissolve
signal merge
signal remove
signal link
signal subdivide


func _on_add_toggled(button_pressed:bool) -> void:
	add_mode = button_pressed

func _on_dissolve_pressed() -> void:
	dissolve.emit()


func _on_merge_pressed() -> void:
	merge.emit()


func _on_remove_pressed() -> void:
	remove.emit()


func _on_link_pressed() -> void:
	link.emit()


func _on_subdivide_pressed() -> void:
	subdivide.emit()

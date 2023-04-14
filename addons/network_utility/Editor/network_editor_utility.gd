@tool
class_name NetworkEditorUtility
extends Control


var add_mode:bool
var portal_mode:bool


signal dissolve
signal merge
signal remove
signal link
signal subdivide
signal unlink


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


func _on_portal_toggled(button_pressed:bool) -> void:
	portal_mode = button_pressed


func reset_portal_mode() -> void:
	($"Box/Portal" as Button).button_pressed = false # will call signal automatically


func _on_unlink_pressed() -> void:
	unlink.emit()

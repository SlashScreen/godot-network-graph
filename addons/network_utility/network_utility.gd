@tool
extends EditorPlugin


var network_gizmo:NetworkGizmo = NetworkGizmo.new()


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_node_3d_gizmo_plugin(network_gizmo)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_node_3d_gizmo_plugin(network_gizmo)

@tool
extends EditorPlugin


## Container we add the toolbar to
const container = CONTAINER_SPATIAL_EDITOR_MENU

## The active [NetworkEditorUtility].
var utility:NetworkEditorUtility
## Gizmo instance for a [NetworkInstance].
var network_gizmo:NetworkGizmo = NetworkGizmo.new()
## Currently editing network.
var target:Network:
	get:
		return target
	set(val):
		if target == val: # Prevent reinitializing a whole lot. may be redundant.
			return
		target = val
		_set_toolbar_visibility(not val == null) # set toolbar visibility to true if it isnt null


func _enter_tree() -> void:
	# Initialize utility
	utility = load("addons/network_utility/Editor/editor_toolbar.tscn").instantiate()
	add_control_to_container(container, utility) # add to spatial toolbar
	_set_toolbar_visibility(false) # hide by default

	# Selection
	get_editor_interface()\
		.get_selection()\
		.selection_changed\
		.connect(_selection_changed.bind())
	
	# Gizmo
	add_node_3d_gizmo_plugin(network_gizmo)


func _exit_tree() -> void:
	remove_control_from_container(container, utility)
	remove_node_3d_gizmo_plugin(network_gizmo)


func _selection_changed() -> void:
	# Get selected nodes
	var selections = get_editor_interface()\
							.get_selection()\
							.get_selected_nodes()
	# Skip if no selections 
	if selections.is_empty():
		target = null
		return
	# Set target if network instance
	if selections[0] is NetworkInstance:
		target = selections[0].network
		return
	target = null



func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	# TODO: If add mode, block and process click
	return AFTER_GUI_INPUT_PASS


func _set_toolbar_visibility(state:bool) -> void:
	if utility:
		if state:
			utility.show()
		else:
			utility.hide()

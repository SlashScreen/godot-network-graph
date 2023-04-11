@tool
extends EditorPlugin


## Container we add the toolbar to
const container = CONTAINER_SPATIAL_EDITOR_MENU
const RAY_LENGTH:float = 500
const SNAP_DISTANCE:float = 0.5

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
var _target_node:NetworkInstance


func _enter_tree() -> void:
	# Initialize utility
	utility = load("addons/network_utility/Editor/editor_toolbar.tscn").instantiate()
	add_control_to_container(container, utility) # add to spatial toolbar
	_set_toolbar_visibility(false) # hide by default
	# Connect the buttons
	utility.link.connect(_on_link.bind())
	utility.merge.connect(_on_merge.bind())
	utility.remove.connect(_on_remove.bind())
	utility.dissolve.connect(_on_dissolve.bind())

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


func _handles(object: Object) -> bool:
	return object is NetworkInstance


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
		_target_node = selections[0]
		target = selections[0].network
		return
	target = null



func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	# if no utility, pass
	if not utility:
		return AFTER_GUI_INPUT_PASS
	# if no target, pass
	if target == null:
		return AFTER_GUI_INPUT_PASS
	# if not in add mode, pass
	if not utility.add_mode:
		return AFTER_GUI_INPUT_PASS
	# pass if event isn't a mouse button
	if not event is InputEventMouseButton:
		return AFTER_GUI_INPUT_PASS
	# pass if not mouse right click down
	if not (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT or \
		not (event as InputEventMouseButton).pressed:
			return AFTER_GUI_INPUT_PASS
	# If we passed all failure conditions, we block and add point
	_add_point(viewport_camera, event)
	return AFTER_GUI_INPUT_STOP


func _set_toolbar_visibility(state:bool) -> void:
	if utility:
		if state:
			utility.show()
		else:
			utility.hide()


func _on_dissolve() -> void:
	if target and network_gizmo.last_modified:
		# dissolve selected point
		target.dissolve_point(network_gizmo.last_modified)


func _on_remove() -> void:
	if target and network_gizmo.last_modified:
		# remove selected point
		target.remove_point(network_gizmo.last_modified)


func _on_merge() -> void:
	if target and network_gizmo.last_modified and network_gizmo.second_last_modified:
		# Merge the last two selected points
		target.merge_points(network_gizmo.last_modified, network_gizmo.second_last_modified)


func _on_link() -> void:
	if target and network_gizmo.last_modified and network_gizmo.second_last_modified:
		# Add an edge between the two last selected points
		target.add_edge(network_gizmo.last_modified, network_gizmo.second_last_modified)


## Add or link nodes.
func _add_point(camera: Camera3D, event: InputEventMouseButton) -> void:
	# return if no target
	if not _target_node:
		return
	var hit_pos:Vector3

	# Step 1: find hit point
	var from = camera.project_ray_origin(event.position)
	var to = from + (camera.project_ray_normal(event.position) * RAY_LENGTH)
	var ray = PhysicsRayQueryParameters3D.create(from, to)
	# wait for physics
	await _target_node.get_tree().physics_frame
	var hits = _target_node.get_world_3d().direct_space_state.intersect_ray(ray)
	if hits:
		hit_pos = hits["position"]
	else:
		return
	
	# Step 2: determine if linking to anything else
	var linking:bool = false
	var link_target:NetworkPoint
	var candidates = target.points.filter(func(x:NetworkPoint): return hit_pos.distance_to(x.position) <= SNAP_DISTANCE) # Get all points within distance
	candidates.sort_custom(func(a:NetworkPoint, b:NetworkPoint): return hit_pos.distance_to(a.position) < hit_pos.distance_to(b.position)) # sort by distance
	# if we have candidates, grab closest one
	if not candidates.is_empty():
		linking = true
		link_target = candidates[0]
	
	# Step 3: perform link or add
	if linking: # we are linking
		target.add_edge(link_target, network_gizmo.last_modified) # add between last selected and this one
	else: # add new node
		var new_pt = target.add_point(hit_pos)
		# if there is something to link, try linking
		if network_gizmo.last_modified:
			target.add_edge(new_pt, network_gizmo.last_modified)

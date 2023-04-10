class_name NetworkGizmo
extends EditorNode3DGizmoPlugin


func _init() -> void:
	create_material("edge", Color(0, 1, 0)) # Edge color
	create_material("point_unselected", Color(0, 0, 1)) # Color for normal points
	create_material("point_select0", Color(1, 0, 0)) # Color for recently selected points
	create_material("point_select1", Color(1, 1, 0)) # Color for second most recently selected points
	create_handle_material("handles")


func _get_gizmo_name() -> String:
	return "Network"


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is NetworkInstance


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	# For each node:
	var mesh = SphereMesh.new()
	var handle_pts = PackedVector3Array()
	for n in gizmo.get_node_3d().network.points:
		# set transform
		var t = Transform3D()
		t = t.scaled(Vector3(0.1, 0.1, 0.1))
		t.origin = n.position
		# Draw node sphere and handle
		# TODO: Handle associating
		handle_pts.append(n.position)
		gizmo.add_mesh(mesh, get_material("point_unselected", gizmo), t)
	# Then for each edge:
	var pts = PackedVector3Array()
	for e in gizmo.get_node_3d().network.edges:
		# Add line points
		pts.append(e.point_a.position)
		pts.append(e.point_b.position)
	# Then draw lines
	gizmo.add_lines(pts, get_material("edge", gizmo))
	# Add handles
	gizmo.add_handles(handle_pts, get_material("handles", gizmo), [])

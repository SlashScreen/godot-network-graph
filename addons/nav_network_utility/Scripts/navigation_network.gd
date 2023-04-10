@tool
class_name NavigationNetwork
extends Resource
## This is the network graph itself, containing nodes and edges.


## The points in this network.
@export var points:Array[NavigationNetworkPoint] = []
## The edges in this network.
@export var edges:Array[NavigationNetworkEdge] = []
## This dictionary contains an array (value) of edges that involve a point (key).
var edge_map:Dictionary = {}


## Add a point to this network.
func add_point(pt:Vector3) -> NavigationNetworkPoint:
	# Create edge
	var new_point = NavigationNetworkPoint.new(pt)
	# Initialize map entry
	edge_map[new_point] = []
	# Add to points
	points.append(new_point)

	return new_point


## Remove a point from the network and all associated connections. See [method dissolve_point].
func remove_point(pt:NavigationNetworkPoint) -> void:
	points.erase(pt)
	# Remove all edges involving this node
	for edge in edge_map[pt]:
		# Get other point in the edge.
		var other = edge.point_a if edge.point_b == pt else edge.point_a
		# Erase edge from the other entry in the edge map, disconnecting it from both sides.
		edge_map[other].erase(edge)
		# Erase edge from edge list.
		edges.erase(edge)
	
	# Erase all entries in edge map.
	edge_map.erase(pt)


## Dissolve a point in the network, connecting all nodes it was connected to together. See [method remove_point].
func dissolve_point(pt:NavigationNetworkPoint) -> void:
	# TODO: Cost?
	# The nodes this point was connected to, so we can connect them to eachother.
	var to_connect = []
	# Loop through edges and get the other point.
	for edge in edge_map[pt]:
		to_connect.append(edge.point_a if edge.point_b == pt else edge.point_a)
	# Remove the point and associated connections
	remove_point(pt)
	# For unique pairs of to connect, connect edge
	for pair in _find_unique_pairs(to_connect):
		add_edge(pair[0], pair[1])


## Merge two points together and reconnect all connections.
func merge_points(a:NavigationNetworkPoint, b:NavigationNetworkPoint) -> NavigationNetworkPoint:
	# Create a new node from the average of 2 points
	var new_node = add_point((a.position + b.position)/2)
	# Track other edges to reconnect to the new node
	var to_connect = []

	# Add other side of edges for a
	for edge in edge_map[a]:
		var other = edge.point_a if edge.point_b == a else edge.point_a
		# Skip connections to other node we are merging
		if other == b:
			continue
		
		to_connect.append(other)
	# Add other side of edges for b
	for edge in edge_map[b]:
		var other = edge.point_a if edge.point_b == b else edge.point_a
		# Skip connections to other node we are merging
		if other == a:
			continue
		
		to_connect.append(other)
	
	# Reconnect everything
	for other in to_connect:
		add_edge(new_node, other)

	return new_node


## Add an edge to this network.
func add_edge(a:NavigationNetworkPoint, b:NavigationNetworkPoint, cost:float = 1, bidirectional:bool = true) -> NavigationNetworkEdge:
	# Create edge
	var edge = NavigationNetworkEdge.new(a, b, cost, bidirectional)
	# Add this edge to the edge map
	edge_map[a].append(edge)
	edge_map[b].append(edge)
	# Add to edges
	edges.append(edge)

	return edge


## Remove an edge from the network.
func remove_edge(edge:NavigationNetworkEdge) -> void:
	# Erase edge map entry on both sides
	edge_map[edge.point_a].erase(edge)
	edge_map[edge.point_b].erase(edge)
	# Erase from edge database
	edges.erase(edge)


## Find all unique pairs of an array
func _find_unique_pairs(arr:Array) -> Array[Array]:
	var pairs = []

	for i in range(arr.size() - 1):
		for j in range(i + 1, arr.size()):
			if arr[i] == arr[j]:
				continue
			pairs.append([arr[i], arr[j]])

	return pairs

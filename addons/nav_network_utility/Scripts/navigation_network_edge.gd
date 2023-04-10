@tool
class_name NavigationNetworkEdge
extends Resource


@export var point_a:NavigationNetworkPoint
@export var point_b:NavigationNetworkPoint
@export var cost:float = 1
@export var bidirectional:bool = true


func _init(a:NavigationNetworkPoint, b:NavigationNetworkPoint, cost:float = 1, bidirectional:bool = true) -> void:
	self.point_a = a
	self.point_b = b
	self.cost = cost
	self.bidirectional = bidirectional

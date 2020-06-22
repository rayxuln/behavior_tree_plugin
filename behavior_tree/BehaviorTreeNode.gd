
extends Node

class_name BehaviorTreeNode

enum BTNResult{
	RUNNING,
	FINISHED
}

var bte_identity

export(NodePath) var behavior_tree_path setget _on_behavior_tree_path_set, _on_behavior_tree_path_get
func _on_behavior_tree_path_set(v):
	behavior_tree_path = v
func _on_behavior_tree_path_get():
	return behavior_tree_path 
var behavior_tree:Node = null
func get_behavior_tree() -> Node:
	if behavior_tree:
		return behavior_tree
	if behavior_tree_path:
		behavior_tree = get_node_or_null(behavior_tree_path)
		return behavior_tree
	var node = get_parent()
	while node:
		if node.has_method("BehaviorTree"):
			behavior_tree = node
			return behavior_tree
		node = node.get_parent()
	return null

export(NodePath) var condition_path setget _on_condition_path_set, _on_condition_path_get
func _on_condition_path_set(v):
	condition_path = v
	condition = get_node_or_null(condition_path)
func _on_condition_path_get():
	return condition_path 
onready var condition = get_node_or_null(condition_path)

var active:bool = true

func BehaviorTreeNode():
	pass

	
func get_first_availible_child() -> Node:
	for child in get_children():
		if child.has_method("BehaviorTreeNode"):
			return child
	return null
func get_next_availible_child(start_child:Node) -> Node:
	var i = start_child.get_index() + 1
	while i < get_child_count():
		var child:Node = get_child(i)
		if child.has_method("BehaviorTreeNode"):
			return child
		i += 1
	return null
func get_availible_child_count():
	var child = get_first_availible_child()
	var cnt = 0
	while child:
		cnt += 1
		child = get_next_availible_child(child)
	return cnt

func get_from_database(key):
	var bt = get_behavior_tree()
	if bt:
		if bt.database.has(key):
			return bt.database[key]
	return null
func set_to_database(key, value):
	var bt = get_behavior_tree()
	if bt:
		bt.database[key] = value
func get_node_from_behavior_tree(path:NodePath) -> Node:
	var bt = get_behavior_tree()
	if bt:
		return bt.get_node_or_null(path)
	return null
func get_node_from_database(key) -> Node:
	var v = get_from_database(key)
	if v and v is NodePath:
		return get_behavior_tree().get_node_or_null(v)
	return null

func eval():
	return active and ((not condition) or condition.check(self)) and do_eval()

# override
func activate():
	pass

# override
func do_eval():
	return true

# override
func tick():
	return BTNResult.FINISHED

# override
func clear():
	pass


extends "BehaviorTreeNode.gd"

class_name BehaviorTreeNodeProxy

export(NodePath) var behavior_tree_node_path setget _on_behavior_tree_node_path_set, _on_behavior_tree_node_path_get
func _on_behavior_tree_node_path_set(v):
	behavior_tree_node_path = v
	behavior_tree_node = get_node_or_null(behavior_tree_node_path)
func _on_behavior_tree_node_path_get():
	return behavior_tree_node_path 
onready var behavior_tree_node = get_node_or_null(behavior_tree_node_path)

func BehaviorTreeNodeProxy():
	pass

# override
func activate():
	if behavior_tree_node:
		behavior_tree_node.activate()

# override
func do_eval():
	if behavior_tree_node:
		return behavior_tree_node.do_eval()
	return true

# override
func tick():
	if behavior_tree_node:
		return behavior_tree_node.tick()
	return BTNResult.FINISHED

# override
func clear():
	if behavior_tree_node:
		behavior_tree_node.clear()

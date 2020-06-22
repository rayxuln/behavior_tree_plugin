
extends Resource

class_name  BehaviorTreeScriptDataResource

var graph_node:Node

export(Dictionary) var data setget _on_data_set, _on_data_get
func _on_data_set(v):
	if graph_node.is_queued_for_deletion():
		return
	graph_node.resource_data["data"] = v
func _on_data_get():
	if graph_node.is_queued_for_deletion():
		return null
	return graph_node.resource_data["data"]

export(bool) var is_root setget _on_is_root_set, _on_is_root_get
func _on_is_root_set(v):
	if graph_node.is_queued_for_deletion():
		return
	if not graph_node.has_method("BehaviorTreeEditorGraphNodeCondition"):
		if v:
			graph_node.resource.root = graph_node.name
		else:
			if graph_node.resource.root == graph_node.name:
				graph_node.resource.root = ""
func _on_is_root_get():
	if graph_node.is_queued_for_deletion():
		return false
	if not graph_node.has_method("BehaviorTreeEditorGraphNodeCondition"):
		return graph_node.resource.root == graph_node.name
	return false

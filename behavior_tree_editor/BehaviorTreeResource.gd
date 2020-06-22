tool
extends Resource

class_name BehaviorTreeResource

export(String) var tree_name = "Behavior Tree"

export(Array) var nodes:Array
export(Array) var connections:Array
export(String) var root:String

enum NodeType{
	NodeUndefined,
	NodeAction,
	NodeConcurrent,
	NodePrioritySelector,
	NodeProxy,
	NodeRandomSelector,
	NodeSequenceSelector,
	Condition
}

func node_type_to_string(t):
	match t:
		NodeType.NodeUndefined:
			return "Unkown"
		NodeType.NodeAction:
			return "Action"
		NodeType.NodeConcurrent:
			return "Concurrent"
		NodeType.NodePrioritySelector:
			return "PrioritySelector"
		NodeType.NodeProxy:
			return "Proxy"
		NodeType.NodeRandomSelector:
			return "RandomSelector"
		NodeType.NodeSequenceSelector:
			return "SequenceSelector"
		NodeType.Condition:
			return "Condition"

func create_node(type):
	var res = {
		"g_name": "",
		"position": Vector2.ZERO,
		"type": type,
		"name": "Unkown",
		"custom_script": null,
		"data": {}
	}
	match type:
		NodeType.NodeUndefined:
			pass
		NodeType.NodeAction:
			pass
		NodeType.NodeConcurrent:
			res["concurrent_mode"] = 0
			res["condition_mode"] = 0
		NodeType.NodePrioritySelector:
			res["max_select_delay"] = 0
			res["min_select_delay"] = 0
			res["delay_on_start"] = false
		NodeType.NodeProxy:
			pass
		NodeType.NodeRandomSelector:
			res["max_select_delay"] = 0
			res["min_select_delay"] = 0
			res["delay_on_start"] = false
		NodeType.NodeSequenceSelector:
			pass
		NodeType.Condition:
			pass
	nodes.append(res)
	return res

func remove_node(n):
	nodes.remove(nodes.find(n))

func is_root_exist():
	if root.empty():
		return false
	
	# check if the root exists
	for n in nodes:
		if n["g_name"] == root:
			return true
	return false

func get_node_by(k, v):
	for n in nodes:
		if n[k] == v:
			return n

func get_children_by_g_name(from):
	var res = []
	for c in connections:
		if c["from"] == from:
			res.append(get_node_by("g_name", c["to"]))
	return res

func create_node_by_data(node_data):
	match(node_data["type"]):
		NodeType.NodeUndefined:
			return null
		NodeType.NodeAction:
			var n = BehaviorTreeNodeAction.new()
			n.name = node_data["name"]
			if node_data["custom_script"]:
				n.set_script(node_data["custom_script"])
			n.bte_identity = node_data["g_name"]
			set_node_properties_from_data(n, node_data["data"])
			return n
		NodeType.NodeConcurrent:
			var n = BehaviorTreeNodeConcurrent.new()
			n.name = node_data["name"]
			n.bte_identity = node_data["g_name"]
			n.concurrent_mode = node_data["concurrent_mode"]
			n.condition_mode = node_data["condition_mode"]
			return n
		NodeType.NodePrioritySelector:
			var n = BehaviorTreeNodePrioritySelector.new()
			n.name = node_data["name"]
			n.bte_identity = node_data["g_name"]
			n.min_select_delay = node_data["min_select_delay"]
			n.max_select_delay = node_data["max_select_delay"]
			n.delay_on_start = node_data["delay_on_start"]
			return n
		NodeType.NodeProxy:
			var n = BehaviorTreeNodeProxy.new()
			n.name = node_data["name"]
			n.bte_identity = node_data["g_name"]
			return n
		NodeType.NodeRandomSelector:
			var n = BehaviorTreeNodeRandomSelector.new()
			n.name = node_data["name"]
			n.bte_identity = node_data["g_name"]
			n.min_select_delay = node_data["min_select_delay"]
			n.max_select_delay = node_data["max_select_delay"]
			n.delay_on_start = node_data["delay_on_start"]
			return n
		NodeType.NodeSequenceSelector:
			var n = BehaviorTreeNodeSequenceSelector.new()
			n.name = node_data["name"]
			n.bte_identity = node_data["g_name"]
			return n
		NodeType.Condition:
			var n = BehaviorTreeCondition.new()
			n.name = node_data["name"]
			if node_data["custom_script"]:
				n.set_script(node_data["custom_script"])
			n.bte_identity = node_data["g_name"]
			set_node_properties_from_data(n, node_data["data"])
			return n

func set_node_properties_from_data(node:Node, data:Dictionary):
	for key in data.keys():
		node.set(key, data[key])

func get_node_datas_by(key, value):
	var res = []
	for n in nodes:
		if n[key] == value:
			res.append(n)
	return res

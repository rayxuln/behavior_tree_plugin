tool
extends Node

class_name BehaviorTree

export(Resource) var behavior_tree_resource

export(NodePath) var root_path setget _on_root_path_set, _on_root_path_get
func _on_root_path_set(v):
	root_path = v
	root = get_node_or_null(root_path)
func _on_root_path_get():
	return root_path
onready var root = get_node_or_null(root_path)

export(Dictionary) var database

export(bool) var enable = true
export(bool) var debug_mode = true

func BehaviorTree():
	pass

func get_node_by(k, v, parent=null):
	parent = parent if parent else self
	for c in parent.get_children():
		if c.get(k) == v:
			return c
		var res = get_node_by(k, v, c)
		if res:
			return res
	return null

func gen_nodes_from_behavior_tree_resource(res:BehaviorTreeResource):
	if not res.is_root_exist():
		return
	
	# Generate Behvavior Tree Nodes from root
	var root_node = gen_node_from_data(self, res.get_node_by("g_name", res.root), res)
		
	# Generate conditions node
	var condition_datas = res.get_node_datas_by("type", BehaviorTreeResource.NodeType.Condition)
	for n in condition_datas:
		gen_node_from_data(self, n, res)
	
	# Connect condittions node
	connect_condition(root_node, res)
	
	# Connect proxy node
	connect_proxy(root_node, res)
	
	# done!
	self.root_path = get_path_to(root_node)

func gen_node_from_data(parent_node:Node, node_data, res:BehaviorTreeResource):
	var new_node = res.create_node_by_data(node_data)
	if not new_node:
		return null
	parent_node.add_child(new_node)
	
	if node_data["type"] == BehaviorTreeResource.NodeType.NodeProxy:
		return new_node
	if node_data["type"] == BehaviorTreeResource.NodeType.NodeAction:
		return new_node
	if node_data["type"] == BehaviorTreeResource.NodeType.Condition:
		return new_node
	# fetch the children
	var children = res.get_children_by_g_name(node_data["g_name"])
	for child in children:
		if child["type"] != BehaviorTreeResource.NodeType.Condition:
			gen_node_from_data(new_node, child, res)
	return new_node

func connect_condition(node:Node, res:BehaviorTreeResource):
	if not node:
		return
		
	# connect to condition
	var children = res.get_children_by_g_name(node.bte_identity)
	for child in children:
		if child["type"] == BehaviorTreeResource.NodeType.Condition:
			var cond = get_node_by("bte_identity", child["g_name"])
			node.condition_path = node.get_path_to(cond)
	
	# travel node
	for child in node.get_children():
		if child.has_method("BehaviorTreeNode"):
			connect_condition(child, res)

func connect_proxy(node:Node, res:BehaviorTreeResource):
	if not node:
		return
		
	# connect to proxy
	if node.has_method("BehaviorTreeNodeProxy"):
		var children = res.get_children_by_g_name(node.bte_identity)

		for child in children:
			if child["type"] != BehaviorTreeResource.NodeType.Condition:
				var btn = get_node_by("bte_identity", child["g_name"])
				node.behavior_tree_node_path = node.get_path_to(btn)
	
	# travel node
	for child in node.get_children():
		if child.has_method("BehaviorTreeNode"):
			connect_proxy(child, res)

func _ready():
	if Engine.editor_hint:
		return
	if behavior_tree_resource:
		gen_nodes_from_behavior_tree_resource(behavior_tree_resource)
	if root:
		root.activate()

func _process(_delta):
	if Engine.editor_hint:
		return
	if not enable:
		return

	if root and root.eval():
		root.tick()

func reset():
	if root:
		root.clear()

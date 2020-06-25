tool
extends Control

var the_plugin

var current_behavior_tree

var editor_selection:EditorSelection

onready var graph_edit = $GraphEdit
onready var warning_label = $WarningLabel
onready var empty_menu = $EmptyPopupMenu

#const GraphNode_BehaviorTreeNode = preload("BehaviorTreeEditor_GraphNode_BehaviorTreeNode.tscn")
const GraphNode_Action = preload("GraphNode_Action.tscn")
const GraphNode_Concurrent = preload("GraphNode_Concurrent.tscn")
const GraphNode_PrioritySelector = preload("GraphNode_PrioritySelector.tscn")
const GraphNode_RandomSelector = preload("GraphNode_RandomSelector.tscn")
const GraphNode_Sequence = preload("GraphNode_SequenceSelector.tscn")
const GraphNode_Proxy = preload("GraphNode_Proxy.tscn")
const GraphNode_Condition = preload("GraphNode_Condition.tscn")
const GraphNode_ConditionDecorator = preload("GraphNode_ConditionDecorator.tscn")

var has_ready = false

func _ready():
	set_current_behavior_tree(null)
	if the_plugin:
		var editor_interface:EditorInterface = the_plugin.get_editor_interface()
		editor_selection = editor_interface.get_selection()
		editor_selection.connect("selection_changed", self, "_on_editor_selection_changed")


func _process(delta):
	if not has_ready:
		notification(NOTIFICATION_READY)
		has_ready = true

# ----------------- Custom Methods ------
func set_current_behavior_tree(n):
	clear_nodes()
	if n:
		graph_edit.visible = true
		warning_label.visible = false
		
		
		current_behavior_tree = n
		
		if not current_behavior_tree.behavior_tree_resource:
			# Add new resource
			var res = BehaviorTreeResource.new()
			current_behavior_tree.behavior_tree_resource = res
			refresh_inspetor()

		load_nodes_from_resource(current_behavior_tree.behavior_tree_resource)
	else:
		current_behavior_tree = null
		graph_edit.visible = false
		warning_label.visible = true

#func add_behavior_tree_node():
#	var n = GraphNode_BehaviorTreeNode.instance()
#	n.editor = self
#	n.resource = current_behavior_tree.behavior_tree_resource
#	n.resource_data = current_behavior_tree.behavior_tree_resource.create_node(BehaviorTreeResource.NodeType.NodeUndefined)
#	graph_edit.add_child(n)
#	n.offset = graph_edit.get_local_mouse_position() + graph_edit.scroll_offset
#	n.resource_data["position"] = n.offset
#	n.resource_data["g_name"] = n.name
#
#	refresh_inspetor()

func add_behavior_tree_node_action():
	var n = GraphNode_Action.instance()
	graph_edit.add_child(n)
	slap_data_into_node(n, BehaviorTreeResource.NodeType.NodeAction)
	refresh_inspetor()

func add_behavior_tree_node_concurrent():
	var n = GraphNode_Concurrent.instance()
	graph_edit.add_child(n)
	slap_data_into_node(n, BehaviorTreeResource.NodeType.NodeConcurrent)
	refresh_inspetor()

func add_behavior_tree_node_priority_selector():
	var n = GraphNode_PrioritySelector.instance()
	graph_edit.add_child(n)
	slap_data_into_node(n, BehaviorTreeResource.NodeType.NodePrioritySelector)
	refresh_inspetor()

func add_behavior_tree_node_random_selector():
	var n = GraphNode_RandomSelector.instance()
	graph_edit.add_child(n)
	slap_data_into_node(n, BehaviorTreeResource.NodeType.NodeRandomSelector)
	refresh_inspetor()

func add_behavior_tree_node_sequence():
	var n = GraphNode_Sequence.instance()
	graph_edit.add_child(n)
	slap_data_into_node(n, BehaviorTreeResource.NodeType.NodeSequenceSelector)
	refresh_inspetor()

func add_behavior_tree_node_proxy():
	var n = GraphNode_Proxy.instance()
	graph_edit.add_child(n)
	slap_data_into_node(n, BehaviorTreeResource.NodeType.NodeProxy)
	refresh_inspetor()

func add_behavior_tree_condition():
	var n = GraphNode_Condition.instance()
	graph_edit.add_child(n)
	slap_data_into_node(n, BehaviorTreeResource.NodeType.Condition)
	refresh_inspetor()

func add_behavior_tree_node_condition_decorator():
	var n = GraphNode_ConditionDecorator.instance()
	graph_edit.add_child(n)
	slap_data_into_node(n, BehaviorTreeResource.NodeType.ConditionDecorator)
	refresh_inspetor()

func slap_data_into_node(n, type):
	n.editor = self
	n.resource = current_behavior_tree.behavior_tree_resource
	n.resource_data = current_behavior_tree.behavior_tree_resource.create_node(type)
#	n.offset = graph_edit.get_local_mouse_position() + graph_edit.scroll_offset
	n.offset = empty_menu.get_global_rect().position - graph_edit.get_global_rect().position + graph_edit.scroll_offset
	n.resource_data["position"] = n.offset
	n.resource_data["g_name"] = n.name

func clear_nodes():
	graph_edit.clear_connections()
	for c in graph_edit.get_children():
		if c is GraphNode:
			graph_edit.remove_child(c)
			c.free()

func load_nodes_from_resource(res:BehaviorTreeResource):
	# first load nodes
	for r in res.nodes:
		var gn = null
		match r["type"]:
			BehaviorTreeResource.NodeType.NodeAction:
				gn = GraphNode_Action.instance()
			BehaviorTreeResource.NodeType.NodeConcurrent:
				gn = GraphNode_Concurrent.instance()
			BehaviorTreeResource.NodeType.NodePrioritySelector:
				gn = GraphNode_PrioritySelector.instance()
			BehaviorTreeResource.NodeType.NodeProxy:
				gn = GraphNode_Proxy.instance()
			BehaviorTreeResource.NodeType.NodeRandomSelector:
				gn = GraphNode_RandomSelector.instance()
			BehaviorTreeResource.NodeType.NodeSequenceSelector:
				gn = GraphNode_Sequence.instance()
			BehaviorTreeResource.NodeType.Condition:
				gn = GraphNode_Condition.instance()
			BehaviorTreeResource.NodeType.ConditionDecorator:
				gn = GraphNode_ConditionDecorator.instance()
			BehaviorTreeResource.NodeType.NodeUndefined:
#				gn = GraphNode_BehaviorTreeNode.instance()
				gn = null
		if not gn:
			printerr("Connot load node: ", r["typee"])
			continue
		gn.editor = self
		gn.resource = res
		gn.resource_data = r
		graph_edit.add_child(gn)
		gn.offset = r["position"]
		gn.name = r["g_name"]
		
		# load cutom data
		match r["type"]:
			BehaviorTreeResource.NodeType.NodeAction:
				gn.load_action_script(r["custom_script"])
			BehaviorTreeResource.NodeType.NodeConcurrent:
				pass
			BehaviorTreeResource.NodeType.NodePrioritySelector:
				pass
			BehaviorTreeResource.NodeType.NodeProxy:
				pass
			BehaviorTreeResource.NodeType.NodeRandomSelector:
				pass
			BehaviorTreeResource.NodeType.NodeSequenceSelector:
				pass
			BehaviorTreeResource.NodeType.Condition:
				gn.load_action_script(r["custom_script"])
			BehaviorTreeResource.NodeType.ConditionDecorator:
				pass
			BehaviorTreeResource.NodeType.NodeUndefined:
				pass
	
	# second load connections
	#{ from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }.
	for c in res.connections:
		graph_edit.connect_node(c["from"], c["from_port"], c["to"], c["to_port"])

func refresh_inspetor():
	var editor_interface:EditorInterface = the_plugin.get_editor_interface()
	editor_interface.get_inspector().refresh()

func update_connections_in_resource():
	current_behavior_tree.behavior_tree_resource.connections = graph_edit.get_connection_list().duplicate()
	refresh_inspetor()

func is_node_connect_to_other(node_name, slot):
	for c in graph_edit.get_connection_list():
		if c["from"] == node_name and c["from_port"] == slot:
			return true
	return false

func get_parent_through_connections(node_name):
	for c in graph_edit.get_connection_list():
		if c["to"] == node_name:
			return c["from"]
	return null

# ----------------- signals -------------
func _on_editor_selection_changed():
	var ns:Array = editor_selection.get_selected_nodes()
	if ns.size() > 0:
		if ns[0].has_method("BehaviorTree") :
			set_current_behavior_tree(ns[0])
	else:
		set_current_behavior_tree(null)
	



func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	if from == to:
		return
	
	var node = graph_edit.get_node_or_null(from)
	if node.has_method("BehaviorTreeEditorGraphNodeAction"):
		if from_slot == 0 and is_node_connect_to_other(from, from_slot):
			return
	
	if from_slot != 1 or (from_slot == 1 and not is_node_connect_to_other(from, from_slot) ):
		# to can't not be from's parent
		var is_to_is_from_parent = false
		var temp_from = from
		var p = get_parent_through_connections(from)
		while p:
			if p == to:
				is_to_is_from_parent = true
				break
			p = get_parent_through_connections(p)
		if is_to_is_from_parent:
			return
			
		graph_edit.connect_node(from, from_slot, to, to_slot)
		update_connections_in_resource()


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	graph_edit.disconnect_node(from, from_slot, to, to_slot)
	update_connections_in_resource()


func _on_GraphEdit_node_selected(node):
	node._on_selected()


func _on_GraphEdit_popup_request(position):
	empty_menu.set_global_position(position)
	empty_menu.popup()


func _on_CreateBehaviorTreeNodeButton_pressed():
#	add_behavior_tree_node()
	empty_menu.visible = false


func _on_CreateConditionNodeButton_pressed():
	add_behavior_tree_condition()
	empty_menu.visible = false



func _on_GraphEdit__end_node_move():
	pass # Replace with function body.


func _on_GraphEdit_delete_nodes_request():
	update_connections_in_resource()


func _on_CreateBehaviorTreeNodeActionButton_pressed():
	add_behavior_tree_node_action()
	empty_menu.visible = false


func _on_CreateBehaviorTreeNodeConcurrent_pressed():
	add_behavior_tree_node_concurrent()
	empty_menu.visible = false


func _on_CreateBehaviorTreeNodePrioritySelector_pressed():
	add_behavior_tree_node_priority_selector()
	empty_menu.visible = false


func _on_CreateBehaviorTreeNodeRandomSelector_pressed():
	add_behavior_tree_node_random_selector()
	empty_menu.visible = false


func _on_CreateBehaviorTreeNodeSequence_pressed():
	add_behavior_tree_node_sequence()
	empty_menu.visible = false


func _on_CreateBehaviorTreeNodeProxy_pressed():
	add_behavior_tree_node_proxy()
	empty_menu.visible = false


func _on_CreateConditionDecoratorNodeButton_pressed():
	add_behavior_tree_node_condition_decorator()
	empty_menu.visible = false

tool
extends EditorPlugin

var dock

var script_select_dialog

func _enter_tree():
	add_custom_type("BehaviorTree", "Node", preload("behavior_tree/BehaviorTree.gd"), preload("icon.png"))
	
	add_custom_type("BehaviorTreeCondition", "Node", preload("behavior_tree/BehaviorTreeCondition.gd"), preload("icon.png"))
	
	add_custom_type("BehaviorTreeNode", "Node", preload("behavior_tree/BehaviorTreeNode.gd"), preload("icon.png"))
	add_custom_type("BehaviorTreeNodeAction", "Node", preload("behavior_tree/BehaviorTreeNodeAction.gd"), preload("icon.png"))
	add_custom_type("BehaviorTreeNodeConcurrent", "Node", preload("behavior_tree/BehaviorTreeNodeConcurrent.gd"), preload("icon.png"))
	add_custom_type("BehaviorTreeNodePrioritySelector", "Node", preload("behavior_tree/BehaviorTreeNodePrioritySelector.gd"), preload("icon.png"))
	add_custom_type("BehaviorTreeNodeProxy", "Node", preload("behavior_tree/BehaviorTreeNodeProxy.gd"), preload("icon.png"))
	add_custom_type("BehaviorTreeNodeRandomSelector", "Node", preload("behavior_tree/BehaviorTreeNodeRandomSelector.gd"), preload("icon.png"))
	add_custom_type("BehaviorTreeNodeSequenceSelector", "Node", preload("behavior_tree/BehaviorTreeNodeSequenceSelector.gd"), preload("icon.png"))
	
	dock = preload("behavior_tree_editor/BehaviorTreeEditor.tscn").instance()
	add_control_to_bottom_panel(dock, "BehaviorTree Editor")
	dock.the_plugin = self
	
	script_select_dialog = preload("behavior_tree_editor/ScriptSelectDialog.tscn").instance()
	get_editor_interface().get_base_control().add_child(script_select_dialog)

func _exit_tree():
	remove_custom_type("BehaviorTree")
	
	remove_custom_type("BehaviorTreeCondition")
	
	remove_custom_type("BehaviorTreeNode")
	remove_custom_type("BehaviorTreeNodeAction")
	remove_custom_type("BehaviorTreeNodeConcurrent")
	remove_custom_type("BehaviorTreeNodePrioritySelector")
	remove_custom_type("BehaviorTreeNodeProxy")
	remove_custom_type("BehaviorTreeNodeRandomSelector")
	remove_custom_type("BehaviorTreeNodeSequenceSelector")
	
	remove_control_from_bottom_panel(dock)
	dock.free()
	
	get_editor_interface().get_base_control().remove_child(script_select_dialog)
	script_select_dialog.free()
	

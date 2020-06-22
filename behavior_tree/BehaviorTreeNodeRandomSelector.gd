extends "BehaviorTreeNodePrioritySelector.gd"

class_name BehaviorTreeNodeRandomSelector

func BehaviorTreeNodeRandomSelector():
	pass

func do_eval():
	if wait_for_delay():
		return true
	
	# if there is no child, then no need to tick
	if get_availible_child_count() == 0:
		clear()
		return false
	
	# Reselect child if current is bad
	if not selected_child or not selected_child.eval():
		while true:
			var child = get_child(randi()%get_child_count())
			if child.has_method("BehaviorTreeNode") and child.eval():
				selected_child = child
				return true
	
	# Keep current selected child
	return true;

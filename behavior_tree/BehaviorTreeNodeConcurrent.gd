
extends "BehaviorTreeNode.gd"

class_name BehaviorTreeNodeConcurrent

enum ConcurrentMode{
	AND, # all node are not running, finished
	OR # any node is not running, finished
}

enum ConditionMode{
	ALL,# fail when all children fail
	ANY# fail when any child fail
}

var running_children:Dictionary
export(ConcurrentMode) var concurrent_mode
export(ConditionMode) var condition_mode

func BehaviorTreeNodeConcurrent():
	pass

# override
func do_eval():
	var child = get_first_availible_child()
	while child:
		if not child.eval():
			if condition_mode == ConditionMode.ANY:
				return false
		else:
			if condition_mode == ConditionMode.ALL:
				return true
		child = get_next_availible_child(child)
	
	if condition_mode == ConditionMode.ANY:
		return true
	return false

# override
func tick():
	var child = get_first_availible_child()
	var finished_cnt = 0
	while child:
		if not running_children.has(child):
			running_children[child] = BTNResult.RUNNING
		match concurrent_mode:
			ConcurrentMode.AND:
				if running_children[child] == BTNResult.RUNNING:
					if child.eval():
						running_children[child] = child.tick()
					else:
						running_children[child] = BTNResult.FINISHED
				else:
					finished_cnt += 1
			ConcurrentMode.OR:
				if running_children[child] == BTNResult.RUNNING:
					if child.eval():
						running_children[child] = child.tick()
					else:
						running_children[child] = BTNResult.FINISHED
				else:
					running_children.clear()
					return BTNResult.FINISHED
		child = get_next_availible_child(child)
	if finished_cnt == get_availible_child_count():
		running_children.clear()
		return BTNResult.FINISHED
	
	return BTNResult.RUNNING

# override
func clear():
	running_children.clear()
	var child = get_first_availible_child()
	while child:
		child.clear()
		child = get_next_availible_child(child)

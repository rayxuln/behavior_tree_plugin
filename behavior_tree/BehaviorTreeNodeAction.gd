
extends "BehaviorTreeNode.gd"

class_name BehaviorTreeNodeAction

enum BTAState{
	READY,
	RUNNING
}

var state = BTAState.READY

func BehaviorTreeNodeAction():
	pass

# override
func enter():
	pass

# override
func exit():
	pass

# override
func execute():
	return BTNResult.RUNNING

func tick():
	var res = BTNResult.FINISHED
	if state == BTAState.READY:
		enter()
		state = BTAState.RUNNING
	if state == BTAState.RUNNING:
		debug_name_the_node_with_suffix("[running]")
		res = execute()
		if res != BTNResult.RUNNING:
			debug_name_the_node_with_suffix()
			exit()
			state = BTAState.READY
	return res

func debug_name_the_node_with_suffix(n=""):
	var bt = get_behavior_tree()
	if bt and bt.debug_mode:
		name = name.split("[")[0] + n

func clear():
	if state != BTAState.READY:
		debug_name_the_node_with_suffix()
		exit()
		state = BTAState.READY

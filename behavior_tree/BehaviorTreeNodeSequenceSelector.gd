
extends "BehaviorTreeNode.gd"

class_name BehaviorTreeNodeSequenceSelector

var selected_child

func BehaviorTreeNodeSequenceSelector():
	pass
	

func do_eval():
	if selected_child:
		var res = selected_child.eval()
		if not res:
			selected_child.clear()
			selected_child = null
		return res
	else:
		var c = get_first_availible_child()
		if c:
			return c.eval()


func tick():
	if not selected_child:
		selected_child = get_first_availible_child()
		if not selected_child:
			return BTNResult.FINISHED
	
	var res = selected_child.tick()
	if res == BTNResult.FINISHED:
		selected_child.clear()
		selected_child = get_next_availible_child(selected_child)
		if selected_child:
			res = BTNResult.RUNNING
	return res


func clear():
	if selected_child:
		selected_child = null
	
	var c = get_first_availible_child()
	while c:
		c.clear()
		c = get_next_availible_child(c)

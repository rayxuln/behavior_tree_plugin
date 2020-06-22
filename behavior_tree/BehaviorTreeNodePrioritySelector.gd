
extends "BehaviorTreeNode.gd"

class_name BehaviorTreeNodePrioritySelector

var selected_child

export(float) var min_select_delay = 0
export(float) var max_select_delay = 0

export(bool) var delay_on_start = false
var has_delay_done = false
var delay_timer = null
func _on_select_delay_done():
	has_delay_done = true
	delay_timer = null

func BehaviorTreeNodePrioritySelector():
	pass

func _ready():
	has_delay_done = not delay_on_start
	if delay_on_start:
		start_delay_timer()

func wait_for_delay():
	if not has_delay_done and delay_timer:
		return true
	has_delay_done = false
	return false

func get_random_select_delay():
	return rand_range(min_select_delay, max_select_delay)

func start_delay_timer():
	has_delay_done = false
	if not delay_timer:
		var t = get_random_select_delay()
		if t == 0:
			has_delay_done = true
			return
		delay_timer = get_tree().create_timer(t)
		delay_timer.connect("timeout", self, "_on_select_delay_done")

func do_eval():
	if wait_for_delay():
		return true

	for child in get_children():
		if child.has_method("BehaviorTreeNode") and child.eval():
			if selected_child and selected_child != child:
				selected_child.clear()
			selected_child = child
			return true
	
	clear()
	return false;

func tick():
	if not selected_child:
		return BTNResult.FINISHED
	
	var res = selected_child.tick()
	if res != BTNResult.RUNNING:
		clear()
	
	return res

func clear():
	start_delay_timer()
	if selected_child:
		selected_child.clear()
		selected_child = null

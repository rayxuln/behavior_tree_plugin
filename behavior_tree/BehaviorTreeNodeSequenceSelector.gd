
extends "BehaviorTreeNode.gd"

class_name BehaviorTreeNodeSequenceSelector

var selected_child

func BehaviorTreeNodeSequenceSelector():
	pass

export(float) var min_select_delay = 0
export(float) var max_select_delay = 0

export(bool) var delay_on_start = false
var has_delay_done = false
var delay_timer = null
func _on_select_delay_done():
	has_delay_done = true
	delay_timer = null

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
	if wait_for_delay():
		return BTNResult.RUNNING
	
	if not selected_child:
		selected_child = get_first_availible_child()
		if not selected_child:
			return BTNResult.FINISHED
	
	var res = selected_child.tick()
	if res == BTNResult.FINISHED:
		start_delay_timer()
		selected_child.clear()
		selected_child = get_next_availible_child(selected_child)
		if selected_child:
			res = BTNResult.RUNNING
	return res


func clear():
	if selected_child:
		selected_child = null
	
	has_delay_done = false
	delay_timer = null
	
	var c = get_first_availible_child()
	while c:
		c.clear()
		c = get_next_availible_child(c)

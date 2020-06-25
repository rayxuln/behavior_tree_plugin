tool
extends "BehaviorTreeCondition.gd"

class_name BehaviorTreeConditionDecorator

enum Mode{
	AND,
	OR,
}

export(Array, NodePath) var conditions_path:Array setget _on_conditions_path_set, _on_conditions_path_get
func _on_conditions_path_set(v):
	conditions_path = v
	valid_conditions()
func _on_conditions_path_get():
	return conditions_path
var conditions:Array
func valid_conditions():
	conditions.clear()
	for cp in conditions_path:
		var n = get_node_or_null(cp)
		if n and n.has_method("BehaviorTreeCondition"):
			conditions.append(n)

export(Mode) var mode = Mode.OR
export(bool) var flip = false

func _ready():
	valid_conditions()

func BehaviorTreeConditionDecorator():
	pass

# override
func check(btn):
	if conditions.size() == 0:
		return true
	var res = false
	var has_set_res = false
	for c in conditions:
		if not has_set_res:
			has_set_res = true
			res = c.check(btn)
		match mode:
			Mode.AND:
				res = res and c.check(btn)
			Mode.OR:
				res = res or c.check(btn)
	if flip:
		res = not res
	return res

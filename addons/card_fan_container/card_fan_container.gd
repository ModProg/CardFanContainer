tool
extends Container

#export (float, 0, 1) var root: float
#export (float, 0, 1) var progress: float
#export(float, 0, 180) var min_angle: float;
#export(float, 0, 90) var max_angle: float;
export (float, 0, 90) var max_angle: float = 45 setget _set_max_angle
export (float, 0.01, 1) var bow_spacing: float = .2 setget _set_bow_spacing
export (float, 0, .49) var padding: float = .1 setget _set_padding
export var child_size: Vector2 = Vector2(50, 50) setget _set_child_size
enum ORDER { LTR, RTL }
#export (ORDER) var order


func _set_max_angle(value: float):
	max_angle = value
	_resort()


func _set_bow_spacing(value: float):
	bow_spacing = value
	_resort()


func _set_padding(value: float):
	padding = value
	_resort()


func _set_child_size(value: Vector2):
	child_size = value
	_resort()


func _ready():
	connect("sort_children", self, "_resort")
	_resort()


func _resort():
	var rect = get_rect()

	var children = _get_filtered_children()

	if children.size() == 0:
		return

	var bow_width = rect.size.x * (.5 - padding) * 2
	var bow_height = bow_spacing * rect.size.y
	print(bow_width, " ", bow_height)
	var radius = (4 * pow(bow_height, 2) + pow(bow_width, 2)) / (8 * bow_height)
	var max_total_angle = 2 * asin(bow_width / (2 * radius))
	#print((4*pow(bow_height,2)+pow(bow_width,2)))
	var root = Vector2(rect.size.x / 2, rect.size.y - bow_height + radius)
	var pad_point = Vector2(rect.size.x * padding, rect.size.y)
	#var radius = pad_point.distance_to(root)
	print(pad_point, root, radius)

	var wanted_angle = atan((child_size.x / 2) / radius) * 2
	var angle = min(wanted_angle, deg2rad(max_angle))
	print(angle, "<=", max_angle)
	var total_angle = min((children.size() - 1) * angle, max_total_angle - wanted_angle)
	angle = total_angle / (children.size() - 1)
	var current_angle = -total_angle / 2
	for child in children:
		_put_child_at_angle(child, radius, root, current_angle)
		current_angle += angle


#	var start_pos = Vector2(-(spacing / 2) - (spacing * ((float(array.size()) / 2) - 1)), 0)
#	var cards = []
#	var i = 0
#	for _card in array:
#		var c = _card.instance()
#		var x = start_pos.x + (spacing * i)
#		var y = vert_shrink * pow(x,2)
#		add_child(c)
#		cards.append(c)
#		c.scale = Vector2(0.5,0.5)
#		tween("position", c, c.get_position(), Vector2(x, y), animTime)
#		i += 1
#	var start_rot = -(IH_CARD_ROT / 2) - (IH_CARD_ROT * ((float(array.size()) / 2) - 1))
#	i = 0
#	for c in cards:
#		tween("rotation_degrees", c, rad2deg(c.rotation), start_rot + IH_CARD_ROT * i, animTime)
#		i += 1


func _put_child_at_angle(child: Control, radius, origin, angle):
	child.set_size(child_size)
	child.set_rotation(angle)
	child.rect_pivot_offset = Vector2(child_size.x / 2, child_size.y)

	var target = Vector2(0, -radius).rotated(angle) + origin - child.rect_pivot_offset
	child.set_position(target)


func _get_filtered_children():
	var children = get_children()
	var i = children.size()
	while i > 0:
		i -= 1
		var keep = false
		if children[i] is Control:
			keep = true

		if children[i] is CanvasItem and children[i].visible == false:
			keep = false

		if ! keep:
			children.remove(i)
	return children


func _get_child_min_size(child):
	if child is Control:
		var size = child.get_combined_minimum_size()
		return size
	else:
		return Vector2(0, 0)

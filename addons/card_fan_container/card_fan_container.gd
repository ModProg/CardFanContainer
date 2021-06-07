extends Container

export (float, 0, 1) var root: float
export (float, 0, 1) var progress: float
#export(float, 0, 180) var min_angle: float;
#export(float, 0, 90) var max_angle: float;
export (float, 0, 90) var max_angle: float = 45;
export (float, 0, 100) var circle_center_offset: float
export (float, 0, 1) var padding: float
export var child_size: Vector2
enum ORDER { LTR, RTL }
export (ORDER) var order


func _ready():
	connect("sort_children", self, "_resort")
	_resort()


func _resort():
	var rect = get_rect()

	var children = _get_filtered_children()

	if children.size() == 0:
		return

	var root = Vector2(rect.size.x / 2, rect.size.y + circle_center_offset)
	var radius = Vector2(rect.size.y, rect.size.x * padding).distance_to(root)
	
	var angle = min(atan(child_size.x/2/radius)*2, deg2rad(max_angle))

	var total_angle = (children.size()-1) * angle;
	var current_angle = -total_angle/2
	for child in children:
		_put_child_at_angle(child,radius,root,current_angle)
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
	var target = Vector2(0,-radius).rotated(angle) + origin
	
	
	child.set_size(child_size)
	child.set_rotation(angle)
	child.rect_pivot_offset = Vector2(child_size.x/2,child_size.y)
	
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

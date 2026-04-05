extends Node3D
## main.gd — builds the entire prototype world programmatically.
## Attach to the root Node3D in scenes/main.tscn.
##
## Layout (top-down, Z negative = "south", i.e. in front of the house):
##
##        ┌──────────────────────────────┐
##        │  House (8 m × 6 m × 3 m)    │
##        │                              │
##        │   [door opening at center]   │
##        └──────────┤    ├──────────────┘
##                   │    │  front face z = −3
##                 sidewalk (z −3 to −7)
##                   ↑
##             player start (z ≈ −8)
##
## All distances are in metres.

# ── Colours ────────────────────────────────────────────────────────────────
const C_GRASS    := Color(0.22, 0.55, 0.18)   # ground / lawn
const C_SIDEWALK := Color(0.75, 0.75, 0.72)   # concrete
const C_WALLS    := Color(0.90, 0.87, 0.78)   # cream / plaster
const C_FLOOR    := Color(0.60, 0.45, 0.30)   # light wood
const C_ROOF     := Color(0.48, 0.45, 0.42)   # dark slate
const C_DOOR     := Color(0.55, 0.35, 0.15)   # warm wood

# ── Player scene ───────────────────────────────────────────────────────────
const PLAYER_SCENE := preload("res://scenes/player.tscn")


func _ready() -> void:
	_setup_environment()
	_setup_sun()
	_build_ground()
	_build_sidewalk()
	_build_house()
	_spawn_player()


# ── Environment ─────────────────────────────────────────────────────────────

func _setup_environment() -> void:
	var env_node := WorldEnvironment.new()
	add_child(env_node)
	var env := Environment.new()
	# Simple solid sky colour — no sky material needed for a prototype
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.38, 0.62, 0.90)   # pale blue sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color  = Color(0.65, 0.65, 0.75)
	env.ambient_light_energy = 0.6
	env_node.environment = env


func _setup_sun() -> void:
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-50.0, -30.0, 0.0)  # afternoon angle
	sun.light_energy      = 1.4
	sun.shadow_enabled    = true


# ── Ground & sidewalk ────────────────────────────────────────────────────────

func _build_ground() -> void:
	# A large flat lawn that the house sits on
	_make_box(
		Vector3(40.0, 0.20, 40.0),   # size
		Vector3(0.0, -0.10, 0.0),    # position (top surface at y = 0)
		C_GRASS,
		"Ground"
	)


func _build_sidewalk() -> void:
	# A short concrete path leading from outside to the front door
	_make_box(
		Vector3(1.50, 0.05, 5.0),    # 1.5 m wide, 5 m long
		Vector3(0.0, 0.025, -5.5),   # centred in front of door (z −3 to −8)
		C_SIDEWALK,
		"Sidewalk"
	)


# ── House ────────────────────────────────────────────────────────────────────
#
# Exterior envelope:   8 m wide (X)  ×  6 m deep (Z)  ×  3 m tall (Y)
# Wall thickness:      0.3 m
# Door opening:        1.0 m wide  ×  2.2 m tall, centred on front face
# House centre at world origin (0, 0, 0) — front face at z = −3.

func _build_house() -> void:
	var house := Node3D.new()
	add_child(house)
	house.name = "House"

	# ── Floor (interior surface at y = 0) ──────────────────────────────────
	_make_box_child(house,
		Vector3(8.0, 0.10, 6.0),
		Vector3(0.0, -0.05, 0.0),
		C_FLOOR, "Floor"
	)

	# ── Ceiling / Roof (with a small overhang) ──────────────────────────────
	_make_box_child(house,
		Vector3(8.60, 0.20, 6.60),
		Vector3(0.0, 3.10, 0.0),
		C_ROOF, "Roof"
	)

	# ── Back wall ──────────────────────────────────────────────────────────
	_make_box_child(house,
		Vector3(8.0, 3.0, 0.3),
		Vector3(0.0, 1.5, 3.15),
		C_WALLS, "WallBack"
	)

	# ── Left wall (includes corner thickness) ──────────────────────────────
	_make_box_child(house,
		Vector3(0.3, 3.0, 6.6),
		Vector3(-4.15, 1.5, 0.0),
		C_WALLS, "WallLeft"
	)

	# ── Right wall ─────────────────────────────────────────────────────────
	_make_box_child(house,
		Vector3(0.3, 3.0, 6.6),
		Vector3(4.15, 1.5, 0.0),
		C_WALLS, "WallRight"
	)

	# ── Front wall — left piece (x: −4 to −0.5) ──────────────────────────
	# Width = 4 − 0.5 = 3.5 m,  centre x = (−4 + −0.5) / 2 = −2.25
	_make_box_child(house,
		Vector3(3.5, 3.0, 0.3),
		Vector3(-2.25, 1.5, -3.15),
		C_WALLS, "WallFrontLeft"
	)

	# ── Front wall — right piece (x: 0.5 to 4) ──────────────────────────
	_make_box_child(house,
		Vector3(3.5, 3.0, 0.3),
		Vector3(2.25, 1.5, -3.15),
		C_WALLS, "WallFrontRight"
	)

	# ── Lintel (above the door opening, y: 2.2 to 3.0) ──────────────────
	# Height = 3.0 − 2.2 = 0.8 m,  centre y = 2.6
	_make_box_child(house,
		Vector3(1.0, 0.8, 0.3),
		Vector3(0.0, 2.6, -3.15),
		C_WALLS, "WallLintel"
	)

	# ── Door ──────────────────────────────────────────────────────────────
	# Hinge on the left edge of the opening: x = −0.5, z = −3.05
	_build_door(house, Vector3(-0.5, 0.0, -3.05))


# ── Door helper ──────────────────────────────────────────────────────────────

func _build_door(parent: Node3D, hinge_pos: Vector3) -> void:
	# DoorPivot rotates; DoorBody is the collider that receives "interact" calls
	var pivot := Node3D.new()
	parent.add_child(pivot)
	pivot.name     = "DoorPivot"
	pivot.position = hinge_pos

	var body := StaticBody3D.new()
	body.name = "DoorBody"
	body.set_script(load("res://scripts/door.gd"))

	# Mesh — offset so the door's left edge sits at the pivot (hinge)
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.position = Vector3(0.5, 1.1, 0.0)  # half-width right, half-height up
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.0, 2.2, 0.1)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = C_DOOR
	mesh_inst.material_override = mat
	mesh_inst.mesh = mesh
	body.add_child(mesh_inst)

	# Collision shape — same offset as the mesh
	var col := CollisionShape3D.new()
	col.position = Vector3(0.5, 1.1, 0.0)
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.0, 2.2, 0.1)
	col.shape = shape
	body.add_child(col)

	pivot.add_child(body)


# ── Player ───────────────────────────────────────────────────────────────────

func _spawn_player() -> void:
	var player := PLAYER_SCENE.instantiate()
	add_child(player)
	player.name = "Player"
	# Start a comfortable distance outside the front door, facing the house
	player.position = Vector3(0.0, 1.0, -8.0)


# ── Utility: create a box as a direct child of this scene's root ─────────────

func _make_box(size: Vector3, pos: Vector3, color: Color, node_name: String) -> StaticBody3D:
	return _make_box_child(self, size, pos, color, node_name)


# ── Utility: create a box as a child of any given parent ─────────────────────

func _make_box_child(
	parent  : Node3D,
	size    : Vector3,
	pos     : Vector3,
	color   : Color,
	node_name : String
) -> StaticBody3D:
	var body := StaticBody3D.new()
	parent.add_child(body)
	body.name     = node_name
	body.position = pos

	# Mesh
	var mesh_inst := MeshInstance3D.new()
	body.add_child(mesh_inst)
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_inst.material_override = mat
	mesh_inst.mesh = mesh

	# Collision
	var col := CollisionShape3D.new()
	body.add_child(col)
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape

	return body

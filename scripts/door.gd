extends StaticBody3D
## door.gd — simple toggling door
## Attach to the "DoorBody" StaticBody3D (child of the "DoorPivot" Node3D).
##
## Scene hierarchy expected:
##   DoorPivot  (Node3D)  ← pivot sits at the hinge edge of the door
##     DoorBody (StaticBody3D, this script)
##       MeshInstance3D   ← box mesh offset so its left edge is at the pivot
##       CollisionShape3D

# ── Tuning ─────────────────────────────────────────────────────────────────
@export var open_angle_deg : float = 90.0  # how far the door swings open
@export var swing_speed    : float = 4.0   # lerp speed (higher = snappier)

# ── State ──────────────────────────────────────────────────────────────────
var _is_open    : bool  = false
var _target_y   : float = 0.0  # current rotation target for the pivot


## Called by the player's interaction system (player.gd → _try_interact).
func interact() -> void:
	_is_open = not _is_open
	# When open, rotate the pivot by open_angle_deg; closed = back to 0
	_target_y = deg_to_rad(open_angle_deg) if _is_open else 0.0


func _process(delta: float) -> void:
	# Smoothly rotate the DoorPivot parent towards the target angle
	var pivot := get_parent()  # the DoorPivot Node3D
	pivot.rotation.y = lerp_angle(pivot.rotation.y, _target_y, swing_speed * delta)

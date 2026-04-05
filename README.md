# pow — First-Person Life Sim Prototype

A beginner-friendly, first-person Sims-like prototype built with **Godot 4**.
This is Phase 1: the smallest playable version — movement, a house, and a door.

---

## What's in the prototype

| Feature | Status |
|---|---|
| First-person movement (WASD) | ✅ |
| Mouse look (pitch + yaw) | ✅ |
| Jumping (Space) | ✅ |
| Collision | ✅ |
| Ground plane (grass) | ✅ |
| Sidewalk leading to the door | ✅ |
| House — floor, 4 walls, roof, doorway | ✅ |
| Interactable door (press E to open/close) | ✅ |
| Basic lighting + sky colour | ✅ |

---

## Requirements

| Tool | Version |
|---|---|
| [Godot Engine](https://godotengine.org/download) | **4.3** (or any 4.x release) |

No plugins or addons needed.

---

## Project structure

```
pow/
├── project.godot          ← Godot project config (input maps live here)
├── icon.svg               ← project icon
│
├── scenes/
│   ├── main.tscn          ← run this scene (F5)
│   └── player.tscn        ← first-person character body
│
└── scripts/
    ├── main.gd            ← builds the world (ground, house, lighting, player)
    ├── player.gd          ← WASD movement, mouse look, jump, E-to-interact
    └── door.gd            ← door open/close with smooth pivot rotation
```

---

## Setup (step by step)

1. **Download and install Godot 4** from <https://godotengine.org/download>.
2. **Clone or download this repo** into any local folder.
3. **Open Godot** → click **Import** → navigate to the repo folder → select
   `project.godot` → click **Import & Edit**.
4. In the **FileSystem** panel, open `scenes/main.tscn` (double-click).
5. Press **F5** (or the ▶ button) to run the project.

---

## Controls

| Key | Action |
|---|---|
| **W A S D** | Walk forward / left / backward / right |
| **Mouse** | Look around |
| **Space** | Jump |
| **E** | Interact (open / close the door) |
| **Escape** | Release / recapture mouse |

---

## How the house is laid out

```
Top view (not to scale)

  ┌───────────────────────────────────────┐
  │           House interior              │  ← 8 m wide × 6 m deep
  │                                       │
  │                                       │
  └─────────────┤ door ├─────────────────┘
                     ↑
               sidewalk (z −3 → −8)
                     ↑
             player start (z ≈ −8, facing house)
```

- House centre is at world origin `(0, 0, 0)`
- Front face (with door) is at `z = −3`
- Door opening is 1 m wide × 2.2 m tall, centred on the front wall
- Door hinge is on the left side of the opening
- Player is spawned 5 m outside the front door, facing the house

---

## Testing checklist

After pressing F5:

- [ ] You appear outside the house facing the front door
- [ ] Mouse moves the camera smoothly (no cursor visible)
- [ ] WASD moves the character in the correct directions
- [ ] Pressing Space makes the character jump
- [ ] Walking into the house walls stops you (collision works)
- [ ] Walking through the doorway puts you inside the house
- [ ] Looking at the door and pressing **E** opens it
- [ ] Pressing **E** again closes it
- [ ] Pressing **Escape** shows/hides the OS cursor

---

## Roadmap — next 10 prototype steps

After this phase is working, here is the recommended order for further development:

1. **Step 2 — Interaction label UI**: show "Press E" when looking at the door
2. **Step 3 — Interior objects**: a bed, table, and chair as placeholder boxes
3. **Step 4 — Simple usable objects**: sit, sleep, eat — just a text-log for now
4. **Step 5 — Day/night cycle**: rotate the sun over time, change sky colour
5. **Step 6 — Needs bars**: hunger, energy — displayed as simple progress bars
6. **Step 7 — Outdoor environment**: add trees (cylinders + spheres), a road, a fence
7. **Step 8 — Multiple rooms**: add interior walls to divide the house into rooms
8. **Step 9 — Sound effects**: footstep sounds, door creak using AudioStreamPlayer3D
9. **Step 10 — Saving/loading**: persist player position and object states
10. **Step 11 — NPC placeholder**: a capsule that path-finds around the house

---

## Keeping the code simple

- All world geometry is built in **`scripts/main.gd`** — edit constants at the top
  to resize the house, ground, or sidewalk.
- The player's speed, jump height, and mouse sensitivity are constants at the top
  of **`scripts/player.gd`**.
- The door's swing angle and speed are `@export` variables on the door scene node,
  editable directly in the Godot Inspector.

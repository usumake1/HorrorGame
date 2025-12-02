# Horror Hide and Seek

A first-person horror hide-and-seek game built with Godot 4.4.1.

## Description

Navigate through a dark house while avoiding a patrolling enemy. Use hiding spots strategically to avoid detection and survive!

## Features

- **First-Person Controller**: Smooth mouse look and WASD movement
- **Sprint System**: Sprint with a stamina system that drains and regenerates
- **Flashlight**: Toggle flashlight to see in the dark (but be careful - it might give away your position!)
- **Intelligent Enemy AI**:
  - Patrols between waypoints
  - Chases player when spotted
  - Searches last known location when losing sight
  - Vision-based detection (range, angle, and line-of-sight)
- **Hiding Mechanics**: Enter closets to hide from the enemy and become invisible
- **House Environment**: Multi-room house layout with walls and doorways

## Controls

| Key | Action |
|-----|--------|
| **W** | Move Forward |
| **A** | Move Left |
| **S** | Move Backward |
| **D** | Move Right |
| **Mouse** | Look Around |
| **Shift** | Sprint (uses stamina) |
| **F** | Toggle Flashlight |
| **E** | Hide/Exit Hiding Spot |
| **ESC** | Release Mouse Cursor |

## How to Play

1. Open the project in Godot 4.4.1
2. Press F5 or click the Play button to start
3. Navigate through the house and avoid the enemy
4. Use hiding spots (closets) when the enemy gets close
5. Manage your stamina carefully when sprinting
6. Try to survive as long as possible!

## Project Structure

```
HorrorGame/
├── scenes/
│   ├── main.tscn          # Main level scene
│   ├── player.tscn        # Player character
│   ├── enemy.tscn         # Enemy AI
│   └── hiding_spot.tscn   # Hiding spot (closet)
├── scripts/
│   ├── player.gd          # Player controller
│   ├── enemy.gd           # Enemy AI logic
│   └── hiding_spot.gd     # Hiding spot interaction
├── project.godot          # Godot project configuration
└── README.md              # This file
```

## Technical Details

### Player Controller
- Mouse sensitivity: 0.002
- Walk speed: 5.0 m/s
- Sprint speed: 8.0 m/s
- Max stamina: 100
- Stamina drain rate: 20/second
- Stamina regen rate: 15/second

### Enemy AI
- Patrol speed: 2.0 m/s
- Chase speed: 5.0 m/s
- Vision range: 15.0 meters
- Vision angle: 60 degrees (cone)
- Search duration: 5 seconds

### Game Mechanics
- Enemy cannot detect player while hiding in closets
- Line-of-sight checking prevents detection through walls
- Flashlight automatically turns off when hiding

## Requirements

- Godot 4.4.1 or later
- Windows, macOS, or Linux

## Credits

Created as a horror game prototype demonstrating AI behavior, player stealth mechanics, and environmental interaction.

## License

This project is open source and available for educational purposes.

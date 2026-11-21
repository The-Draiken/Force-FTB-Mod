# Force Turn-Based Hotkey – Keyboard & Controller

A Baldur's Gate 3 mod that toggles **Force Turn-Based (FTB) mode for your whole party** with one button press, on keyboard **or** controller.

I Originnaly made it because I play on controller (a PS5 DualSense Edge) and wanted to enter turn-based mode on a single button without always going into that submenu and manualluy selecting it, ideally a back paddle. I also made it fully work on keyboard.

## Features

- **Party-wide toggle.** One press puts every active party member into Force Turn-Based mode. Press again and everyone leaves it.
- **Smart toggle.** The mod checks the character you're controlling: if they're in FTB, it exits for the party; if not, it enters for the party. Your party never ends up half in, half out.
- **Keyboard support.** The default is `Left Shift + Space`, and you can rebind it to any key + modifier.
- **Controller support.** The default is `R3` (Right Stick click). You can bind it to:
  - A / B / X / Y
  - D-Pad Up / Down / Left / Right
  - Left / Right Shoulder
  - Left / Right Trigger
  - Left / Right Stick click
  - Back, Start, Touchpad
- **Two-button combos (optional).** Set a second controller button so the toggle only fires when both are held together. This keeps the toggle from triggering by accident.
- **Override option.** Stop the bound button's normal in-game action, so it does *only* the toggle.
- **Paddle friendly.** Controllers with remappable back buttons (DualSense Edge, Xbox Elite, etc.) can map a paddle to the bound button, giving you a dedicated turn-based paddle.

## Requirements

- [BG3 Script Extender](https://github.com/Norbyte/bg3se) (v25 or newer)
- *(Optional)* [Mod Configuration Menu (MCM)](https://www.nexusmods.com/baldursgate3/mods/9162). Without it, the mod still works with the default bindings.

## Installation

1. Install the BG3 Script Extender.
2. *(Optional)* Install Mod Configuration Menu.
3. Install this mod with BG3 Mod Manager (or your mod manager of choice) and enable it in your load order.

## Configuration (MCM)

Open MCM in-game and find **Force_FTB**.

**Keybindings tab**
| Setting | Default | Description |
|---|---|---|
| Pause Toggle Hotkey | `Left Shift + Space` | Enter/exit Force Turn-Based mode. |

**Controller tab**
| Setting | Default | Description |
|---|---|---|
| Pause Toggle Hotkey | `RightStick` (R3) | Main controller button. |
| Pause Toggle Hotkey 2 (Optional) | *(blank)* | If set, both buttons must be pressed together. |
| Override | Off | If on, the bound button's normal action is blocked. |

Changes take effect as soon as you save them in MCM. No reload is needed.

## Tips

- **DualSense Edge / Elite users:** Bind the toggle to a button you rarely use (e.g. `RightStick`), map a back paddle to that button in your controller profile, and turn on **Override** if needed.
- If a button does something you still need, use a **two-button combo** (e.g. `LeftShoulder` + `RightStick`) instead of Override.

## Compatibility

- Uses Script Extender events and the game's built-in Force Turn-Based function. It doesn't edit game data files, so it should work with most other mods.
- Safe to add mid-playthrough.

## Reports
Need Help, want to report a Bug or just comment somthing about this Mod. You can do so here: https://rpghq.org/forums/viewtopic.php?p=434214-force-ftb-mode-1-0-baldur-s-gate-3 

(Be aware of how the site is though if you venture out of the thread for my Mod, people on the site are very unhinged)
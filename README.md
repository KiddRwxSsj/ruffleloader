<p align="center">
  <img src="sce_sys/icon0.png" alt="RuffleLoader Logo" width="128"/>
</p>

<h1 align="center">RuffleLoader</h1>

<p align="center">
  Flash game launcher and custom input mapper for Ruffle on PS Vita.
</p>

---

RuffleLoader is a lightweight terminal-based GUI for the PS Vita. It automates the process of loading `.swf` files into the Ruffle emulator and allows users to create persistent, per-game control mappings using the console's physical buttons.

## AI Assistance

Parts of the code were written or improved with the help of an AI assistant. The core logic, file management structure, and debugging process were human-led.

## Features

- **File Browser**: Navigate your `ux0:data/FlashGames/` directory to easily find and select `.swf` files.
- **Custom Input Mapping**: Map the Vita's physical buttons (Triangle, Square, Cross, Circle) to standard keyboard keys required by Flash games.
- **Persistent Profiles**: Control mappings are automatically saved on a per-game basis and loaded instantly on subsequent launches.
- **Quick Launch**: Bypass the configuration screen and boot directly into a game using your saved profile.
- **Native Execution**: Prepares the Ruffle environment and seamlessly hands off execution using ONElua's native `game.launch()` API.

## Requirements

Before using RuffleLoader, you must have the following installed on your PS Vita:

- A modded PS Vita (HENkaku/Enso).
- [Ruffle Flash Player Vita](https://github.com/ruffle-rs/ruffle) (The emulator itself).
- Games must be placed in `ux0:data/FlashGames/`.

## Usage

### Download

Head to the [Releases](../../releases) section and download the latest `.vpk` file.
Install it using VitaShell.

### Build from source

If you want to compile the `.vpk` yourself, you will need the ONEmaker tool (or similar packager) and the files in this repository.

1. Clone the repository:
```bash
git clone https://github.com/KiddRwxSsj/RuffleLoader.git
```
2. Place the repository contents into the `homebrew` folder of ONEmaker.
3. Run ONEmaker and compile using the App ID `RUFFLELDR`.
*Note: Make sure not to compress the output ZIP file to avoid the `0x8010113D` installation error.*

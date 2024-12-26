# Saturn

![Saturn Banner](https://example.com/banner.png) <!-- Replace with actual banner image URL -->

## Table of Contents

- [About](#about)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## About

**Saturn** is a comprehensive quality-of-life mod for the deck-building rogue-lite game [Balatro](https://example.com/balatro). Designed to enhance your gaming experience, Saturn introduces a suite of features that streamline gameplay, improve user interface interactions, and provide deeper insights into your game statistics.

## Features

- **Animation Control**
  - Speed up animations to maintain game flow.
  - Skip animations entirely for a more streamlined experience.
  
- **Consumable Management**
  - Stack consumable cards to reduce clutter and manage resources efficiently.
  
- **Enhanced Deck Viewer**
  - Improved performance for deck viewing.
  - Add filters to easily find specific cards.
  
- **Stat Tracking**
  - Monitor global stats for cards and overall game performance.
  - Dedicated stats pages for jokers, consumables, general statistics, and more.
  
- **Settings UI Overhaul**
  - Aesthetic and readability improvements.
  - Modular settings functions for easier customization.
  
- **Additional Quality Enhancements**
  - Sticky Joker Counters.
  - Mass Use buttons for consumables.
  - Retry buttons in challenges.
  - And much more!

## Installation

### Prerequisites

- **Balatro** game installed.
- [**Steamodded**](https://github.com/Steamopollys/Steamodded/) framework installed and properly configured for managing mods. Download the latest release from the [releases](https://github.com/Steamopollys/Steamodded/releases) page.
- [**Lovely-injector**](https://github.com/ethangreen-dev/lovely-injector) runtime Lua injector framework. Download the latest release from the [releases](https://github.com/ethangreen-dev/lovely-injector/releases) page.

### Steps

1. **Create a Mod directory within your Balatro %appdata% directory:**
   - Navigate to your Balatro %appdata% directory (`%appdata%/Balatro`) and create a new folder named `Mods` (if it doesn't already exist).

   ```bash
   cd %appdata%/Balatro
   mkdir Mods
   ```

2. **Create a Steamodded directory within your Mods directory:**
   - In this Mods directory and create a new folder named `Steamodded`.
   
   ```bash
   mkdir Steamodded
   ```

3. **Extract the contents of the Steamodded release into your Steamodded directory:**
   - In this Steamodded directory, extract the contents of the Steamodded release into it (downloaded from the prerequisites section). Be sure you are extracting the contents of the Steamodded-main folder, and not the entire zip file or the Steamodded folder itself.

4. **Optional** Add `version.dll` from Lovely-injector to your antivirus's exclusion list.
   - This may be necessary to prevent your antivirus from deleting the Lovely-injector files or flagging them as a false positive. If you are encountering issues with the mod, this may be the cause.

5. **Add version.dll to Balatro's Steamodded directory:**
   - Navigate to your Balatro Steam install directory (`../SteamLibrary/steamapps/common/Balatro/`) and copy the `version.dll` file from the Lovely-injector release into the Steamodded directory. You can find this directory also by clicking `Manage -> Browse Local Files` in Steam.

6. **Download the latest release of Saturn:**
   - Navigate to the [releases](https://github.com/Steamopollys/Saturn/releases) page and download the latest release of Saturn.


7. **Extract the contents of the Saturn release into your %appdata%/Balatro/Mods/Steamodded directory:**
   - Unzip the contents of the Saturn release into the Steamodded directory. Be sure you are extracting the entire folder, and not the zip file itself or the contents within the Saturn release folder.

8. **Launch Balatro:**
   - Launch Balatro from Steam. You should now see the Saturn mod in the Mods section of the game menu.

## Configuration

Saturn comes with a set of configurable options to tailor the mod to your preferences.

1. **Accessing Settings:**
   - In-game, navigate to the **Settings** menu.
   - Click on the **Saturn** tab to access all configuration options.

2. **Available Settings:**

   - **Animation Settings:**
     - **Game Speed:** Adds 8x and 16x speed options to the game.
     - **Remove animations:** Remove game animations to speed up the gameplay drastically.
     - **Enable dramatic final hand:** Gives you time to shuffle jokers during the final hand.
     
   - **Consumable Settings:**
     - **Stacking:** Enable or disable stacking of consumable cards. You will be able to split one or split half of the stack of cards. This reduces UI lag and clutter.
     
   - **Deck Viewer:**
     - **Hide played cards:** Hides played cards in the deck viewer.
     - **Performance:** Toggle performance enhancements for smoother deck management.
     
   - **Stat Tracker:**
     - **Global Stats:** Enable tracking of global game statistics.
     - **Category Selection:** Choose specific stat categories like jokers, consumables, and general stats.
     
   - **Additional Features:**
     - Enable or disable features such as Sticky Joker Counters, Mass Use buttons, Retry buttons, and more.


## Contributing

Contributions are welcome! If you'd like to improve Saturn or add new features, follow these steps:

1. **Fork the Repository:**
   - Click the **Fork** button at the top-right corner of the [GitHub repository](https://github.com/yourusername/saturn).

2. **Clone Your Fork:**
   
   ```bash
   git clone https://github.com/yourusername/saturn.git
   ```

3. **Create a New Branch:**
   
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make Your Changes:**
   - Implement your feature or fix bugs.

5. **Commit Your Changes:**
   
   ```bash
   git commit -m "Add feature description"
   ```

6. **Push to Your Fork:**
   
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request:**
   - Go to the original repository and create a pull request detailing your changes.

## Contact

For support, feature requests, or any inquiries, please open an issue on the [GitHub Issues](https://github.com/yourusername/saturn/issues) page.
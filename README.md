# Saturn

## Table of Contents

- [About](#about)
- [Features](#features)
- [Installation](#installation)
  - [For New Users](#for-new-users)
  - [If You Already Have Steamodded Installed](#if-you-already-have-steamodded-installed)
  - [If You Already Have Lovely-injector Installed](#if-you-already-have-lovely-injector-installed)
  - [If You Already Have Both Steamodded and Lovely-injector Installed](#if-you-already-have-both-steamodded-and-lovely-injector-installed)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [Contact](#contact)

## About

**Saturn** is a comprehensive quality-of-life mod for the deck-building rogue-lite game [Balatro](https://example.com/balatro). Designed to enhance your gaming experience, Saturn introduces a suite of features that streamline gameplay, improve user interface interactions, and provide deeper insights into your game statistics.

## Features

- **Animation Control**
  - **Game Speed:** Adjust the game speed with options like 8x and 16x to suit your playstyle.
  - **Remove Animations:** Eliminate in-game animations for a faster and more streamlined experience.
  - **Enable Dramatic Final Hand:** Allows time to shuffle jokers during the final hand, adding strategic depth.

- **Consumable Management**
  - **Stacking:** Enable or disable the stacking of consumable cards. Options to split one or half of the stack help reduce UI clutter and manage resources efficiently.

- **Enhanced Deck Viewer**
  - **Hide Played Cards:** Automatically hides played cards in the deck viewer for a cleaner overview.
  - **Performance Enhancements:** Toggle performance settings to ensure smoother deck management and reduce lag.

- **Stat Tracking**
  - **Global Stats:** Enable tracking of comprehensive game statistics to monitor your progress.
  - **Category Selection:** Choose specific stat categories such as jokers, consumables, and general statistics for detailed insights.

- **Settings UI Overhaul**
  - **Aesthetic Improvements:** Enhance readability and visual appeal of the settings menu.
  - **Modular Settings Functions:** Easily customize and manage settings with a flexible, modular interface.

- **Additional Quality Enhancements**
  - **Sticky Joker Counters:** Keep track of jokers more effectively with persistent counters.
  - **Mass Use Buttons:** Quickly use multiple consumables at once, saving time and improving efficiency.
  - **Retry Buttons in Challenges:** Easily retry challenges without navigating through multiple menus.
  - **And More:** A variety of additional quality-of-life improvements to enhance your overall gaming experience.
  
## Installation

Saturn installation varies depending on whether you already have **Steamodded** and/or **Lovely-injector** installed. Follow the appropriate section below based on your current setup.

### For New Users

If you're starting fresh and do not have **Steamodded** or **Lovely-injector** installed, follow these steps:

#### Prerequisites

- **Balatro** game installed.
- [**Steamodded**](https://github.com/Steamopollys/Steamodded/) framework installed and properly configured for managing mods.
  - Download the latest release from the [Steamodded Releases](https://github.com/Steamopollys/Steamodded/releases) page.
- [**Lovely-injector**](https://github.com/ethangreen-dev/lovely-injector) runtime Lua injector framework.
  - Download the latest release from the [Lovely-injector Releases](https://github.com/ethangreen-dev/lovely-injector/releases) page.

#### Steps

1. **Install Steamodded:**
  - Navigate to your Balatro AppData directory and create a new folder named `Mods`.
  - Create a new folder named `Steamodded` inside the `Mods` folder.
  - Extract the contents of the Steamodded release into the `Steamodded` folder. Be sure you are extracting the entire folder, and not the zip file itself or the contents within the Steamodded release folder.
  
   
   ```bash
   # Navigate to your Balatro AppData directory 
   cd %appdata%/Balatro
   mkdir Mods
   
   # Create Steamodded directory
   mkdir Mods/Steamodded
   
   # Extract Steamodded release contents
   unzip path/to/Steamodded-release.zip -d Mods/Steamodded
   ```

2. **Install Lovely-injector:**
   
   - Extract the `version.dll` from the Lovely-injector release.
   - Copy `version.dll` to your antivirus's exclusion list to prevent false positives.
   
3. **Add `version.dll` to Balatro's Steam Library Directory:**
   
   ```bash
   # Navigate to your Balatro Steam install directory
   cd ../SteamLibrary/steamapps/common/Balatro/
   
   # Copy version.dll to Steam Library directory
   cp path/to/lovely-injector/version.dll ../SteamLibrary/steamapps/common/Balatro/
   ```

4. **Install Saturn:**
   
   - Download the latest release of Saturn from the [Saturn Releases](https://github.com/Steamopollys/Saturn/releases) page.
   - Extract the contents of the Saturn release into your `%appdata%/Balatro/Mods` directory. Be sure you are extracting the release folder, and not the zip file itself or the contents within the Saturn release folder.
   
   ```bash
   unzip path/to/Saturn-release.zip -d %appdata%/Balatro/Mods/Steamodded
   ```

5. **Launch Balatro:**
   
   - Start Balatro from Steam.
   - Navigate to the Mods section to ensure Saturn is listed and active.

### If You Already Have Steamodded Installed

If you already have **Steamodded** installed but not **Lovely-injector**, follow these steps to install Saturn:

#### Prerequisites

- **Balatro** game installed.
- **Steamodded** framework already installed and configured.
- [**Lovely-injector**](https://github.com/ethangreen-dev/lovely-injector) runtime Lua injector framework.
  - Download the latest release from the [Lovely-injector Releases](https://github.com/ethangreen-dev/lovely-injector/releases) page.

#### Steps

1. **Install Lovely-injector:**
   
   - Extract the `version.dll` from the Lovely-injector release.
   - Copy `version.dll` to your antivirus's exclusion list to prevent false positives.
   
2. **Add `version.dll` to Balatro's Steam Library Directory:**
   
   ```bash
   # Navigate to your Balatro Steam install directory
   cd ../SteamLibrary/steamapps/common/Balatro/
   
   # Copy version.dll to Steam Library directory
   cp path/to/lovely-injector/version.dll ../SteamLibrary/steamapps/common/Balatro/
   ```

3. **Install Saturn:**
   
   - Download the latest release of Saturn from the [Saturn Releases](https://github.com/Steamopollys/Saturn/releases) page.
   - Extract the contents of the Saturn release into your `%appdata%/Balatro/Mods` directory. Be sure you are extracting the release folder, and not the zip file itself or the contents within the Saturn release folder.
   
   ```bash
   unzip path/to/Saturn-release.zip -d %appdata%/Balatro/Mods/Steamodded
   ```

4. **Launch Balatro:**
   
   - Start Balatro from Steam.
   - Navigate to the Mods section to ensure Saturn is listed and active.

### If You Already Have Lovely-injector Installed

If you already have **Lovely-injector** installed but not **Steamodded**, follow these steps to install Saturn:

#### Prerequisites

- **Balatro** game installed.
- [**Steamodded**](https://github.com/Steamopollys/Steamodded/) framework installed and properly configured for managing mods.
- **Lovely-injector** runtime Lua injector framework already installed.

#### Steps

1. **Install Steamodded:**
  - Navigate to your Balatro AppData directory and create a new folder named `Mods`.
  - Create a new folder named `Steamodded` inside the `Mods` folder.
  - Extract the contents of the Steamodded release into the `Steamodded` folder. Be sure you are extracting the entire folder, and not the zip file itself or the contents within the Steamodded release folder.
  
   
   ```bash
   # Navigate to your Balatro AppData directory 
   cd %appdata%/Balatro
   mkdir Mods
   
   # Create Steamodded directory
   mkdir Mods/Steamodded
   
   # Extract Steamodded release contents
   unzip path/to/Steamodded-release.zip -d Mods/Steamodded
   ```

2. **Add `version.dll` to Balatro's Steamodded Directory:**
   
   ```bash
   # Navigate to your Balatro Steam install directory
   cd ../SteamLibrary/steamapps/common/Balatro/
   
   # Copy version.dll to Steamodded directory
   cp path/to/lovely-injector/version.dll Mods/Steamodded/
   ```

3. **Install Saturn:**
   
   - Download the latest release of Saturn from the [Saturn Releases](https://github.com/Steamopollys/Saturn/releases) page.
   - Extract the contents of the Saturn release into your `%appdata%/Balatro/Mods/Steamodded` directory.
   
   ```bash
   unzip path/to/Saturn-release.zip -d %appdata%/Balatro/Mods/Steamodded
   ```

4. **Launch Balatro:**
   
   - Start Balatro from Steam.
   - Navigate to the Mods section to ensure Saturn is listed and active.

### If You Already Have Both Steamodded and Lovely-injector Installed

#### Steps

1. **Install Saturn:**
   - Download the latest release of Saturn from the [Saturn Releases](https://github.com/Steamopollys/Saturn/releases) page.
   - Extract the contents of the Saturn release into your `%appdata%/Balatro/Mods/Steamodded` directory.
   
   ```bash
   unzip path/to/Saturn-release.zip -d %appdata%/Balatro/Mods/Steamodded
   ```

2. **Launch Balatro:**
   - Start Balatro from Steam.
   - Navigate to the Mods section to ensure Saturn is listed and active.

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
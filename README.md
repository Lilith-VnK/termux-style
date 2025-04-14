---

### Termux Style

Termux Style is a collection of Bash scripts that enhances your Termux experience with an interactive CLI menu and a variety of utilities. This setup is integrated directly into your .bashrc file, allowing you to access system information, network tools, file management features, and more, all from Termux.

### Features

Interactive Menu: Quickly access utilities such as system information, storage management, and network diagnostics.

System Utilities: Display detailed system information including OS, kernel, uptime, CPU, IP address, and more.

Network Tools: Includes tools for DNS lookup, ping tests, traceroute, and WiFi scanning using Termux API.

File & Storage Management: Manage and back up files, organize storage, monitor disk/memory usage, and clean junk files.

Additional Utilities: Calculator, encryption tool, SMS sender, clipboard management, battery status, weather check, and more.

Custom Prompt: A dynamic prompt that shows user, host, IP address, and exit status.


### Installation

1. Clone the Repository:

```
git clone https://github.com/Lilith-VnK/termux-style.git
```


2. Copy the .bashrc File:

Replace your existing .bashrc file with the one provided in the repository:

```
cp termux-style/.bashrc $HOME/.bashrc
```

3. Restart Termux:

Close and reopen Termux, or source your .bashrc:

```
source $HOME/.bashrc
```


### Usage

Launch the Interactive Menu:
After loading your updated .bashrc, a header will appear with a prompt message. Type menu to open the interactive menu.

Navigate the Menus:
Use the provided numeric options to access various features including system updates, Python/Ruby REPLs, network diagnostics, and more.

Custom Aliases:
Several aliases are set up for convenience:

menu – Opens the interactive menu.

sysinfo – Displays system information.

update – Updates and upgrades system packages.

cls – Clears the screen.



### Requirements

Termux API: Functions such as notifications, location, and SMS require Termux API.

Additional Tools: Some features depend on external commands like jq, curl, figlet, lolcat, wget, nmap, dig, etc.


### Repository Structure

.bashrc: The primary configuration file that contains all the functions and menu setups.

Various Functions: Organized within .bashrc, functions cover system info, network utilities, file management, and other enhancements.


### Contributing

Feel free to fork the repository and submit pull requests with improvements or new features. Make sure to maintain the structure and logic so that all features continue to work seamlessly.


---

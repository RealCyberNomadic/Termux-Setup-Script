# Termux Setup Script

## Overview

The **Termux Setup Script** is designed to simplify the process of setting up and configuring your Termux environment. Instead of spending time searching through forums for packages or asking for help in groups, this script takes the hassle out of getting your environment ready. With a few clicks or by using the arrow keys and Enter, you’ll have all the necessary tools installed in no time.

The script ensures that everything is set up in your **$HOME** directory to keep your environment clean and organized, so you won’t have packages scattered all over the place. It also automatically checks for **`termux-setup-storage`** and enables it for you if it hasn’t been done yet—just in case you missed it.

## Key Features

- **Automated Package Installation**  
  Quickly installs essential tools like Git, Curl, Python, Node.js, and more, so you can get straight to work.

- **Blutter Installation**  
  Offers a simple option to install and update **Blutter**, making it easy to set up reverse engineering tools.

- **Backup and Environment Restoration**  
  Easily back up and restore your Termux environment, ensuring that you can recover your setup when needed.

- **User-Friendly Setup**  
  The menu-driven process simplifies installation. Whether you’re installing packages, setting up themes, or configuring your environment, everything can be done with a few key presses—no complicated steps.

- **Wipe Environment Option**  
  There’s also an option to reset your entire environment. This feature won’t wipe anything unless you explicitly type "YES" when prompted. It’s a safety feature for those who need to test or start fresh.

---

### Installation Instructions

1. Install Git (if it’s not already installed):
   <pre><code id="cmd1">pkg install git -y</code></pre>
   <button onclick="copyToClipboard('cmd1')"></button>

2. Clone the repository:
   <pre><code id="cmd2">git clone https://github.com/RealCyberNomadic/Termux-Setup-Script.git</code></pre>
   <button onclick="copyToClipboard('cmd2')"></button>

3. Change to the script’s directory:
   <pre><code id="cmd3">cd Termux-Setup-Script</code></pre>
   <button onclick="copyToClipboard('cmd3')"></button>

4. Make the script executable:
   <pre><code id="cmd4">chmod +x Termux-Setup-Script.sh</code></pre>
   <button onclick="copyToClipboard('cmd4')"></button>

5. Run the script:
   <pre><code id="cmd5">bash ./Termux-Setup-Script.sh</code></pre>
   <button onclick="copyToClipboard('cmd5')"></button>

---

## Why I Created This Script

As a member of several Termux groups and communities, I repeatedly saw the same questions: *"How do I set up a clean, customized Termux environment?"* and *"How can I install tools like Blutter and Radare2 for reverse engineering?"* It was clear that many people were spending too much time struggling with setups, and the whole process was often more complicated than it needed to be.

This script was created to make it easier for users, especially beginners, to get started. Whether you’re installing tools, customizing your environment with themes, or organizing your setup, this script takes care of everything with a simple, guided process.

> **Important:** If you’ve already built your own custom Termux environment, this script may not be for you. However, for those who are just getting started, it’s a great way to save time and avoid confusion.

---

## A Quick Note

What started as a simple Python script to speed up my own installs eventually grew into this fully-fledged tool after numerous rounds of testing and refinement. While I only had a few hours each day to work on it, I’m proud of how far it’s come. If it helps even one person get their Termux environment set up quicker, it will have been worth the effort.

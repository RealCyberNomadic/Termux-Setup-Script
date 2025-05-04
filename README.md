# Termux Setup Script

## Overview

The Termux Setup Script is designed to automate the setup and configuration of essential tools and packages within the Termux environment. This script streamlines the installation process, making it easier for users to quickly get their Termux environment up and running with a variety of useful utilities, including dependency management, theme customization, backup options, and environment restoration.

## Features

- Automated package installations: Installs essential packages such as Git, Curl, Python, Node.js, and more.
- Blutter installation: Provides an option to install and update the Blutter package.
- Environment restoration and backup: Allows users to easily restore or backup their Termux environment.
- Simplified setup process: Removes unnecessary options and streamlines the user experience for easy configuration.

  <h2>Termux Setup Script</h2>
  <p>Copy each command separately by clicking on it:</p>

  <pre><code id="cmd1">git clone https://github.com/RealCyberNomadic/Termux-Setup-Script.git</code></pre>
  <button onclick="copyToClipboard('cmd1')">Copy</button>

  <pre><code id="cmd2">cd Termux-Setup-Script</code></pre>
  <button onclick="copyToClipboard('cmd2')">Copy</button>

  <pre><code id="cmd3">chmod +x Termux-Setup-Script.sh</code></pre>
  <button onclick="copyToClipboard('cmd3')">Copy</button>

  <pre><code id="cmd4">bash ./Termux-Setup-Script.sh</code></pre>
  <button onclick="copyToClipboard('cmd4')">

Why I Created This Script

As someone active in multiple Termux groups and communities, I kept seeing the same questions over and over—how to set up a clean, themed environment, and how to install tools like Blutter and Radare2 for reverse engineering. For many newcomers, getting started was confusing, and setup often took longer than it should.

This script was built to solve that.

It's a lightweight, menu-driven Bash utility that helps new users get up and running fast with essential packages, themes, and reverse engineering tools. Whether you want to dive into debugging with Blutter, analyze binaries with Radare2, or just make Termux look better—this script can do it in minutes.

> If you’ve already built your own environment, this script might not be for you. But for beginners, it's a time-saver.

Important:
The "Wipe All Packages" option will reset your entire Termux environment as if you just installed it—so please use that only if you're absolutely sure.

A Quick Note

Originally, this started out as a rough Python script I hacked together just to speed up my own installs. But after testing (what feels like) 7 billion times and tweaking the UI over time, it evolved into something cleaner and more useful. I could only work on it for a few hours before work each day, but I'm proud of how far it's come.

If it helps even one person get set up quicker, it was worth it.

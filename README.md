Here is the revised documentation, incorporating the auto-copy installation command, removing the references to Dex2c, and updating the information regarding APKEditor and the new Blutter Manager submenu.

🛠️ Termux Setup Script Documentation (Updated)

Installation Instructions (Auto-Copy)

To install the Termux Setup Script, simply copy the command below and paste it directly into your Termux terminal. This command automatically installs Git, clones the repository, sets permissions, and starts the script.

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Copy Termux Command</title>
<style>
    body {
        font-family: Arial, sans-serif;
        padding: 20px;
    }
    .command-container {
        position: relative;
        display: inline-block;
        width: 100%;
        max-width: 800px;
    }
    pre {
        background-color: #f6f8fa;
        padding: 15px 50px 15px 15px;
        border-radius: 6px;
        overflow-x: auto;
        font-family: monospace;
        font-size: 14px;
        margin: 0;
    }
    button.copy-btn {
        position: absolute;
        top: 10px;
        right: 10px;
        padding: 5px 10px;
        font-size: 12px;
        background-color: #2ea44f;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }
    button.copy-btn:hover {
        background-color: #2c974b;
    }
</style>
</head>
<body>

<h2>Termux Setup Command</h2>
<div class="command-container">
    <pre id="command">pkg install git -y && git clone https://github.com/RealCyberNomadic/Termux-Setup-Script.git && cd Termux-Setup-Script && chmod +x Termux-Setup-Script.sh && bash ./Termux-Setup-Script.sh</pre>
    <button class="copy-btn" onclick="copyCommand()">Copy</button>
</div>

<script>
function copyCommand() {
    const commandText = document.getElementById('command').innerText;
    navigator.clipboard.writeText(commandText).then(() => {
        const btn = document.querySelector('.copy-btn');
        const originalText = btn.innerText;
        btn.innerText = "Copied!";
        setTimeout(() => btn.innerText = originalText, 1500);
    }).catch(err => {
        console.error("Failed to copy: ", err);
    });
}
</script>

</body>
</html>
Overview

The Termux Setup Script is designed to make setting up and configuring your Termux environment straightforward and hassle-free. Instead of manually installing packages or searching for complex instructions, this script provides an intuitive, menu-driven interface that quickly prepares your environment with everything you need.

All installations and configurations are neatly contained within your home directory, keeping your system clean and well-organized. Additionally, the script automatically ensures that Termux has proper storage permissions configured, preventing common file access issues.

Key Features
 * Automated Package Installation
   Quickly installs all essential tools like Git, Curl, Python, Node.js, and more — so you can dive right into your work without delay.

 * Blutter Manager Submenu (New)
   A full submenu dedicated to managing the Blutter reverse engineering toolset. This menu, now called Blutter Manager, handles the installation, update, and removal of all Blutter tools.

 * Backup & Wipe Tools
   Enables you to create backups of your entire Termux environment and restore them easily. Also includes a wipe option for fresh starts, with safety checks to prevent accidental data loss.

 * Zsh Add-ons Installer
   Helps enhance your terminal experience by installing popular Zsh plugins and themes effortlessly.

 * MOTD Configuration
   Customize your Termux Message of the Day with personalized styles or system information to make your terminal feel like your own.

 * Python Packages & Plugins
   Provides a curated selection of Python libraries and plugins optimized for scripting, development, and automation within Termux.

 * Radare2 Suite
   Facilitates the installation and update of the Radare2 reverse engineering framework and related tools.

 * Script Refresh & Update
   Allows you to update or refresh the setup script at any time without reinstalling, ensuring you always have the latest features.

 * File Explorer Interface
   Includes a user-friendly folder-style navigation UI to simplify file browsing and management without relying solely on command-line commands.

 * Clean Exit Option
   Lets you exit the script safely at any point, preserving your environment and session state.

Suites Included
Blutter Suite
A comprehensive toolkit focused on reverse engineering and APK modification, featuring:
 * APKEditor for editing APK files, including resources and manifests. A key update ensures that if you remove an APKs, XAPK file using a file Manager APKEditor will properly detect its absence and will not keep you stuck in the editor.

 * Hermes tools for decompiling and disassembling Hermes bytecode.

 * Full installation, update, and removal management via the Blutter Manager submenu.

 * Automated processing for ARM64 binaries.

Radare2 Suite
A powerful set of tools for binary analysis and reverse engineering, including:
 * Assembly-level disassembly of Android bundles.
 * Detailed disassembly and analysis capabilities.
 * Installation support for Hermes Bytecode Tool (HBCTOOL).
 * APK signing and verification with KeySigner.
 * Installation and updating of the Radare2 framework.
 * Signature detection and analysis via SigTool.

Why I Created This Script
As an active member of various Termux communities, I noticed many users struggled to set up clean, functional Termux environments or to install complex tools like Blutter and Radare2. The process was often confusing, time-consuming, and frustrating—especially for beginners.
This script was created to simplify all of that. It’s meant to be a one-stop solution that guides users through setup and customization with ease, saving time and minimizing hassle.
If you’ve already customized your Termux setup extensively, this script might not be necessary for you. But for anyone starting fresh, it’s a great way to get up and running quickly and confidently.

A Quick Note
What began as a small Python script to speed up my own installations evolved into this comprehensive tool after much testing and refinement. Though I only worked on it part-time, I’m proud of the result and hope it helps many users get their Termux environments ready faster and with less frustration.

New Features to be Added Coming Soon.

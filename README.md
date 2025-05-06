Termux Setup Script

Overview

The Termux Setup Script is designed to simplify the process of setting up and configuring your Termux environment. Instead of spending time searching through forums for packages or asking for help in groups, this script takes the hassle out of getting your environment ready. With a few clicks or by using the arrow keys and Enter, you’ll have all the necessary tools installed in no time.

The script ensures that everything is set up in your $HOME directory to keep your environment clean and organized, so you won’t have packages scattered all over the place. It also automatically checks for termux-setup-storage and enables it for you if it hasn’t been done yet—just in case you missed it.

Key Features

Automated Package Installation
Installs essential tools like Git, Curl, Python, Node.js, and more—so you can get straight to work.

Blutter Installation
Provides a simple option to install and update Blutter, making it easy to set up reverse engineering tools.

Backup and Environment Restoration
Back up and restore your Termux environment easily, ensuring you can recover your setup whenever needed.

User-Friendly Setup
The menu-driven interface simplifies installation. Whether you're setting up packages, themes, or configurations, everything is just a few key presses away.

Wipe Environment Option
Includes an option to reset your entire environment. This will only run if you type "YES" when prompted—ideal for testing or starting fresh.


Installation Instructions

1. Install Git (if it’s not already installed):

<pre><code id="cmd1">pkg install git -y</code></pre>  <button onclick="copyToClipboard('cmd1')"></button>


2. Clone the repository:

<pre><code id="cmd2">git clone https://github.com/RealCyberNomadic/Termux-Setup-Script.git</code></pre>  <button onclick="copyToClipboard('cmd2')"></button>


3. Change to the script’s directory:

<pre><code id="cmd3">cd Termux-Setup-Script</code></pre>  <button onclick="copyToClipboard('cmd3')"></button>


4. Make the script executable:

<pre><code id="cmd4">chmod +x Termux-Setup-Script.sh</code></pre>  <button onclick="copyToClipboard('cmd4')"></button>


5. Run the script:

<pre><code id="cmd5">bash ./Termux-Setup-Script.sh</code></pre>  <button onclick="copyToClipboard('cmd5')"></button>


6. All in one command:

<pre><code id="cmd6">pkg install git -y && git clone https://github.com/RealCyberNomadic/Termux-Setup-Script.git && cd Termux-Setup-Script && chmod +x Termux-Setup-Script.sh && bash ./Termux-Setup-Script.sh</code></pre>  <button onclick="copyToClipboard('cmd6')"></button>


Why I Created This Script

As a member of several Termux groups and communities, I kept seeing the same questions: "How do I set up a clean, customized Termux environment?" and "How can I install tools like Blutter and Radare2 for reverse engineering?" Many people were spending too much time struggling with setups. The process was often more complicated than it needed to be.

I created this script to make it easier—especially for beginners—to get started. Whether you’re installing tools, customizing themes, or organizing your setup, this script handles everything through a simple, guided process.

> Important: If you’ve already built your own custom Termux environment, this script may not be for you. But for anyone starting fresh, it’s a great way to save time and avoid confusion.

A Quick Note

What started as a simple Python script to speed up my own installs eventually turned into a full tool after a lot of testing and fine-tuning. I only had a few hours a day to work on it, but I’m proud of the result. If this helps even one person get their Termux environment set up faster, the effort was worth it.

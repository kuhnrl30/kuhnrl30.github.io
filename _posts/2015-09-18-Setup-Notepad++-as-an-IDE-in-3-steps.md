---
layout: post
title: "How to Setup Notepad++ as an IDE"
date: 2015-09-18
comments: true
tags:
- R
- Python
- Octave
---

Notepad++ is an incredibly powerful, open source text editor. Python is a versatile, open source programming language. It only makes sense to put the two together and the result will be a lightweight <img src="/images/npp_logo.png" alt="Notepad++" align="right" width="200" height="125" hspace="20"> Integrated Development Environment or IDE. Notepad++ (Npp) opens really quickly and offers code folding and syntax highlighting for many languages based on the file extension when you save your script. The quick startup is especially handy when you have to make a quick edit and you don't want to wait for Spyder or IDLE to open. You can use Notepad++ as an IDE for many languages which gives the advantage of a single consistent environment if you work with multiple languages. I'll show you examples of how I have it setup for Python, Octave, and R. I've been using Npp as an IDE since I started using Python and Matlab and I'm slowly transitioning my R scripts from RStudio. If I ever figure out how to use Knitr in Npp, then I'll have few reasons to stay with RStudio.

Let's get started!

### 1. Install Notepad++  
You can get your copy of Notepad++ from SourceForge [here](https://notepad-plus-plus.org/download/v6.8.3.html). As of writing, the latest version is 6.8.3. There's nothing special here, just follow your normal install process.

### 2. Install NppExec  
NppExec is a free plugin which allows you to use the console in Notepad++. Open the plugin manager from where else but the Plugins menu. Scroll through the list of plugins until you find NppExec and install it. So far, this has been a pretty simple process. You should have a working copy of Npp installed and the NppExec plugin installed. 

### 3. Setup the Execute command  
This part is a little more complicated but not by much. It's easy to see what you should do once you are done but also easy to get tripped up along the way. It took me a few attempts to get there because I was over complicating everything. Open the execute command by navigating through this menu path: Plugins > NppExec > Execute. Notice you can also use the F6 key to get there much quicker in the future. This should open up an input window where you will tell Npp where to find Python and which script to run. You'll type two lines of code here: the first is changing the directory to where Python.exe is located and the second is telling the computer to execute the current script. I'm running the Anaconda distribution of Python and my fields look like this:  
  
    cd c:/users/ryan/anaconda3  
    python "$(FULL_CURRENT_PATH)"  

It crucial that you enter the "$(FULL_CURRENT_PATH)" exactly as I wrote it. DO NOT try to change this to the path of the file you are trying to run or it won't work. Essentially, NppExec is picking up the directory location based on that of the active file so it will take care of that for you. Once you have these two lines in, you can click OK and your script will run in the console. I'd recommend saving the set as something like RunPython. You can use the same process to run Octave/Matlab scrips or R like this: 

For Octave:  

    cd c:/Octave/Octave-4.0.0/bin  
    octave "$(FULL_CURRENT_PATH)"  

For R:  

	cd "c:/Program Files/R/R-3.2.2/bin"  
    Rscript "$(FULL_CURRENT_PATH)"  

That's it, there's nothing else to it. If you saved each of these as separate setups, you can easily switch the program running the script from the dropdown menu. Remember to press F6 as a shortcut to bring up the execute window. Click ok or hit enter and your program will run. 

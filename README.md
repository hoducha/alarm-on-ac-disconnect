# Alarm on AC disconnect

## Description ##
This is a small program which will notify you when your computer AC power is disconnected.

## Installation
Install the program using the setup file in the ** dist ** directory.

### Create Scheduled Task
Create scheduled task to start the program automatically when you lock your computer and close it when you unlock it.
From ** Control Panel **, go to ** Schedule tasks ** and create 2 tasks as bellow:

1. AlarmOn
	- Trigger: On workstation lock of any user
	- Action: Start a program
		+ Program/scripts: Path to your installed program
		+ Start in: Path the program installed directory

2. AlarmOff
	- Trigger: On workstation unlock  of any user
	- Action: Start a program
		+ Program/scripts: Path to your installed program
		+ Add arguments: `Exit`
		+ Start in: Path the program installed directory

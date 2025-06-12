# PowerShell Purple Team Automation Framework
This repository contains a suite of PowerShell scripts designed to automate the security validation of a hardened Windows host. It leverages the Atomic Red Team framework to execute simulated attacks and then uses enhanced local logging to verify whether those attacks were successfully blocked or detected.
This creates a continuous validation loop, allowing security teams and system administrators to programmatically test their defenses against known MITRE ATT&CK® techniques.
  ## Features
   - Automated TTP Execution: Runs a series of tests from the Atomic Red Team framework.
   - Automated Verification: Immediately queries Windows Event Logs and Sysmon logs to check for evidence of blocks or detections.
   - Clear Reporting: Provides a test-by-test summary of whether a technique was BLOCKED, DETECTED, or if a GAP exists.
   - Actionable Recommendations: Suggests specific configuration changes (e.g., enable a specific audit policy) when a detection gap is found.
   - Customizable Scope: Easily modify the list of tests to run, allowing you to focus on specific threats or tactics.

  ## How to Customize Atomic Red Team Tests
The PowerShell script uses a simple array to define which tests to run. Customizing your test scope is a straightforward process of editing this array.
  ### Step 1: Find Available Tests
The best resource is the official MITRE ATT&CK mapping in the Atomic Red Team GitHub repository.
Primary Resource: Visit the Atomic Red Team TTP Index on GitHub.
Browse by Tactic: This page lists all techniques organized by tactic (e.g., Privilege Escalation, Remote Code Execution).
Select a Technique: Click on a technique link (e.g., T1053.005 - Scheduled Task/Job: Scheduled Task). This will take you to a page listing all the available "atomic tests" for that technique. Each test has a specific purpose and command.
Alternatively, once the AtomicRedTeam module is installed, you can list all available tests directly in PowerShell:</br>
-- This command lists every available atomic test --</br>
Get-AtomicTest


  ### Step 2: Update the Script's Test Array
Open the Script: Open the purple_team_script_ps.ps1 file in a text editor or the PowerShell ISE.
Locate the Array: Near the top of the script, you will find the $TTPsToTest array.
Add or Remove TTPs: To add a test, simply add its TTP number (e.g., "T1553.004") to the list. To remove one, delete its line.
Example:
Original Array
$TTPsToTest = @(
    "T1003.001", 
    "T1543.003"
)

To add a test for BitsJobs, you would change it to:
$TTPsToTest = @(
    "T1003.001", 
    "T1543.003",
    "T1197"      # BITS Jobs
)


The script will automatically loop through this updated list. Note that for new TTPs, you may need to add corresponding detection logic (a new Test-* function and a case in the switch statement) for the automated "DETECTED" check to work. If no detection logic exists, the script will still execute the attack but will report the detection status as "SKIPPED".

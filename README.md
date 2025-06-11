# BlueTeam
BlueTeam scripts

## ExploitProtectionTestingFramework
  ## Script applies and tests (by launching the application) all discovered exploit protection settings.  Any log generation - script will roll back the setting and display the log 
Change the config for the application you are testing.  Create a test folder, script uses "C:\Automated_App_Testing".  Does not work with suite based applications (Adobe - pending testing)
Script outputs to test file folder - json for validation

  ## Set up
  Update Configuration with the application being tested, sample configurations located at the bottom of the script
          #------------------------------------------------------------------------------------
          # --- CONFIGURATION BLOCK - PASTE THE DESIRED APP CONFIGURATION HERE ---
          #------------------------------------------------------------------------------------
          
          # This section will be replaced by one of the application-specific blocks from the guide.
          $friendlyAppName = "Microsoft Word"
          $appName         = "WINWORD.EXE"
          $appType         = "DocumentApp" # 'Browser' or 'DocumentApp'
          $testResource    = "C:\Automated_App_Testing\test.docx"
          $delayInSeconds  = 10 # Longer delay for larger Office apps

        ## Sample Success and Sample Error (Rolled Back)
         + ------------------------------------------------------------
        ATTEMPTING MITIGATION: AuditEnableRopCallerCheck
          - VERIFY: Setting for 'AuditEnableRopCallerCheck' was successfully applied.
          - LAUNCH: Launching WINWORD.EXE as STANDARD USER...
          - WAIT: Waiting for 10 seconds...
          - CHECK: Checking for security mitigation events...
          - RESULT: No events found. Mitigation 'AuditEnableRopCallerCheck' appears STABLE.
        
         + ------------------------------------------------------------
        ATTEMPTING MITIGATION: EnableRopSimExec
          - VERIFY: Setting for 'EnableRopSimExec' was successfully applied.
          - LAUNCH: Launching WINWORD.EXE as STANDARD USER...
          - WAIT: Waiting for 10 seconds...
          - CHECK: Checking for security mitigation events...
          - RESULT: No events found. Mitigation 'EnableRopSimExec' appears STABLE.
        
         + ------------------------------------------------------------
        ATTEMPTING MITIGATION: AuditEnableRopSimExec
          - VERIFY: Setting for 'AuditEnableRopSimExec' was successfully applied.
          - LAUNCH: Launching WINWORD.EXE as STANDARD USER...
          - WAIT: Waiting for 10 seconds...
          - CHECK: Checking for security mitigation events...
        WARNING:   - RESULT: Found event(s) for 'AuditEnableRopSimExec'. This mitigation is UNSTABLE.
        WARNING:     - Event Details: Process '\Device\HarddiskVolume3\Program Files\Microsoft Office\root\Office16\WINWORD.EXE' (PID 12512) was blocked from making the NtFsControlFile system call.
          - ACTION: Disabling 'AuditEnableRopSimExec'...
        
         + ------------------------------------------------------------

## WORDCheckSum.ps1
      Setup - put the application tested, this will pick up the json and validate against implemented settings
      ## Sample Output
              Reading expected configuration from 'C:\Automated_App_Testing\stable_mitigations_for_WINWORD.EXE.json'...
              
              Verifying Exploit Protection configuration for Microsoft Word...
              NOTE: Ignoring 2 known problematic mitigation(s): StrictHandle, Sehop
              Expecting to find 25 enabled (and verifiable) mitigations for 'WINWORD.EXE'.
              
               + ------------------------------------------------------------
                - Expected Enabled Count: 25
                - Actually Enabled Count: 25
                - RESULT: PASS
              
               + ============================================================
              VERIFICATION SCRIPT COMPLETE.
              ============================================================


      

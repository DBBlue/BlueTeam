#Requires -RunAsAdministrator
# Definitive Single-App Verification Script v4.2 - Cleaner Logic

#------------------------------------------------------------------------------------
# --- CONFIGURATION BLOCK ---
#------------------------------------------------------------------------------------
# Define the application you are verifying. This must match the one from the test script.
$friendlyAppName = "Microsoft Word"
$appName         = "WINWORD.EXE"

# --- IGNORE LIST ---
# Mitigations to ignore during verification due to known system-specific override or revert behaviors.
$ignoredMitigations = @(
    'StrictHandle', 
    'Sehop'
)

#------------------------------------------------------------------------------------
# --- SCRIPT ENGINE (Reads results automatically from file) ---
#------------------------------------------------------------------------------------

#region Verification Engine

function Get-CurrentlyEnabledMitigations {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetAppName
    )
    # The pre-emptive "Set" command has been removed as it is not needed in a verification context.
    # We expect the application to already be configured by the main test script.
    $mitigationObject = Get-ProcessMitigation -Name $TargetAppName -ErrorAction Stop
    if (-not $mitigationObject) { throw "Could not retrieve the mitigation object for '$TargetAppName'." }

    $enabledNames = [System.Collections.Generic.List[string]]::new()
    $topLevelGroups = $mitigationObject.psobject.Properties | Where-Object { $_.Name -notin 'ProcessName', 'Id', 'Source' }

    foreach ($group in $topLevelGroups) {
        $policyObject = $group.Value
        
        # Case 1: Check if the top-level property itself represents the state as 'ON'.
        if ($policyObject.ToString() -eq 'ON') {
             $enabledNames.Add($group.Name)
        }

        # Case 2: Check the nested properties within the policy object.
        if ($policyObject -and $policyObject.psobject.Properties.Count -gt 0) {
            foreach ($setting in $policyObject.psobject.Properties) {
                if ($setting.Value.ToString() -eq 'ON') {
                    $mitigationName = if ($setting.Name -eq 'Enable') { $group.Name } else { $setting.Name }
                    $enabledNames.Add($mitigationName)
                }
            }
        }
    }
    return $enabledNames | Select-Object -Unique
}

# --- Main Verification Logic ---
$resultsFile = "C:\Automated_App_Testing\stable_mitigations_for_$($appName).json"
Write-Host "Reading expected configuration from '$resultsFile'..."
if (-not (Test-Path $resultsFile)) {
    Write-Error "Could not find the results file. Please run the main test script first for '$appName'."
    return
}
$expectedEnabledMitigations = Get-Content -Path $resultsFile | ConvertFrom-Json

# Filter the expected list based on the ignore list
$originalExpectedCount = $expectedEnabledMitigations.Count
$expectedEnabledMitigations = $expectedEnabledMitigations | Where-Object { $_ -notin $ignoredMitigations }
$filteredExpectedCount = $expectedEnabledMitigations.Count

Write-Host "`nVerifying Exploit Protection configuration for $friendlyAppName..." -ForegroundColor Cyan

if ($originalExpectedCount -ne $filteredExpectedCount) {
    Write-Host "NOTE: Ignoring $($originalExpectedCount - $filteredExpectedCount) known problematic mitigation(s): $($ignoredMitigations -join ', ')" -ForegroundColor DarkGray
}

$expectedCount = $filteredExpectedCount
Write-Host "Expecting to find $expectedCount enabled (and verifiable) mitigations for '$appName'."
Write-Host "`n" + ("-"*60)
try {
    $actuallyEnabledList = Get-CurrentlyEnabledMitigations -TargetAppName $appName
    if ($null -eq $actuallyEnabledList) { $actuallyEnabledList = @() }
    
    # Filter the actual list based on the ignore list
    $actuallyEnabledList = $actuallyEnabledList | Where-Object { $_ -notin $ignoredMitigations }
    $actualCount = $actuallyEnabledList.Count

    Write-Host "  - Expected Enabled Count: $expectedCount"
    Write-Host "  - Actually Enabled Count: $actualCount"

    if ($expectedCount -eq $actualCount) {
        Write-Host "  - RESULT: PASS" -ForegroundColor Green
    }
    else {
        Write-Warning "  - RESULT: FAIL - Mismatch detected."
        $comparison = Compare-Object -ReferenceObject ($expectedEnabledMitigations | Sort-Object) -DifferenceObject ($actuallyEnabledList | Sort-Object)
        
        $missingFromSystem = $comparison | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -ExpandProperty InputObject
        $unexpectedOnSystem = $comparison | Where-Object { $_.SideIndicator -eq '=>' } | Select-Object -ExpandProperty InputObject

        if ($missingFromSystem) { Write-Warning "    - Mitigations that SHOULD be enabled but are NOT: $($missingFromSystem -join ', ')" }
        if ($unexpectedOnSystem) { Write-Warning "    - Mitigations that are unexpectedly ENABLED: $($unexpectedOnSystem -join ', ')" }
    }
}
catch { Write-Error "Could not verify '$appName'. Error: $($_.Exception.Message)" }

Write-Host "`n" + ("="*60)
Write-Host "VERIFICATION SCRIPT COMPLETE." -ForegroundColor Cyan
Write-Host ("="*60)

#endregion


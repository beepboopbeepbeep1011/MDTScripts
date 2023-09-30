###
#
# Standard GPLv3 License
# This script is designed to account for the current applications listed and
# then append the applications in the Applications\%Make%\%Model% folder\group
# setup in the MDT Workbench.
# You are responsible to verify the %Make% and %Model% and setup the 
# folder\group strucuture accordingly.
# 
# Date: 2023-09-30
# Author: beepboopbeepbeep1011
# Version: 1.0
#
###

<#
.SYNOPSIS

    Add list applications from the Applications\%Make%\%Model% node from the MDT
    Workbench.

.DESCRIPTION

    Get the list of applications selected from the wizard or included in the 
    CustomSettings.ini file and append all Applications from the Applications\
    %Make%\%Model% folder\group stucture in the MDT Workbench.

.EXAMPLE

    .\Get-MDTApplicationsFromWorkbenchMakeModelFolders.ps1

.NOTES

    Required to be run from within an MDT Task Sequence.  Leverages the
    Microsoft.SMS.TSEnvironment COMObject.
    
#>


Function Format-InstallCounter{

    Param(
        [parameter(Mandatory = $true)] [int] $count
    )

    If(($count -ge 1) -AND ($count -le 9)){
        [string] $count = "00$count"
    }
    ElseIf(($count -ge 10) -AND ($count -le 99)){
        [string] $count = "0$count"
    }

    Return $count

}

#Load the TS Environment
$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$ApplicationsXMLFile = "$($TSEnv.Value('DeployRoot'))\Control\ApplicationGroups.xml"

$AppCounter = 0
$PresentGUIDList = ""

#Checking for any existing applications, noting where the list stops, holding a list of existing application Guids for reference to help prevent attempting to install an application more than once.
For ($Tester = 1; $Tester -le 999; $Tester++){
    
    $fmtTester = Format-InstallCounter -count $Tester
    If($TSEnv.Value("Applications$fmtTester") -ne ""){

        $PresentGUIDList+="Applications$fmtTester=$($TSEnv.Value("Applications$fmtTester"))`r`n"
        $AppCounter++
        
    }

}

Write-Host "The initial applications install list contains $AppCounter applications selected in the the wizard or preconfigured from the rules/customsettings.ini file."

#Read in the ApplicationGroups.xml used to find the Applications in a specific Make/Model group/folder from the Deployment Workbench.
Try{
    [xml] $AppGroupXML = Get-Content $ApplicationsXMLFile
}
Catch{
    Write-Host "Could not access path $ApplicationsXMLFile"
    Exit
}

# Get the list of all the group objects.
$AppGroups = $AppGroupXML.FirstChild.Group

$SkipCounter = 0

# Search for and the make and model group in the ApplicationsGroup.xml
# If found, add each Application from the group into the list of Applications going with each subsquent number.
# If the application is already in the list, do not add the application again.
ForEach($AppGroup in $AppGroups){

    If($AppGroup.name -eq "$($TSEnv.Value('Make'))\$($TSEnv.Value('Model'))"){

        Write-Host "Found Deployment Workbench group/folder - $($AppGroup.Name)"
        Write-Host "Found $($AppGroup.Member.Count) applications to add to the applications install list."        
        If($AppGroup.Member.Count -gt 0){
            ForEach($memberGuid in $AppGroup.Member){
            
                If($PresentGUIDList -notmatch $memberGuid){
                    $AppCounter++
                    $y = Format-InstallCounter -count $AppCounter
                    $TSEnv.Value("Applications$y") = $MemberGuid
                    $CurrentGuidList+="Applications$y=$MemberGuid`r`n"

                }
                Else{

                    Write-Host "Application: $MemberGuid already in list.  Skipping."
                    $SkipCounter++

                }
            
            }
    
        }
        Else{

            Write-Host "No applications found in the $($AppGroup.Name) folder/group."

        }
    
    }
    
}
If($SkipCounter -gt 0){
    Write-Host "Skipped adding $SkipCounter duplicate application(s) to the applications install list."
}
If($AppCounter -gt 0){
    Write-Host "The final applications install list contains $AppCounter applications."
    Write-Host $PresentGuidList$CurrentGuidList
}

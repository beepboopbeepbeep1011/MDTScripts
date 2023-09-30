#How To Use Get-MDTApplicationsFromWorkbenchMakeModelFolders.ps1

Disclaimer: 
This script was not tested with an MDT Task Sequence in Configuration Manager.
This script was not tested in a Media deployment.

1. Setup the Applications\%Make%\%Model% folder structure with the correct makes and models.
2. Add the requisite applications to each folder.
3. Copy the script to the \\\\<MDTSERVER\>\\\<MDTShare\>\\Scripts folder.
4. Ensure the Task Sequence contains an InstallApplications task where the 'Install multiple applications' option has been selected.  This is the task and selection to install MandadoryApplicationsXXX and ApplicationsXXX dynamically.
5. In an MDT Task Sequence, add a Run PowerShell Script task at some point before an InstallApplications task as described in #2.
6. Set the Name of the task.
7. Set the PowerShell script: to %SCRIPTROOT%\Get-MDTApplicationsFromWorkbenchMakeModelFolders.ps1
8. Click 'Apply' or 'OK' to commit the change.
9. Deploy a device and review the logs and installed applications for verification.

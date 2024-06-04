AZMIGRATEPROJECT_SUBSCRIPTION_ID,AZMIGRATEPROJECT_RESOURCE_GROUP_NAME,AZMIGRATEPROJECT_NAME,AZMIGRATE_APPLIANCE_NAME,SOURCE_MACHINE_NAME,OS_UPGRADE_VERSION,AZMIGRATEASSESSMENT_NAME,AZMIGRATEGROUP_NAME,SQL_SERVER_LICENSE_TYPE,TAG_KEY,TAG_VALUE,VM_TAG_KEY,VM_TAG_VALUE,DISK_TAG_KEY,DISK_TAG_VALUE,NIC_TAG_KEY,NIC_TAG_VALUE,TEST_VNET_NAME,TEST_SUBNET_NAME,TARGET_SUBSCRIPTION_ID,TARGET_RESOURCE_GROUP_NAME,TARGET_VNET_NAME,TARGET_SUBNET_NAME,TARGET_MACHINE_NAME,TARGET_MACHINE_SIZE,LICENSE_TYPE,OS_DISK_ID,OS_DISK_TYPE,DATA_DISK1_ID,DATA_DISK1_TYPE,TARGET_DISKTYPE,AVAILABILITYZONE_NUMBER,AVAILABILITYSET_NAME,TURNOFF_SOURCESERVER,TESTMIGRATE_VNET_NAME,UPDATED_TEST_VNET_NAME,UPDATED_TAG_KEY,UPDATED_TAG_VALUE,UPDATED_TAG_OPERATION,UPDATED_VMTAG_KEY,UPDATED_VMTAG_VALUE,UPDATED_VMTAG_OPERATION,UPDATED_DISKTAG_KEY,UPDATED_DISKTAG_VALUE,UPDATED_DISKTAG_OPERATION,UPDATED_NICTAG_KEY,UPDATED_NICTAG_VALUE,UPDATED_NICTAG_OPERATION,UPDATED_TARGET_RESOURCE_GROUP_NAME,UPDATED_TARGET_VNET_NAME,UPDATED_TARGET_MACHINE_NAME,UPDATED_TARGET_DISK_NAME,UPDATED_TARGET_OS_DISK_NAME,UPDATED_TARGET_DATA_DISK1_NAME,UPDATED_TARGET_DATA_DISK2_NAME,UPDATED_TARGET_MACHINE_SIZE,UPDATED_AVAILABILITYZONE_NUMBER,UPDATED_AVAILABILITYSET_NAME,UPDATED_NIC1_ID,TFO_NIC1_ID,UPDATED_TARGET_NIC1_NAME,UPDATED_TARGET_NIC1_SELECTIONTYPE,UPDATED_TARGET_NIC1_SUBNET_NAME,UPDATED_TARGET_NIC1_IP,UPDATED_TARGET_NIC1_TEST_IP,UPDATED_TARGET_NIC1_TEST_SUBNET_NAME,TFO_NIC1_TEST_SUBNET_NAME,UPDATED_NIC2_ID,TFO_NIC2_ID,UPDATED_TARGET_NIC2_NAME,UPDATED_TARGET_NIC2_SELECTIONTYPE,UPDATED_TARGET_NIC2_SUBNET_NAME,UPDATED_TARGET_NIC2_IP,UPDATED_TARGET_NIC2_TEST_IP,UPDATED_TARGET_NIC2_TEST_SUBNET_NAME,TFO_NIC2_TEST_SUBNET_NAME,OK_TO_UPDATE,OK_TO_MIGRATE,OK_TO_USE_ASSESSMENT,OK_TO_TESTMIGRATE,OK_TO_RETRIEVE_REPLICATIONSTATUS,OK_TO_CLEANUP,OK_TO_TESTMIGRATE_CLEANUP
0c608708-8dca-42ac-9a36-0fd35523f857,GUY-PP-EUNR1-AZUREMIGRATE,GUY-PP-EUNR1-AZUREMIGRATE,GBBED11AS867V,GBBE13V0814,,,,,"responsibleOrg,backupPolicy,patchContact,appName","Guy Carpenter,Short,z-CHG GC Analytics Infr Svc,KCENTER GC - EMEA","responsibleOrg,backupPolicy,patchContact,appName","Guy Carpenter,Short,z-CHG GC Analytics Infr Svc,KCENTER GC - EMEA","responsibleOrg,backupPolicy,patchContact,appName","Guy Carpenter,Short,z-CHG GC Analytics Infr Svc,KCENTER GC - EMEA","responsibleOrg,backupPolicy,patchContact,appName","Guy Carpenter,Short,z-CHG GC Analytics Infr Svc,KCENTER GC - EMEA",,,9b91a2ed-d806-40f2-92ab-e84f03240880,gc-azmigratepilot-emea-privatedev-rg,GUY-PV-EUNR1,GUY-PV-EUNR1-DEV,GBBE13V0814,Standard_B2s_v2,WindowsServer,,Standard_LRS,,StandardSSD_LRS,,1,,Y,,,,,,,,,,,,,,,,,,,,,,,,,,,,,GUY-PV-EUNR1-DEV,10.134.36.5,,,,,,,,,,,,,Y,Y,N,N,Y,Y,N
0c608708-8dca-42ac-9a36-0fd35523f857,GUY-PP-EUNR1-AZUREMIGRATE,GUY-PP-EUNR1-AZUREMIGRATE,GBBED11AS867V,GBBE13V0815,,,,,"responsibleOrg,backupPolicy,patchContact,appName","Guy Carpenter,Short,z-CHG GC Analytics Infr Svc,KCENTER GC - EMEA","responsibleOrg,backupPolicy,patchContact,appName","Guy Carpenter,Short,z-CHG GC Analytics Infr Svc,KCENTER GC - EMEA","responsibleOrg,backupPolicy,patchContact,appName","Guy Carpenter,Short,z-CHG GC Analytics Infr Svc,KCENTER GC - EMEA","responsibleOrg,backupPolicy,patchContact,appName","Guy Carpenter,Short,z-CHG GC Analytics Infr Svc,KCENTER GC - EMEA",,,9b91a2ed-d806-40f2-92ab-e84f03240880,gc-azmigratepilot-emea-privatedev-rg,GUY-PV-EUNR1,GUY-PV-EUNR1-DEV,GBBE13V0815,Standard_B2s_v2,WindowsServer,,Standard_LRS,,StandardSSD_LRS,,2,,Y,,,,,,,,,,,,,,,,,,,,,,,,,,,,,GUY-PV-EUNR1-DEV,10.134.36.6,,,,,,,,,,,,,Y,Y,N,N,Y,Y,N




Param(
    [parameter(Mandatory=$true)]
    $CsvFilePath
)

$ErrorActionPreference = "Stop"

$scriptsPath = $PSScriptRoot
if ($PSScriptRoot -eq "") {
    $scriptsPath = "."
}

. "$scriptsPath\AzMigrate_Logger.ps1"
. "$scriptsPath\AzMigrate_Shared.ps1"
. "$scriptsPath\AzMigrate_CSV_Processor.ps1"

Function ProcessItemImpl($processor, $csvItem, $reportItem) {
    
    $reportItem | Add-Member NoteProperty "AdditionalInformation" $null

    $sourceMachineName = $csvItem.SOURCE_MACHINE_NAME
    if ([string]::IsNullOrEmpty($sourceMachineName)) {
        $processor.Logger.LogError("SOURCE_MACHINE_NAME is not mentioned in the csv file")
        $reportItem.AdditionalInformation = "SOURCE_MACHINE_NAME is not mentioned in the csv file" 
        return
    }
    $azMigrateRG = $csvItem.AZMIGRATEPROJECT_RESOURCE_GROUP_NAME
    if ([string]::IsNullOrEmpty($azMigrateRG)) {
        $processor.Logger.LogError("AZMIGRATEPROJECT_RESOURCE_GROUP_NAME is not mentioned for: '$($sourceMachineName)'")
        $reportItem.AdditionalInformation = "AZMIGRATEPROJECT_RESOURCE_GROUP_NAME is not mentioned for: '$($sourceMachineName)'"
        return
    }
    $azMigrateProjName = $csvItem.AZMIGRATEPROJECT_NAME
    if ([string]::IsNullOrEmpty($azMigrateProjName)) {
        $processor.Logger.LogError("AZMIGRATEPROJECT_NAME is not mentioned for: '$($sourceMachineName)'")
        $reportItem.AdditionalInformation = "AZMIGRATEPROJECT_NAME is not mentioned for: '$($sourceMachineName)'"
        return
    }
    $azMigrateApplianceName = $csvItem.AZMIGRATE_APPLIANCE_NAME
    if ([string]::IsNullOrEmpty($azMigrateApplianceName)) {
        $processor.Logger.LogError("AZMIGRATE_APPLIANCE_NAME is not mentioned for: '$($sourceMachineName)'")
        $reportItem.AdditionalInformation = "AZMIGRATE_APPLIANCE_NAME is not mentioned for: '$($sourceMachineName)'"
        return
    }

    # Validate required tags
    $requiredTags = @("appName", "backupPolicy", "patchContact", "responsibleOrg")
    $tagKeys = $csvItem.TAG_KEY -split ","
    $tagValues = $csvItem.TAG_VALUE -split ","
    $tags = @{}
    for ($i = 0; $i -lt $tagKeys.Length; $i++) {
        $tags[$tagKeys[$i]] = $tagValues[$i]
    }

    foreach ($tag in $requiredTags) {
        if (-not $tags.ContainsKey($tag)) {
            $processor.Logger.LogError("Required tag '$tag' is not mentioned for: '$($sourceMachineName)'")
            $reportItem.AdditionalInformation = "Required tag '$tag' is not mentioned for: '$($sourceMachineName)'"
            return
        }
    }

    # Apply tags to the resource group to ensure policy compliance
    $resourceGroup = Get-AzResourceGroup -Name $azMigrateRG
    if ($null -ne $resourceGroup) {
        Set-AzResource -ResourceId $resourceGroup.ResourceId -Tag $tags -Force
        $processor.Logger.LogTrace("Tags have been successfully applied to the resource group: '$($azMigrateRG)'")
    } else {
        $processor.Logger.LogError("Failed to retrieve the resource group to apply tags for: '$($azMigrateRG)'")
        $reportItem.AdditionalInformation = "Failed to retrieve the resource group to apply tags for: '$($azMigrateRG)'"
        return
    }

    # Retrieve the information if we should turn off the source server
    $TurnOff_SrcServer = $csvItem.TURNOFF_SOURCESERVER
    if ([string]::IsNullOrEmpty($TurnOff_SrcServer)) {$processor.Logger.LogTrace("TURNOFF_SOURCESERVER is not mentioned for: '$($sourceMachineName)'")}

    # Validate if we can/should run TestMigrate at all for this machine
    $ReplicatingServermachine = $AzMigrateShared.GetReplicationServer($azMigrateRG, $azMigrateProjName, $sourceMachineName, $azMigrateApplianceName)
    
    if((-not $ReplicatingServermachine) -or ($csvItem.OK_TO_MIGRATE -ne 'Y') `
        -or (($ReplicatingServermachine.MigrationState -ne "Replicating") -and ($ReplicatingServermachine.MigrationStateDescription -ne "Ready to migrate")) `
        -or (-not $ReplicatingServermachine.AllowedOperation -contains "Migrate")){

        $processor.Logger.LogError("We cannot initiate Migration as either it is not configured in csv file OR the state of this machine replication is not suitable for initiating Migration Now: '$($sourceMachineName)'")
        $reportItem.AdditionalInformation = "We cannot initiate Migration as either it is not configured in csv file OR the state of this machine replication is not suitable for initiating Migration Now: '$($sourceMachineName)'. Please Run AzMigrate_UpdateReplicationStatus.ps1 and look at the output csv file which may provide more details"
        $processor.Logger.LogTrace("Current Migration State of machine: '$($ReplicatingServermachine.MigrationState)'")
        $processor.Logger.LogTrace("Current Migration State Description of machine: '$($ReplicatingServermachine.MigrationStateDescription)'")
        foreach($AO in $ReplicatingServermachine.AllowedOperation)
        {
            $processor.Logger.LogTrace("Allowed Operation: '$($AO)'")
        }
        return
    }

    $osUpgradeVersion = $csvItem.OS_UPGRADE_VERSION

    # Start the migration
    if ([string]::IsNullOrEmpty($TurnOff_SrcServer) -or ($TurnOff_SrcServer -eq 'N') -or ($TurnOff_SrcServer -eq 'No')){
        # We are defaulting to this if Turn off Source Server is not mentioned
        if([string]::IsNullOrEmpty($osUpgradeVersion)){
            $processor.Logger.LogTrace("OS_UPGRADE_VERSION is not mentioned for: '$($sourceMachineName)'")
            $reportItem.AdditionalInformation = "OS_VERSION_UPGRADE is not mentioned for: '$($sourceMachineName)'"
            $MigrateJob = Start-AzMigrateServerMigration -InputObject $ReplicatingServermachine
        } else{
            $MigrateJob = Start-AzMigrateServerMigration -InputObject $ReplicatingServermachine -OsUpgradeVersion $osUpgradeVersion
        }
    }
    else {
        if([string]::IsNullOrEmpty($osUpgradeVersion)){
            $processor.Logger.LogTrace("OS_UPGRADE_VERSION is not mentioned for: '$($sourceMachineName)'")
            $reportItem.AdditionalInformation = "OS_VERSION_UPGRADE is not mentioned for: '$($sourceMachineName)'"
            $MigrateJob = Start-AzMigrateServerMigration -InputObject $ReplicatingServermachine -TurnOffSourceServer
        } 
        else {
            $MigrateJob = Start-AzMigrateServerMigration -InputObject $ReplicatingServermachine -TurnOffSourceServer -OsUpgradeVersion $osUpgradeVersion
        }
    }
    
    if (-not $MigrateJob){
        $processor.Logger.LogError("Migration Job couldn't be initiated for the specified machine: '$($sourceMachineName)'")   
        $reportItem.AdditionalInformation = "Migration Job couldn't be initiated for the specified machine: '$($sourceMachineName)'. Please Run AzMigrate_UpdateReplicationStatus.ps1 and look at the output csv file which may provide more details)"                  
    }
    else {
        $processor.Logger.LogTrace("Migration Job is initiated for the specified machine: '$($sourceMachineName)'")    

        # Apply tags to the migrated VM
        try {
            $targetRG = $csvItem.TARGET_RESOURCE_GROUP_NAME
            $processor.Logger.LogTrace("Retrieving target resource group: '$targetRG'")
            $targetResourceGroup = Get-AzResourceGroup -Name $targetRG

            if ($null -eq $targetResourceGroup) {
                $processor.Logger.LogError("Target resource group '$targetRG' could not be found.")
                $reportItem.AdditionalInformation = "Target resource group '$targetRG' could not be found."
                return
            }

            $targetVM = Get-AzVM -ResourceGroupName $targetRG -Name $csvItem.TARGET_MACHINE_NAME
            if ($null -ne $

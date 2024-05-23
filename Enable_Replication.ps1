[CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $MigrateSubscriptionName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $RecoveryVault,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $RecoveryVaultResourceGroup,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $VMFriendlyName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $OSType,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationSubScriptionName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationResourceGroupName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationStorageAccountName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationStorageAccountResourceGroupName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationNetworkName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationSubnetName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationNetworkResourceGroupName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationSize,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationAvailabilityZone,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $SqlServerLicenceType,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $tagKeys,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $tagValues
        )


        Write-Verbose "MigrateSubscriptionName  = $($MigrateSubscriptionName)"
        Write-Verbose "RecoveryVault  = $($RecoveryVault)"
        Write-Verbose "RecoveryVaultResourceGroup  = $($RecoveryVaultResourceGroup)"
        Write-Verbose "VMFriendlyName  = $($VMFriendlyName)"
        Write-Verbose "OSType  = $($OSType)"
        Write-Verbose "DestinationSubScriptionName  = $($DestinationSubScriptionName)"
        Write-Verbose "DestinationResourceGroupName  = $($DestinationResourceGroupName)"
        Write-Verbose "DestinationStorageAccountName  = $($DestinationStorageAccountName)"
        Write-Verbose "DestinationStorageAccountResourceGroupName  = $($DestinationStorageAccountResourceGroupName)"
        Write-Verbose "DestinationNetworkName  = $($DestinationNetworkName)"
        Write-Verbose "DestinationSubnetName  = $($DestinationSubnetName)"
        Write-Verbose "DestinationNetworkResourceGroupName  = $($DestinationNetworkResourceGroupName)"
        Write-Verbose "DestinationSize  = $($DestinationSize)"
        Write-Verbose "DestinationAvailabilityZone  = $($DestinationAvailabilityZone)"
        Write-Verbose "SqlServerLicenceType  = $($SqlServerLicenceType)"
        Write-Verbose "tagKeys  = $($tagKeys)"
        Write-Verbose "tagValues  = $($tagValues)"

        #$tagKeys="AppName","backupPolicy,patchContact,responsibleOrg"
        #$tagValues="GC CAT CLIENT VM(S)","None","GC GL Infr Svc RTB - W","GC IT - Infrastructure Services"
Function ProcessTags($tagKeys,$tagValues){
    $tagDict= [System.Collections.Generic.Dictionary[string, string]]::new()
    if ([string]::IsNullOrEmpty($tagKeys) -or [string]::IsNullOrEmpty($tagValues)) {
        write-host "Tag Key/Value not mentioned for: '$($VMFriendlyName)'"
    }
    else{
        $tagKeys = $tagKeys -split ","
        $tagValues = $tagValues -split ","
        # check if the count is equal for keys and values
        if ($tagKeys.Count -ne $tagValues.Count) {
            write-host "Tag Key/Value count mismatch for: '$($VMFriendlyName)'"
            return 
        }
        else{
            for ($i = 0; $i -lt $tagKeys.Count; $i++) {
                $tagDict.Add($tagKeys[$i], $tagValues[$i])
            }
        }
    }
    return $tagDict
}
        

Function Get-DestinationResourceGroupID{
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationSubScriptionName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationResourceGroupName           
        )
    Write-Verbose "Setting the context to $DestinationSubScriptionName"
    Set-AzContext -Subscription $DestinationSubScriptionName |out-null
    Write-Verbose "Context changed to $DestinationSubScriptionName"
    Write-Verbose "Getting resource group id for $DestinationResourceGroupName"
    return (Get-AzResourceGroup -Name $DestinationResourceGroupName).ResourceId
}
Function Get-DestinationStorageAccountID{
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationSubScriptionName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationStorageAccountName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationStorageAccountResourceGroupName           
        )
    Write-Verbose "Setting the context to $DestinationSubScriptionName"
    Set-AzContext -Subscription $DestinationSubScriptionName |out-null
    Write-Verbose "Context changed to $DestinationSubScriptionName"
    Write-Verbose "Getting Storage Account id for $DestinationStorageAccountName in $DestinationStorageAccountResourceGroupName"
    return (Get-AzResource -Name $DestinationStorageAccountName -ResourceGroupName $DestinationStorageAccountResourceGroupName).ResourceId
}
Function Get-DestinationNetworkID{
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationSubScriptionName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationNetworkName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $DestinationNetworkResourceGroupName           
        )
    Write-Verbose "Setting the context to $DestinationSubScriptionName"
    Set-AzContext -Subscription $DestinationSubScriptionName |out-null
    Write-Verbose "Context changed to $DestinationSubScriptionName"
    Write-Verbose "Getting Network id for $DestinationNetworkName in $DestinationNetworkResourceGroupName"
    return (Get-AzResource -Name $DestinationNetworkName -ResourceGroupName $DestinationNetworkResourceGroupName).ResourceId
}

$DestinationResourceGroupID = Get-DestinationResourceGroupID `
                                -DestinationSubScriptionName $DestinationSubScriptionName `
                                -DestinationResourceGroupName $DestinationResourceGroupName -Verbose

$DestinationStorageAccountID = Get-DestinationStorageAccountID `
                                -DestinationSubScriptionName $DestinationSubScriptionName `
                                -DestinationStorageAccountName $DestinationStorageAccountName `
                                -DestinationStorageAccountResourceGroupName $DestinationStorageAccountResourceGroupName -Verbose

$DestinationNetworkId = Get-DestinationNetworkID `
                                -DestinationSubScriptionName $DestinationSubScriptionName `
                                -DestinationNetworkName $DestinationNetworkName `
                                -DestinationNetworkResourceGroupName $DestinationNetworkResourceGroupName -Verbose
                            
$tags=ProcessTags -tagKeys $tagKeys -tagValues $tagValues

#Change the context to the migtation subscription
Set-AzContext -Subscription $MigrateSubscriptionName | out-null
#Get the vault object
$vault = Get-AzRecoveryServicesVault -Name $RecoveryVault -ResourceGroupName $RecoveryVaultResourceGroup
#Set the Recovery Services vault context
Set-AzRecoveryServicesAsrVaultContext -Vault $vault | out-null
#Retrieve the protection container(s) that corresponds to the site, as follows:
$protectionContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $(Get-AzRecoveryServicesAsrFabric)
#Retrieve the protection container mapping.
$ProtectionContainerMapping = Get-AzRecoveryServicesAsrProtectionContainerMapping -ProtectionContainer $protectionContainer[0]
#Enable VM protection

#Retrieve the protectable item from the protection container, that corresponds to the VM you want to protect
$ProtectableItem = Get-AzRecoveryServicesAsrProtectableItem `
        -ProtectionContainer $protectionContainer `
        -FriendlyName $VMFriendlyName
#Create a new DR job to start the replication
$DRjob = New-AzRecoveryServicesAsrReplicationProtectedItem `
 -ProtectableItem $ProtectableItem `
 -Name $ProtectableItem.FriendlyName `
 -ProtectionContainerMapping $ProtectionContainerMapping `
 -RecoveryAzureStorageAccountId $DestinationStorageAccountID `
 -OSDiskName $($ProtectableItem.Disks[0].Name) `
 -OS $OSType `
 -SqlServerLicenseType $SqlServerLicenceType `
 -Size $DestinationSize `
 -UseManagedDisk $true `
 -RecoveryResourceGroupId $DestinationResourceGroupID `
 -RecoveryAvailabilityZone $DestinationAvailabilityZone `
 -RecoveryAzureNetworkId $DestinationNetworkId `
 -RecoveryAzureSubnetName $DestinationSubnetName `
 -RecoveryVmTag $tags `
 -DiskTag $tags `
 -RecoveryNicTag $tags




#Not able to use the parameter -LicenseType $WindowsLicenceType only supported by vmware
#LogStorageAccountId - Specifies the log or cache storage account Id to be used to store replication logs.
#RecoveryAvailabilitySetId = The ID of the AvailabilitySet to recover the machine to in the event of a failover.
#RecoveryProximityPlacementGroupId = Specify the proximity placement group Id to used by the failover Vm in target recovery region.
#RecoveryVmName = Name of the recovery Vm created after failover.

 #get the job
 $DRjob = Get-ASRJob -Job $DRjob
 #Loop through while replication job is submitted
 while (($DRjob.State -eq "InProgress") -or ($DRjob.State -eq "NotStarted")) {
    write-host "$(Get-Date -Format "HH:mm:ss") - $($DRjob.DisplayName) -  $($DRjob.StateDescription) - $($DRjob.TargetObjectName)"
    start-sleep 10;
    $DRjob = Get-ASRJob -Job $DRjob
}



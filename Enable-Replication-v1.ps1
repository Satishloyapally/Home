[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    $CsvFilePath
)

# Import the CSV file
$inputData = Import-Csv -Path $CsvFilePath

foreach ($row in $inputData) {
    $MigrateSubscriptionName = $row.MigrateSubscriptionName
    $RecoveryVault = $row.RecoveryVault
    $RecoveryVaultResourceGroup = $row.RecoveryVaultResourceGroup
    $VMFriendlyName = $row.VMFriendlyName
    $OSType = $row.OSType
    $WindowsLicenceType = $row.WindowsLicenceType
    $DestinationSubScriptionName = $row.DestinationSubScriptionName
    $DestinationResourceGroupName = $row.DestinationResourceGroupName
    $DestinationStorageAccountName = $row.DestinationStorageAccountName
    $DestinationStorageAccountResourceGroupName = $row.DestinationStorageAccountResourceGroupName
    $DestinationNetworkName = $row.DestinationNetworkName
    $DestinationSubnetName = $row.DestinationSubnetName
    $DestinationNetworkResourceGroupName = $row.DestinationNetworkResourceGroupName
    $DestinationSize = $row.DestinationSize
    $DestinationAvailabilityZone = $row.DestinationAvailabilityZone
    $SqlServerLicenceType = $row.SqlServerLicenceType
    $tagKeys = $row.tagKeys
    $tagValues = $row.tagValues
    $PrimaryVMNetworkName = $row.PrimaryVMNetworkName
    $backupNetworkName = $row.backupNetworkName

    Write-Verbose "MigrateSubscriptionName  = $($MigrateSubscriptionName)"
    Write-Verbose "RecoveryVault  = $($RecoveryVault)"
    Write-Verbose "RecoveryVaultResourceGroup  = $($RecoveryVaultResourceGroup)"
    Write-Verbose "VMFriendlyName  = $($VMFriendlyName)"
    Write-Verbose "OSType  = $($OSType)"
    Write-Verbose "WindowsLicenceType  = $($WindowsLicenceType)"
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
    Write-Verbose "PrimaryVMNetworkName  = $($PrimaryVMNetworkName)"
    Write-Verbose "backupNetworkName  = $($backupNetworkName)"

    Function ProcessTags($tagKeys, $tagValues) {
        $tagDict = [System.Collections.Generic.Dictionary[string, string]]::new()
        if ([string]::IsNullOrEmpty($tagKeys) -or [string]::IsNullOrEmpty($tagValues)) {
            Write-Host "Tag Key/Value not mentioned for: '$($VMFriendlyName)'"
        }
        else {
            $tagKeys = $tagKeys -split ","
            $tagValues = $tagValues -split ","
            if ($tagKeys.Count -ne $tagValues.Count) {
                Write-Host "Tag Key/Value count mismatch for: '$($VMFriendlyName)'"
                return $null
            }
            else {
                for ($i = 0; $i -lt $tagKeys.Count; $i++) {
                    $tagDict.Add($tagKeys[$i], $tagValues[$i])
                }
            }
        }
        return $tagDict
    }

    Function Get-DestinationResourceGroupID {
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
        Set-AzContext -Subscription $DestinationSubScriptionName | Out-Null
        Write-Verbose "Context changed to $DestinationSubScriptionName"
        Write-Verbose "Getting resource group id for $DestinationResourceGroupName"
        return (Get-AzResourceGroup -Name $DestinationResourceGroupName).ResourceId
    }

    Function Get-DestinationStorageAccountID {
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
        Set-AzContext -Subscription $DestinationSubScriptionName | Out-Null
        Write-Verbose "Context changed to $DestinationSubScriptionName"
        Write-Verbose "Getting Storage Account id for $DestinationStorageAccountName in $DestinationStorageAccountResourceGroupName"
        return (Get-AzResource -Name $DestinationStorageAccountName -ResourceGroupName $DestinationStorageAccountResourceGroupName).ResourceId
    }

    Function Get-DestinationNetworkID {
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
        Set-AzContext -Subscription $DestinationSubScriptionName | Out-Null
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

    $tags = ProcessTags -tagKeys $tagKeys -tagValues $tagValues

    # Change the context to the migration subscription
    Set-AzContext -Subscription $MigrateSubscriptionName | Out-Null

    # Get the vault object
    $vault = Get-AzRecoveryServicesVault -Name $RecoveryVault -ResourceGroupName $RecoveryVaultResourceGroup

    # Set the Recovery Services vault context
    Set-AzRecoveryServicesAsrVaultContext -Vault $vault | Out-Null

    # Retrieve the protection container(s) that corresponds to the site
    $protectionContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $(Get-AzRecoveryServicesAsrFabric)

    # Retrieve the protection container mapping
    $ProtectionContainerMapping = Get-AzRecoveryServicesAsrProtectionContainerMapping -ProtectionContainer $protectionContainer[0]

    # Enable VM protection
    # Retrieve the protectable item from the protection container that corresponds to the VM you want to protect
    $ProtectableItem = Get-AzRecoveryServicesAsrProtectableItem `
        -ProtectionContainer $protectionContainer `
        -FriendlyName $VMFriendlyName

    # Create a new DR job to start the replication
    if ($tags -ne $null) {
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
    } else {
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
            -RecoveryAzureSubnetName $DestinationSubnetName
    }

    # Not able to use the parameter -LicenseType $WindowsLicenceType only supported by VMware
    # LogStorageAccountId - Specifies the log or cache storage account Id to be used to store replication logs.
    # RecoveryAvailabilitySetId = The ID of the AvailabilitySet to recover the machine to in the event of a failover.
    # RecoveryProximityPlacementGroupId = Specify the proximity placement group Id to used by the failover Vm in target recovery region.
    # RecoveryVmName = Name of the recovery Vm created after failover.

    # Get the job
    $DRjob = Get-ASRJob -Job $DRjob

    # Loop through while replication job is submitted
    while (($DRjob.State -eq "InProgress") -or ($DRjob.State -eq "NotStarted")) {
        Write-Host "$(Get-Date -Format "HH:mm:ss") - $($DRjob.DisplayName) -  $($DRjob.StateDescription) - $($DRjob.TargetObjectName)"
        Start-Sleep 10
        $DRjob = Get-ASRJob -Job $DRjob
    }
}

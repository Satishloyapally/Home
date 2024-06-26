https://blog.sanjeebojha.com.np/2020/06/convert-premium-ssd-to-standard-hdd-in.html

$RG = "gc-kcenter-emea-sit-rg"
$VMNames = @("GBBE13V0814","GBEX15AS03VCN2")
$diskType ="StandardSSD_LRS"

foreach($VMName in $VMNames)
{
    try{
            Write-Host "Processing VM = $VMName"
            Stop-AzVM -ResourceGroupName $RG -Name $VMName -Force -NoWait
            $vm = Get-AzVM -ResourceGroupName $RG -Name $VMName
            while($vm.ProvisioningState -ne "Succeeded"){
                Start-Sleep -Seconds 10
                $vm = Get-AzVM -ResourceGroupName $RG -Name $VMName
            }
            # Get the data Disks
            $dataDisks = $vm.StorageProfile.DataDisks
            # Update each Data disk SKU to SSD
            foreach($dataDisk in $dataDisks){
                $disk = Get-AzDisk -ResourceGroupName $RG -DiskName $dataDisk.Name
                $disk.Sku.Name = $diskType
                $disk | Update-AzDisk
            }
            # Start the VM
            Start-AzVM -ResourceGroupName $RG -Name $VMName
        }
        catch{
            Write-Host "Failed to Update Disks for VM"
        }
}

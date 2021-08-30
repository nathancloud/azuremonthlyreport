# Connect to Azure Account
Connect-AzAccount
 
# Create Report Array
$report = @()
# Record all the subscriptions in a Text file  
$SubscriptionIds = Get-Content -Path "c:\inputs\Subscriptions.txt" 
Foreach ($SubscriptionId in $SubscriptionIds) 
    {
        $reportName = "VM-Details.csv_$((Get-Date).ToString('dd-mm-yyyy_hh-mm')).csv"
        
        # Select the subscription  
        Select-AzSubscription $subscriptionId
 
        # Get all the VMs from the selected subscription
        $vms = Get-AzVM
 
        # Get all the Public IP Address
        $publicIps = Get-AzPublicIpAddress
 
        # Get all the Network Interfaces
        $nics = Get-AzNetworkInterface | Where-Object{ $_.VirtualMachine -NE $null} 
        foreach ($nic in $nics) 
            { 
                # Creating the Report Header we have taken maxium 5 disks but you can extend it based on your need
                $ReportDetails = "" | Select-Object VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup, OSDiskName,OSDiskCaching, OSDiskSize, DataDiskCount, DataDisk1Name, DataDisk1Size,DataDisk1Caching, DataDisk2Name, DataDisk2Size,DataDisk2Caching, DataDisk3Name, DataDisk3Size,DataDisk3Caching,  DataDisk4Name, DataDisk4Size,DataDisk4Caching, DataDisk5Name, DataDisk5Size,DataDisk5Caching
                #Get VM IDs
                $vm = $vms | Where-Object -Property Id -eq $nic.VirtualMachine.id 
                foreach($publicIp in $publicIps) 
                    { 
                        if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) 
                            {
                                $ReportDetails.PublicIPAddress = $publicIp.ipaddress
                            } 
                    }        
                $ReportDetails.OsType = $vm.StorageProfile.OsDisk.OsType 
                $ReportDetails.VMName = $vm.Name 
                $ReportDetails.ResourceGroupName = $vm.ResourceGroupName 
                $ReportDetails.Region = $vm.Location 
                $ReportDetails.VmSize = $vm.HardwareProfile.VmSize
                $ReportDetails.VirtualNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
                $ReportDetails.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
                $ReportDetails.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
                $ReportDetails.NicName = $nic.Name 
                $ReportDetails.ApplicationSecurityGroup = $nic.IpConfigurations.ApplicationSecurityGroups.Id 
                $ReportDetails.OSDiskName = $vm.StorageProfile.OsDisk.Name 
                $ReportDetails.OSDiskSize = $vm.StorageProfile.OsDisk.DiskSizeGB
                $ReportDetails.OSDiskCaching = $vm.StorageProfile.OsDisk.Caching
                $ReportDetails.DataDiskCount = $vm.StorageProfile.DataDisks.count
 
                if ($vm.StorageProfile.DataDisks.count -gt 0)
                    {
                        $disks= $vm.StorageProfile.DataDisks
                        foreach($disk in $disks)
                            {
                                If ($disk.Lun -eq 0)
                                    {
                                        $ReportDetails.DataDisk1Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
                                        $ReportDetails.DataDisk1Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
                                        $ReportDetails.DataDisk1Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
                                    }
                                elseif($disk.Lun -eq 1)
                                    {
                                       $ReportDetails.DataDisk2Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
                                        $ReportDetails.DataDisk2Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
                                        $ReportDetails.DataDisk2Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
                                    }
                                elseif($disk.Lun -eq 2)
                                    {
                                        $ReportDetails.DataDisk3Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
                                        $ReportDetails.DataDisk3Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
                                        $ReportDetails.DataDisk3Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
                                    }
                                elseif($disk.Lun -eq 3)
                                    {
                                        $ReportDetails.DataDisk4Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
                                        $ReportDetails.DataDisk4Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
                                        $ReportDetails.DataDisk4Caching =$vm.StorageProfile.DataDisks[$disk.Lun].Caching 
                                    }
                                elseif($disk.Lun -eq 4)
                                    {
                                        $ReportDetails.DataDisk5Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
                                        $ReportDetails.DataDisk5Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
                                        $ReportDetails.DataDisk5Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
                                    }
                        }
                    }
                 $report+=$ReportDetails 
            } 
    }
$report | Format-Table VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup, OSDiskName, OSDiskSize, DataDiskCount, DataDisk1Name, DataDisk1Size  
#Change the path based on your convenience
$report | Export-CSV "c:\outputs\$reportName"
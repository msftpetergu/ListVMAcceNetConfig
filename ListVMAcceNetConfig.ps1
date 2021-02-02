PARAM (
    [Parameter(Mandatory=$false)]$FileName = "ListVMAcceNet_" + (Get-Date -Format FileDateTimeUniversal) +  ".csv"
)

$colVM = @()
foreach ($SubID in (Get-AzSubscription)) {
    Select-AzSubscription -SubscriptionId $SubID.Id
    if ((Get-AzResourceGroup | Get-AzVM).Count -gt 0) {
        Get-AzNetworkInterface | % {
            # Extract VM Name from NIC.VirtualMachine.Id
            $VMName = $_.VirtualMachine.Id -match "virtualMachines/(.+)" | %{$Matches[1]}
            if ($VMName) {
                $VM = Get-AzVM -Name $VMName
                $objVMNICs = New-Object System.Object
                $objVMNICs | Add-Member -Type NoteProperty -Name SubscriptionId -Value $SubID.Id
                $objVMNICs | Add-Member -Type NoteProperty -Name SubscriptionName -Value $SubID.Name
                $objVMNICs | Add-Member -Type NoteProperty -Name Location -Value $_.Location
                $objVMNICs | Add-Member -Type NoteProperty -Name ResourceGroup -Value $_.ResourceGroupName
                $objVMNICs | Add-Member -Type NoteProperty -Name VM -Value $VM.Name
                $objVMNICs | Add-Member -Type NoteProperty -Name Size -Value $VM.HardwareProfile.VmSize
                $objVMNICs | Add-Member -Type NoteProperty -Name AN -Value $_.EnableAcceleratedNetworking
                $colVM += $objVMNICs
            }
        }
    }
}
$colVM | epcsv -NoTypeInformation $FileName
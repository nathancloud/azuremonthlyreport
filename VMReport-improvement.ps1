Connect-AzAccount
Get-AzSubscription
Select-AzSubscription "HIT_IMC_Support_General_AZ_PLAN"
Get-AzVM
Get-Help *get*disk*
Get-AzDisk | Select-Object {$_.Name}
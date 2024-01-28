function Add-Entity()
{
 [CmdletBinding()]

 param
 (
 $table, 
 [string] $partitionKey, 
 [string] $rowKey, 
 [double] $Latitude, 
 [double] $Longitude,
 [string] $City,
 [string] $StateID,
 [string] $StateName,
 [string] $CountyFIPS,
 [string] $CountyName,
 [string] $TimeZone
 )

 $entity = New-Object -TypeName Microsoft.WindowsAzure.Storage.Table.DynamicTableEntity -ArgumentList $partitionKey, $rowKey 
 $entity.Properties.Add("lat", $Latitude)
 $entity.Properties.Add("lng", $Longitude)
 $entity.Properties.Add("city", $City)
 $entity.Properties.Add("state_id", $StateID)
 $entity.Properties.Add("state_name", $StateName)
 $entity.Properties.Add("county_fips", $CountyFIPS)
 $entity.Properties.Add("county_name", $CountyName)
 $entity.Properties.Add("timezone", $TimeZone)

 $result = $table.CloudTable.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::Insert($entity))
 Write-Output $result
}

Clear-Host
$subscriptionName = "Azure subscription 1"
$resourceGroupName = "DefaultResourceGroup-EUS"
$storageAccountName = "jlhteststorage"
$tableName = "ZipCodes"

# Log on to Azure and set the active subscription
Add-AzureRMAccount
Select-AzureRmSubscription -SubscriptionName $subscriptionName

# Get the storage key for the storage account
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]

# Get a storage context
$ctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Get a reference to the table
$table = Get-AzureStorageTable -Name $tableName -Context $ctx 

# Get data from the CSV file
$csv = Import-CSV -Path .\uszips_edited.csv

# Loop through the rows in the file and add an entity to the ZipCodes table
ForEach ($line in $csv)
{
 Add-Entity -Table $table -partitionKey $line.PartitionKey -rowKey $line.RowKey -Latitude $line.lat -Longitude $line.lng -City $line.city -StateID $line.state_id -StateName $line.state_name -CountyFIPS $line.county_fips -CountyName $line.county_name -TimeZone $line.timezone
}

Write-Output "Finished"

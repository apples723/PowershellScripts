#works with remote machines too as long as you have remote wmi access to the machine....
$StartChoice = Read-Host "Computer Name(1) or Service Tag(2)"
if($StartChoice -eq 1){
	$Computer = Read-Host "Enter Computer Name"
	$InputSTAG = gwmi win32_bios -cn $Computer -EA SilentlyContinue -ErrorVariable WMIError  | select SerialNumber 
    if($WMIError){
        Write-Host "WMI Error - Either hostname is wrong or WMI is broken or offline!" -ForegroundColor Red
	Sleep 10
        Break
    }

	$InputSTAG = $InputSTAG.SerialNumber
}
Elseif($StartChoice -eq 2){
	$InputSTAG = Read-Host "Enter Service Tag"
}
else{
    Write-Host "Please enter 1 or 2 for your selection!!" -ForegroundColor Red
    Sleep 10
    Break
}


#Creates URL with API
$DellApiKey = "apikey"
$DellAPIURL = "https://sandbox.api.dell.com/support/assetinfo/v4/getassetwarranty/" + $InputSTAG + "?apikey=" + $DellApiKey
#Gets JSON data from DELL
$DellJSONData = (new-object System.Net.WebClient).DownloadString($DellAPIURL)

#Converts Dell JSON data to Powershell Object
$WarrantyPreObj = ConvertFrom-JSON($DellJSONData)


$WarrantyObj = @{
	 ServiceTag = $WarrantyPreObj.AssetWarrantyResponse.AssetHeaderData.ServiceTag
	 ShipDate = $WarrantyPreObj.AssetWarrantyResponse.AssetHeaderData.ShipDate
	 Model = $WarrantyPreObj.AssetWarrantyResponse.AssetHeaderData.MachineDescription
	 WarrantyEndDate = $WarrantyPreObj.AssetWarrantyResponse.AssetEntitlementData.EndDate[0]
}

Write-Host "`n"
Write-Host "Dell Asset Info" -ForegroundColor Magenta
Write-Host "Service Tag:" $WarrantyObj.ServiceTag -ForegroundColor Yellow
Write-Host "Ship Date:" $WarrantyObj.ShipDate -ForegroundColor Yellow
Write-Host "Warranty End Date:" $WarrantyObj.WarrantyEndDate -ForegroundColor Yellow
Write-Host "Model:" $WarrantyObj.Model -ForegroundColor Yellow


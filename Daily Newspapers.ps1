write-host  "Front Pages: Designed for Digital Signage displays in Portrait orientation"
write-host  "Deleting Existing Files"

$refreshTime = 20
$resWidth = "100%"
$resHeight = "100vh"
$myDocs = [Environment]::GetFolderPath("MyDocuments")
$saveFolder ="Newspapers"
$userFolder = $myDocs + "\" + $saveFolder 
#write-host  "User Folder: " + $userFolder 
$uncPath = "{0}" -f ($userFolder -replace "\\", "/" -replace " ", "%20")
write-host  "UNC Path Download: " + $uncPath

if (-not (Test-Path $userFolder)) {
    write-host  "Creating Folder $userFolder"
    New-Item -Path "$myDocs" -Name "$saveFolder" -ItemType "directory"
}

Remove-Item "$userFolder\*.*" | Where { ! $_.PSIsContainer }

$todayDate = Get-Date
$todayDay = $todayDate.Day
$newspapersURL ="http://cdn.freedomforum.org/dfp/pdf" + [string]$todayDay + "/"

[string[]]$frontpagesArray = @("CA_BC","CA_VCS","CA_MN","CA_MCH","CA_LR","UK_TG","IL_RRS","SD_RCJ","IL_CT","IL_LCNS","IL_DH","DC_WP","NY_NYT","IL_SJR","WI_MJS","CHI_CD","JPN_AS","MEX_REF","PHI_PDI","SKOR_CI","IND_AGE","EGY_DNE","BRA_OE","OH_CD", "MO_NT", "CA_LAT","RUS_MP","CA_SDUT","ICE_FRET","TX_TRN","SKOR_JAI","POL_GO","CAN_VS","VEN_EN","EGY_DNE","ARG_ET","SUD_ALJ","NEWZ_NZH","AUS_WA","CAN_TS", "ROM_IZ", "LITH_KD", "FIJI_FT")
[int]$nCounter = 1


foreach ($frontpage in $frontpagesArray) {
  "$frontpage = " + $frontpage.length
  $source = $newspapersURL + $frontpage + ".pdf"   
 try { 
      $response = Invoke-WebRequest -Uri $source -TimeoutSec 40 -ErrorAction:Stop
      #write-host  "Attempting Download $nCounter : $source"
      # Download the File & Increment file name counter      
      $destination = "$uncPath/$nCounter.pdf" 
      #write-host "Attempting Writing File: $destination"
      $CurrentProgressPref = $ProgressPreference
      $ProgressPreference = "SilentlyContinue"
      Invoke-WebRequest -Uri $source -OutFile $destination
      $nCounter += 1 
      $ProgressPreference = $CurrentProgressPref      
 } 
 catch {
      write-host  "Does Not Exist: $source"
      #$_.Exception.Response.StatusCode.Value__
 } 
}

$html= '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' + "`n"
$html = $html + '<html>' + "`n"
$html = $html + '<head>'  + "`n"
$html = $html + '<title></title>' + "`n"
$html = $html + '<meta name="viewport" content="width=device-width, initial-scale=1">' + "`n"
$html = $html + '<meta http-equiv="refresh" content="{0}">' -f $refreshTime + "`n"
$html = $html + '<meta charset="UTF-8">' + "`n"
$html = $html + '</head>' + "`n"
$html = $html + '<body bgcolor="#525659" style="overflow: hidden">' + "`n"
$html = $html + '<p id="PDFFrontPage"></p>' + "`n"
$html = $html + '<script type="text/javascript">' + "`n"
$html = $html + '(function frontpageFunction(){' + "`n"
$html = $html + 'var url_extension = ".pdf";' + "`n"
$html_sub = @"
var pdf_parameters = '#page=1&toolbar=0&navpanes=0&view=FitH,0&scrollbar=0\"';
"@                                                                                          

$html = $html + $html_sub + "`n"
$html = $html + 'var url_page = "{0}/"' -f $uncPath
$html = $html + "`n" 
$html = $html + 'var n = (Math.floor(Math.random() * (' + [string]$nCounter + '))+1);' + "`n"
$html = $html + 'var nString = n.toString();' + "`n"   
$html = $html + 'var url = "" + url_page + nString + "" + url_extension;' + "`n"
$html = $html + 'document.getElementById("PDFFrontPage").innerHTML = "<iframe src=\"" + url + "" + pdf_parameters + "\" style=\"width:{0}; height:{1};\" frameborder=\"0\" scrolling=\"no\"></iframe>";' -f $resWidth, $resHeight + "`n"
$html = $html + 'if (url.statusCode === "404"){' + "`n"
$html = $html + 'window.location.reload();' + "`n"
$html = $html + '}' + "`n"
$html = $html + '})();' + "`n"
$html = $html + '</script>' + "`n"  
$html = $html + '</body>' + "`n"
$html = $html + '</html>' + "`n"
$html | Out-File $userFolder\news2.html


$totalDownloads = $nCounter - 1
$totalRequests = $frontpagesArray.Count

write-host  "Downloaded $totalDownloads out of $totalRequests requests."  

try{
    Stop-Process -processname chrome
}
catch{
    write-host  "No Chrome browser found to reset"     
}

$command = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
$params =  '--profile-directory="Profile 1" --incognito --kiosk file://{0}/news2.html --hide-scrollbars --start-fullscreen' -f $uncPath
#overscroll-history-navigation=0
Start-Process -FilePath "$command" -ArgumentList "$params"
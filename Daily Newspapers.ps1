write-host  "Designed for Digital Signage displays in Portrait orientation"
write-host  "Deleting Existing Files"

$refreshTime = 10
$myDocs = [Environment]::GetFolderPath("MyDocuments")
$saveFolder ="Newspapers"
$userFolder = $myDocs + "\" + $saveFolder 
write-host  "User Folder: " + $userFolder 
$uncPath = "{0}" -f ($userFolder -replace "\\", "/" -replace " ", "%20")
write-host  "UNC Path Download: " + $uncPath


New-Item -Path "$myDocs" -Name "$saveFolder" -ItemType "directory"
Remove-Item "$userFolder\*.*" | Where { ! $_.PSIsContainer }

$todayDate = Get-Date
$todayDay = $todayDate.Day
$newspapersURL ="http://cdn.freedomforum.org/dfp/pdf" + [string]$todayDay + "/"

[string[]]$frontpagesArray = @("CA_BC","CA_VCS","CA_MN","CA_MCH","CA_LR","UK_TG","IL_RRS","IL_CT","IL_LCNS","IL_DH","DC_WP","NY_NYT","IL_SJR","WI_MJS","CHI_CD","JPN_AS","MEX_REF","PHI_PDI","SKOR_CI","IND_AGE","EGY_DNE","BRA_OE","OH_CD", "MO_NT", "CA_LAT","RUS_MP","ICE_FRET","SKOR_JAI","POL_GO","CAN_VS","VEN_EN","EGY_DNE","SUD_ALJ","NEWZ_NZH","AUS_WA","QATAR_AS","CAN_TS","HUN_EM")
[int]$nCounter = 0


foreach ($frontpage in $frontpagesArray) {
  "$frontpage = " + $frontpage.length
  $source = $newspapersURL + $frontpage + ".pdf"   
 try { 
      $response = Invoke-WebRequest -Uri $source -TimeoutSec 40 -ErrorAction:Stop
      write-host  "Attempting Download: $source" 
      # Download the File & Increment file name counter      
      $nCounter += 1 
      $destination = "$uncPath/$nCounter.pdf" 
      write-host "Attempting Writing File: $destination"
      $CurrentProgressPref = $ProgressPreference
      $ProgressPreference = "SilentlyContinue"
      Invoke-WebRequest -Uri $source -OutFile $destination
      $ProgressPreference = $CurrentProgressPref      
 } 
 catch {
      write-host  "Does Not Exist: " + $source
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
$html = $html + 'var url_page = "{0}"' -f $uncPath
$html = $html + "`n" 
$html = $html + 'var n = (Math.floor(Math.random() * (' + [string]$nCounter + ')+1));' + "`n"
$html = $html + 'var nString = n.toString();' + "`n"   
$html = $html + 'var url = "" + url_page + nString + "" + url_extension;' + "`n"
$html = $html + 'document.getElementById("PDFFrontPage").innerHTML = "<iframe src=\"" + url + "" + pdf_parameters + "\" style=\"width:100%; height:100vh;\" frameborder=\"0\" scrolling=\"no\"></iframe>";' + "`n"
$html = $html + 'if (url.statusCode === "404"){' + "`n"
$html = $html + 'window.location.reload();' + "`n"
$html = $html + '}' + "`n"
$html = $html + '})();' + "`n"
$html = $html + '</script>' + "`n"  
$html = $html + '</body>' + "`n"
$html = $html + '</html>' + "`n"
$html | Out-File $userFolder\news2.html

try{
    Stop-Process -processname chrome
}
catch{
    write-host  "No Chrome browser found to reset"     
}

$command = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
$params =  '--profile-directory="Profile 1" --incognito --kiosk file://{0}/news2.html"' -f $uncPath
$process = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe --profile-directory="Profile 1" --incognito --kiosk file://{0}/news2.html"' -f $uncPath
write-host "Chrome app: $process"
& "$command" $params
Start-Process -FilePath "$command" -ArgumentList "$params"
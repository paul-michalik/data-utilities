# Novatel-PostProcessed-To-Csv.ps

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$inputFile,
	
   [Parameter(Mandatory=$True,Position=2)]
   [string]$outputFile
)

if(Test-Path $inputFile) {
    $inputFile
    $outputFile

    Get-Content $inputFile `
        | Where-Object { $_ -match '^\s{6}Week|^\d{4}\.\d{5}' } `
        | ForEach-Object { $_ -replace '(\d{2}) (\d{2}) (\d{2}\.\d{5})', '$1-$2-$3' } `
        | ForEach-Object { [string]$_.TrimStart() } `
        | ForEach-Object { $_ -replace '\s+', ',' }

}
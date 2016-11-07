# Novatel-PostProcessed-To-Csv.ps

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$inputFile,
	
   [Parameter(Mandatory=$True,Position=2)]
   [string]$outputFile
)

if(Test-Path $inputFile) {
    Get-Content $inputFile `
        | ForEach-Object { $_ -replace '(\d{2}) (\d{2}) (\d{2}\.\d{5})','$1-$2-$3' }

    $inputFile
    $outputFile
}
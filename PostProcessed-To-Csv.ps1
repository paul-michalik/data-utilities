# Novatel-PostProcessed-To-Csv.ps

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [System.IO.Path]$inputFile,
	
   [Parameter(Mandatory=$True)]
   [System.IO.Path]$outputFile
)

$inputFile

$outputFile
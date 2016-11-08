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
        | ForEach-Object {
            $csv_line = ($_ -replace '(\d{2}) (\d{2}) (\d{1,2}\.\d{5})', '$1-$2-$3').TrimStart() -replace '\s+', ','
            
            Write-Host "current line:" 
            $csv_line
            
            $csv_line_decimal = ""
            $csv_line_index_ranges = @(0);
            foreach ($match in ($csv_line | Select-String -AllMatches -Pattern '(\d{2})-(\d{2})-(\d{1,2}\.\d{5})').Matches) {                
                if ($match -and $match.Groups.Count -eq 4) {
                    Write-Host "Current group: " 
                    $match.Groups
                    
                    $csv_line_index_ranges += @($match.Groups[0].Index, $match.Groups[0].Index + $match.Groups[0].Length)
                    
                    Write-Host "position deg min sec:" $match.Groups[1].Value $match.Groups[2].Value $match.Groups[3].Value
                
                    $position_decimal = `
                        [double]$match.Groups[1].Value + `
                            [double]$match.Groups[2].Value/60.0 + `
                                [double]$match.Groups[3].Value/3600.0;
            
                    Write-Host "position decimal:" $position_decimal
                   
                }
            }
        } `
        #| Out-File $outputFile

}
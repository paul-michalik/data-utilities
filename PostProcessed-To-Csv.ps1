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

    Get-Content $inputFile | 
        Where-Object { $_ -match '^\s{6}Week|^\d{4}\.\d{5}' } | 
        ForEach-Object {
            $csv_line = ($_ -replace '(\d{2}) (\d{2}) (\d{1,2}\.\d{5})', '$1-$2-$3').TrimStart() -replace '\s+', ','
            
            Write-Host "current line:"
            Write-Host $csv_line
            
            $csv_line_decimal = ""
            $csv_line_index_ranges = @(0);
            foreach ($match in ($csv_line | Select-String -AllMatches -Pattern '(\d{2})-(\d{2})-(\d{1,2}\.\d{5})').Matches) {                
                if ($match -and $match.Groups.Count -eq 4) {
                    $pos = New-Object PsCustomObject -Prop @{
                        Raw = $match.Groups[0]
                        Deg = [double]$match.Groups[1].Value
                        Min = [double]$match.Groups[2].Value
                        Sec = [double]$match.Groups[3].Value
                    }
                    Write-Host "Current group:" $pos.Raw.Value "range:" `
                        $pos.Raw.Index "-" ($pos.Raw.Index + $pos.Raw.Length).ToString()
                    
                    $csv_line_index_ranges += @($pos.Raw.Index, ($pos.Raw.Index + $pos.Raw.Length))

                    $position_decimal = $pos.Deg + $pos.Min/60.0 + $pos.Sec/3600.0;
                                                    
                    Write-Host "position:" $pos.Deg $pos.Min $pos.Sec "->" $position_decimal
                   
                }
            }
            #add max range
            $csv_line_index_ranges += $csv_line.Length
            #remove duplicates
            $csv_line_index_ranges = $csv_line_index_ranges | select -Unique
            Write-Host $csv_line_index_ranges

            for($range = 0; $range -lt ($csv_line_index_ranges.Count - 1); $range++) {
                $index = $csv_line_index_ranges[$range]
                $size = ($csv_line_index_ranges[($range + 1)] - $csv_line_index_ranges[$range])

                Write-Host "index, size:" $index $size
                $csv_line_decimal += $csv_line.Substring($index, $size)
                $csv_line_decimal     
            }
            $csv_line_decimal
        } | 
        Out-File $outputFile

}
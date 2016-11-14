# Novatel-PostProcessed-To-Csv.ps

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$inputFile,
	
   [Parameter(Mandatory=$True,Position=2)]
   [string]$outputFile
)

if(Test-Path $inputFile) {
    Get-Content $inputFile | 
        # Only consider lines which carry "load":  
        Where-Object { $_ -match '^\s{6}Week|^\d{4}\.\d{5}' } |  
        ForEach-Object { 
            # Convert to CSV format:
            $csv_line_org = ($_ -replace '(\d{2}) (\d{2}) (\d{1,2}\.\d{5})', '$1-$2-$3').TrimStart() -replace '\s+', ','
            
            # Convert position data from "degree minutes seconds" to decimal degrees, the data is collected in $csv_line_new.
            $csv_line_new = ""
            $csv_line_back_index = 0   
            foreach ($match in ($csv_line_org | Select-String -AllMatches -Pattern '(\d{2})-(\d{2})-(\d{1,2}\.\d{5})').Matches) {
                if ($match -and $match.Groups.Count -eq 4) {
                    $pos_raw_match = $match.Groups[0]
                    $pos_deg = [double]$match.Groups[1].Value
                    $pos_min = [double]$match.Groups[2].Value
                    $pos_sec = [double]$match.Groups[3].Value
                    
                    $pos_decimal = $pos_deg + $pos_min/60.0 + $pos_sec/3600.0;
                    
                    # Add position in decimal format to current line:
                    if ($csv_line_back_index -lt $pos_raw_match.Index) {
                        $csv_line_new += $csv_line_org.Substring($csv_line_back_index, ($pos_raw_match.Index - $csv_line_back_index))
                    }
                    $csv_line_new += [string]$pos_decimal;
                    $csv_line_back_index = ($pos_raw_match.Index + $pos_raw_match.Length)
                }
            }
            
            # Add reminder of original csv, (if any) or set to original csv (if no match) :
            if ($csv_line_back_index -lt $csv_line_org.Length) {
                $csv_line_new += $csv_line_org.Substring($csv_line_back_index, ($csv_line_org.Length - $csv_line_back_index))
            }
            
            return $csv_line_new
        } | 
        Out-File -FilePath $outputFile -Encoding "ASCII"

}
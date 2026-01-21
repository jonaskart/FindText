<#
.SYNOPSIS
Rapporterer antall hitt av en gitt string.

.DESCRIPTION
Skriptet søker rekursivt etter en streng, default path er hjemmemappen. Resultater blir vist med filen strengen ble funnet i og antall treff.

.PARAMETER Path
Rotmappe å søke i. Standard er brukerens hjemmemappe.

.PARAMETER Text
Texten du vil søke for treff etter.

.EXAMPLE
.\FindText.ps1 -Text "TEST"
Rapporterer antall treff for "TEST" under hjemmemappe

.EXAMPLE
.\FindText.ps1 -Path "C:\Temp" -Text "TEST"
Rapporterer antall treff for "TEST" under C:\Temp
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = $HOME,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Text = '.'
)

# Går gjennom filer rekursivt fra $Path
$Resultat = Get-ChildItem -Path $Path -Filter "*.txt" -File -Recurse -ErrorAction SilentlyContinue |
              ForEach-Object {
#$Antall blir telt opp for hvert treff av $Text
                $Antall =
    (Select-String -Path $_.FullName -Pattern $Text -AllMatches -ErrorAction SilentlyContinue).Matches.Count
    [pscustomobject]@{
            Fil    = $_.FullName
            Treff  = $Antall
        }
  } |
  Where-Object {$_.Treff -gt 0} |
  Sort-Object -Descending -Property Treff

#Sjekker først om det finnes resultat og sier ifra hvis ikke.
if ($Antall -lt 1) {
  Write-Output("Ingen treff av '$Text' funnet under '$Path'")
}
else {
  $Resultat | Format-Table -AutoSize
}

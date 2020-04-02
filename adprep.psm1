###############################################################################################
#
# Skriptname:  adprep.psm1
# Autor:       F. Dort
# Datum:       2. April 2020
# Funktion:    Dieses Modul beinhaltet alle Funktionen für die AD Vorbereitung
#
# Version:     1.0
#
###############################################################################################

function New-ADStructure {
    <#
        .SYNOPSIS
        Die Funktion erstellt die OU-Struktur im Active Directory.
    
        .DESCRIPTION
        In dieser Funktion wird die Grundstruktur der OUs im AD erstellt. Domainname, TLD, erste
        OU und die Standorte werden mitgegeben. Anhand dieser Infos erstellt die Funktion die
        Struktur.
    
        .PARAMETER domain
        DOMAIN beinhaltet die Domain (z.B. intra.muster)

        .PARAMETER tld
        TLD beinhaltet die TLD (z.B. ch)

        .PARAMETER firstOU
        FIRSTOU beinhaltet den Namen der obersten OU der neuen Struktur (z.B. MUSTERFIRMA)

        .PARAMETER standorte
        STANDORTE beinhaltet alle gewuenschten Standorte (z.B. Schaan, Vaduz, St. Gallen)
    
        .EXAMPLE
        New-ADStructure -domain $domain -tld $tld -firstOU $firstOU -standorte $standorte
    
        .NOTES
        Die Funktion erstellt die AD-Struktur internem Standard.

    #>
    
        param(
            [parameter(mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]$domain,
            [parameter(mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]$tld,
            [parameter(mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]$firstOU,
            [parameter(mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [array]$standorte

        )
    
        Process {
            $intTiefe=0
            $strTiefe = New-Object System.Collections.ArrayList
    
            # benoetigte Informationen
            $firstOU = $VM_Infos.AD.AD_Structure.ouFirma
            $strAD = (Get-ADDomain).DistinguishedName
    
            # AD Struktur
            # + bedeutet einen Schritt tiefer
            # - bedeutet einen Schritt hoeher
            # z.b. "Firma","+","Standort" --> OU=Standort,OU=Firma,DC=domain,DC=tld
    
            # Array beginnen
            $strArr = $firstOU,"+"
            foreach ($strStandort in $standorte) {
                    $strArr += $strStandort,"+","Benutzer","Notebook","Computer","-"
            }
    
            $strArr += "Global","+","Laufwerke","Mitgliedserver","Benutzer","Gateway","Kontakte","Gruppen","+",`
                       "Systemgruppen","Dateiberechtigungen","Druckerzuweisung", "Softwaregruppen", "Outlookberechtigungsgruppen",`
                       "Verteilerlisten"
    
    
            # Main Program do not touch
            Foreach ($strTmpArr in $strArr) {
                if ($strTmpArr -eq "+") {
                    $nul = $strTiefe.Add($strTemp)
                    $intTiefe++
                }
        
                if ($strTmpArr -eq "-") {
                    $intTiefe--
                    $nul = $strTiefe.RemoveAt($intTiefe)
                }
    
                if ($strTmpArr -eq $strStandort) {
                    $strTmpArr = $strStandort
                }
        
                if ($strTmpArr -eq $firstOU) {
                    $strTmpArr = $firstOU
                }
    
                $strforTmp=""
                $intCount = $strTiefe.Count
                While ($intCount -gt 0) {
                    $strTmpTiefe=$strTiefe.Item($intCount-1)
                    $strforTmp+="OU="+($strTmpTiefe -replace('\n',''))+ ","
                    $intCount--
                }
        
    
                if  (($strTmpArr -eq "+") -or ($strTmpArr -eq "-")) {
                } else {
                $strTmpArr = ($strTmpArr -replace('\n',''))
                $strTmpPath = $strforTmp.ToString()+""+ $strAD.ToString()
                New-ADOrganizationalUnit -Name $strTmpArr -Path $strTmpPath
                $strTemp=$strTmpArr
                }
            }
    
        }
    
    }
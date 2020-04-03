<#########################################################################

Skriptname:     AD_Prep.ps1
Funktion:       Anlegen der Basisstruktur in der AD
Erstellt am:    25.11.2014
Author:         N.Viragh / F. Dort
Version:        1.2

Aenderungen:
23.3.2020       Fehler korrigiert
02.04.2020      Modul import, Funktion hinzugefügt, wiederholende cmdlets
                entfernt
03.04.2020      Loops eingefügt, wiederholende cmdlets entfernt

#>
##########################################################################

# Variabeln deklarieren
$module = "adprep.psm1"
$dfsfolders = "profiles","homes", "SWInstall", "UserSharedFolders"

# Modul importieren
Import-Module $module -Force

# Abfrage Domänenname

$domainname = Read-Host "Geben Sie den Domänennamen ein.(ohne TLD) > "

# Abfrage TDL

$TLD = Read-Host "Geben Sie die TLD ein. > "

# Abfrage Name erste OU

$firstOU = Read-Host "Geben Sie den Namen der ersten OU ein. > "

# Abfrage Standortname

$standorte = Read-Host "Geben Sie die Standorte ein. > "

# Funktion aufrufen und Parameter mitgeben
New-ADStructure -domain $domainname -tld $TLD -firstOU $firstOU -standorte $standorte

##################################################################################################

#Ordnerstruktur für Freigaben anlegen

#Abfrage Datenpfad

$Laufwerkspfad = Read-Host " Geben Sie den Laufwerksbuchstaben an auf dem die Struktur erstellt werden soll! z.B: D:\ "

# Abfrage Über-Ordner zb. DFS-Datenpool

$Ordnername = Read-Host " Geben Sie nun den ersten Ordnernamen an"

# Erstellung der Struktur

New-Item -Path $Laufwerkspfad -Name $Ordnername -ItemType directory

foreach ($folder in $dfsfolders) {
    New-Item -Path $Laufwerkspfad$Ordnername -Name $folder -ItemType directory
}

# Erstellung der Freigaben der Ordner mit FullAccess Everyone

foreach ($sharefolder in $dfsfolders) {
    New-SmbShare $Laufwerkspfad$Ordnername\$folder -Name $folder$ -FullAccess jeder
}

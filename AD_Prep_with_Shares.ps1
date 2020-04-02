<#########################################################################

Skriptname:     AD_Prep.ps1
Funktion:       Anlegen der Basisstruktur in der AD
Erstellt am:    25.11.2014
Author:         N.Viragh / F. Dort
Version:        1.1

Aenderungen:
23.3.2020       Fehler korrigiert
02.04.2020      Modul import, Funktion hinzugefügt, wiederholende cmdlets
                entfernt

#>
##########################################################################

# Variabeln deklarieren
$module = "adprep.psm1"

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

set-location -Path $Laufwerkspfad 

New-Item -Path $Laufwerkspfad -Name $Ordnername -ItemType directory
New-Item -Path $Laufwerkspfad$Ordnername -Name homes -ItemType directory
New-Item -Path $Laufwerkspfad$Ordnername -Name profiles -ItemType directory
New-Item -Path $Laufwerkspfad$Ordnername -Name SWInstall -ItemType directory
New-Item -Path $Laufwerkspfad$Ordnername -Name usersharedfolders -ItemType directory

# Erstellung der Freigaben der Ordner mit FullAccess Everyone

New-SmbShare $Laufwerkspfad$Ordnername\homes -Name homes$ -FullAccess jeder
New-SmbShare $Laufwerkspfad$Ordnername\profiles -Name profiles$ -FullAccess jeder
New-SmbShare $Laufwerkspfad$Ordnername\SWInstall -Name SWInstall$ -FullAccess jeder
New-SmbShare $Laufwerkspfad$Ordnername\usersharedfolders -Name usersharedfolders$ -FullAccess jeder

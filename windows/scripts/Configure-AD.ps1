<# Simple PowerShell script to configure AD

** users.csv file format **
Name,SurName,Title,Password,Groups
First,Last,"Job Title",SomeSecurePassword!@#,"Group 1,Group 2,Group 3"
#>

# Import modules:
Import-Module ActiveDirectory

# Script variables:
$domain_name = "beenhacked.com"
$netbios = "BEENHACKED"

# Enable AD
Install-ADDSForest -DomainName $domain_name -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "7" -DomainNetbiosName $netbios -ForestMode "7" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$True -SysvolPath "C:\Windows\SYSVOL" -Force:$true


# Add OU's for basic structure
New-ADGroup -Name "HR" -GroupCategory Security -GroupScope Global -Path "CN=Groups,DC=beenhacked,DC=com" -DisplayName "Human Resources" -Description "Members of this group have Rights to the Human Resources Group"
New-ADGroup -Name "Accounting" -Path "CN=Groups,DC=beenhacked,DC=com" -Description "Accounting Group"  -Description "Members of this group have Rights to Accounting resources"
New-ADGroup -Name "RandD" -Path "CN=Groups,DC=beenhacked,DC=com" -Description "Research and Development"  -Description "Members of this group have Rights to Research and Development projects"
New-ADGroup -Name "Employees" -Path "CN=Groups,DC=beenhacked,DC=com" -Description "All Employees"  -Description "Members of this group have Rights to the All Employees Group"
New-ADGroup -Name "Logistics" -Path "CN=Groups,DC=beenhacked,DC=com" -Description "Logistics Group"  -Description "Members of this group have Rights to Logistics"
New-ADGroup -Name "PenTest" -Path "CN=Groups,DC=beenhacked,DC=com" -Description "PenTest Group"  -Description "Members of this group have Rights to Penetration Testing resources"
New-ADGroup -Name "Mobile" -Path "CN=Groups,DC=beenhacked,DC=com" -Description "Mobile PenTest Group"  -Description "Members of this group have Rights to Mobile Penetration Testing resources"
New-ADGroup -Name "Forensics" -Path "CN=Groups,DC=beenhacked,DC=com" -Description "Forensics Group"  -Description "Members of this group have Rights to Forensics resources"

# Import users.csv file
$users = ".\users.csv"

# Add users to AD
import-csv $users | % {
	$acct = "$($_.Name)`.$($_.SurName)"
	$full = "$($_.Name)` $($_.SurName)"
    $email = "$($acct)`@$domain_name"
    $title = "$($_.Title)"
	New-AdUser -Name $full -Surname $_.SurName -GivenName $_.Name -DisplayName $full -samAccountName $acct -AccountPassword $(ConvertTo-SecureString $_.Password -AsPlainText -Force) -Path $_.path -Enable $True -OtherAttributes @{title=$title;mail=$email} -PasswordNeverExpires $True -CannotChangePassword $True -UserPrincipalName $email -PassThru

	($_.Groups).split(",") | % { Add-AdGroupMember -Identity $_ -Member $acct }
}
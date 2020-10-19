# Simple PowerShell script to install AD

# Script variables:
$dc_addr="192.168.100.5"
$gateway="192.168.100.1"
$dns="8.8.8.8"
$hostname="dc01"

New-NetIPAddress -InterfaceIndex 4 -IPAddress $dc_addr -PrefixLength 29 -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses ($dc_addr, $dns)

Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools

Rename-Computer -ComputerName $hostname -Restart

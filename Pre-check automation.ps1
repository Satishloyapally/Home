# Create a folder on the server to store migration information
New-Item -Path "C:\MGT\Script\" -Name "azuremig" -ItemType Directory

# Save a copy of the static routes
route print > C:\MGT\Script\azuremig\azmig-routeprint.txt

# Save a copy of the service status
Get-Service | Where-Object { $_.StartType -eq 'Automatic' } | 
    Select-Object Name, Status, StartType | 
    Out-File C:\MGT\Script\azuremig\azmig-automaticservice-pre.txt

# Save a copy of netstat -an
netstat -an > C:\MGT\Script\azuremig\netstat-pre.txt

# Add a security group to the TBA GROUP on the server
Add-LocalGroupMember -Group "Remote" -Member "TBA GROUP"

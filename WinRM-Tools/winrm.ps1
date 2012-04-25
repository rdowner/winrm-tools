# winrm.ps1
# winrm-tools https://github.com/rdowner/winrm-tools
# Copyright 2012 Richard Downer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Enable-WinRM {
	param (
		[Parameter(Position=0)] [string] $Hostname = ( hostname ),
		[Parameter()] [switch] $HostnameFromEC2,
		[Parameter()] [switch] $HostnameFromDNS
	)
	
	# Stop the script if an error occurs
	$ErrorActionPreference="Stop"
	
	# Test for the presence of the ServerManager module; install if not found
	if (-not(Get-Module -Name ServerManager)) {
		if (-not(Get-Module -ListAvailable | Where-Object {$_.Name -eq "ServerManager"})) {
			echo "Server Manager PowerShell commandlets not available. Installing..."
			Dism.exe /Online /Enable-Feature /FeatureName:ServerManager-PSH-Cmdlets
		}
		Import-Module ServerManager
	}
	
	# Test for the presence of the WinRM feature; install if not found
	echo "Checking WinRM IIS Extensions"
	if (-not( Get-WindowsFeature -Name WinRM-IIS-Ext | Where-Object { $_.Installed } )) {
		echo "Installing WinRM IIS Extensions"
		Add-WindowsFeature WinRM-IIS-Ext | Out-Null
	}

	# Configure WinRM
	Set-WSManInstance WinRM/Config/Service/Auth -ValueSet @{Basic = $true} | Out-Null
	Set-WSManInstance WinRM/Config/Service -ValueSet @{AllowUnencrypted = $true} | Out-Null
	Set-WSManInstance WinRM/Config/WinRS -ValueSet @{MaxMemoryPerShellMB = 1024} | Out-Null
	Set-WSManInstance WinRM/Config/Client -ValueSet @{TrustedHosts="*"} | Out-Null
	
	# Check if a suitable WinRM listener is available; create one if not
	try {
		$listenerRequired = (-not(Get-WSManInstance WinRM/Config/Listener -SelectorSet @{Address = "*"; Transport = "HTTPS"}))
	} catch [InvalidOperationException] {
		$listenerRequired = $true
	}
	if ($listenerRequired) {
	
		# Determine hostname to use in certificate
		if ($HostnameFromEC2) {
			$ec2hostname = (New-Object System.Net.WebClient).DownloadString("http://169.254.169.254/2011-01-01/meta-data/public-hostname")
			$Hostname = $ec2hostname
		}
		if ($HostnameFromDNS) {
			$dnshostname = [System.Net.Dns]::GetHostName()
			$Hostname = $dnshostname
		}
		echo "Using hostname: $Hostname"

		# Generate SSL certificate
		$certname = "CN=$Hostname"
		echo "Generating SSL certificate for: $certname"
		New-SelfSignedCertificate $certname
		
		# Get the thumbprints of the SSL certificates that match the hostname
		$thumbprints = Get-Childitem -path cert:\LocalMachine\My | Where-Object { $_.Subject -eq $certname } | Select-Object -Property Thumbprint
		# PowerShell magic to retrieve the first matching thumbprint (there'll probably only be one anyway)
		$thumbprint = @($thumbprints)[0].Thumbprint
		# Create a WinRM listener, identifying the SSL certificate by the thumbprint
		New-WSManInstance WinRM/Config/Listener -SelectorSet @{Address = "*"; Transport = "HTTPS"} -ValueSet @{Hostname = $hostname; CertificateThumbprint = $thumbprint} | Out-Null
	} else {
		echo "A WSManInstance already exists, so a new one won't be created"
	}
	
	Add-FirewallRule "Windows Remote Management HTTP/SSL" "5986" $null $null

	echo "Completed successfully."
}

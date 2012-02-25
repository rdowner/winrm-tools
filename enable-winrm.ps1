# enable-winrm.ps1
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

$targetdir = $( get-content env:USERPROFILE ) + "\Documents\WindowsPowerShell\Modules\WinRM-Tools"
New-Item -type directory -path $targetdir
$client = new-object System.Net.WebClient
$files = @("WinRM-Tools.psm1", "firewallrule.ps1", "selfsignedcert.ps1", "winrm.ps1")
foreach ($f in $files) { $client.DownloadFile("https://raw.github.com/rdowner/winrm-tools/master/WinRM-Tools/" + $f, $targetdir + "\" + $f) }
Import-Module WinRM-Tools
Enable-WinRM

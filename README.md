Important note about the license
================================

Original parts of this project are licensed under the [Apache License
2.0.][Apache2]

Unfortunately, portions of the project are based on content from
Microsoft's TechNet and MSDN websites, and downloads from these sites
are licensed under the [Microsoft Limited Public License
("MS-LPL")][MS-LPL]. This affects the following files:

 -  WinRM-Tools/selfsignedcert.ps1
 -  WinRM-Tools/firewallrule.ps1

The MS-LPL is included in the affected files.

This situation is less than ideal and I intend to remove these files,
once a suitable replacement is available. I welcome links to
equivalents under a more appropriate license, or volunteers to help
with a clean room rewrite.

[Apache2]: http://www.apache.org/licenses/LICENSE-2.0
[MS-LPL]: http://technet.microsoft.com/en-us/cc300389.aspx#P


Welcome
=======

This project is intended to ease the process of enabling Windows
Remote Management ("WinRM"). On an out-of-the-box install of Windows
Server 2008 R2, WinRM is not enabled or installed by
default. Installing it, and enabling it on an SSL-secured port, takes
many manual steps; this project is intended to automate this as much
as possible, reducing it to a one-liner.

Currently, the aim of the project is to assist in modifying a vanilla
Windows Server 2008 R2, configuring it to allow the
["overthere"][overthere] project to connect to the WinRM port in a
reasonably secure manner. While it's not exclusively limited to this
kind of setup, at the moment the scripts do make assumptions to that
end.

[overthere]: https://github.com/xebialabs/overthere


Usage
=====

When running on Windows Server 2008 R2, you can start a Command Prompt and execute this one-liner:

```
PowerShell -Command "Set-ExecutionPolicy RemoteSigned ; (new-object System.Net.WebClient).DownloadFile(\"https://github.com/rdowner/winrm-tools/raw/master/enable-winrm.ps1\", \"enable-winrm.ps1\") ; ./enable-winrm.ps1 -HostnameFromDNS"
```

This will configure WinRM for you. Part of this involves creating an
SSL certificate; the -HostnameFromDNS argument will use the system's
DNS name. You can instead replace this parameter with a string of the
hostname to use for the SSL certificate.


Amazon EC2
----------

Boot up an Amazon EC2 instance based on the [Amazon-provided Windows
Server 2008 R2 images][AMIs]. Log in using Remote Desktop as Administrator,
and open a Command Prompt window. Copy-and-paste this one-liner to
bootstrap the WinRM-Tools module, and activate WinRM:

```
PowerShell -Command "Set-ExecutionPolicy RemoteSigned ; (new-object System.Net.WebClient).DownloadFile(\"https://github.com/rdowner/winrm-tools/raw/master/enable-winrm.ps1\", \"enable-winrm.ps1\") ; ./enable-winrm.ps1 -HostnameFromEC2"
```

Re-seal the EC2 image:

```
"\Program Files\Amazon\Ec2ConfigService\Ec2Config.exe" -sysprep
```

Wait for SysPrep to run, and shut down the instance. Now create a new
AMI from the stopped instance.

Your new AMI will be configured with WinRM enabled on port 5986, using
HTTPS.

[AMIs]: http://aws.amazon.com/amis/Microsoft-Windows?browse=1

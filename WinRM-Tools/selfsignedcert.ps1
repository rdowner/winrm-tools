# This function is obtained from:
# http://blogs.technet.com/b/vishalagarwal/archive/2009/08/22/generating-a-certificate-self-signed-using-powershell-and-certenroll-interfaces.aspx
# licensed under the Microsoft Limited Public License, which is
# reproduced below.
# 
# MICROSOFT LIMITED PUBLIC LICENSE
# 
# This license governs use of code marked as “sample” or “example”
# available on this web site without a license agreement, as provided under
# the section above titled “NOTICE SPECIFIC TO SOFTWARE AVAILABLE ON THIS
# WEB SITE.” If you use such code (the “software”), you accept this
# license. If you do not accept the license, do not use the software.
# 
# 1. Definitions
# 
# The terms “reproduce,” “reproduction,” “derivative works,” and
# “distribution” have the same meaning here as under U.S. copyright law.
# 
# A “contribution” is the original software, or any additions or changes
# to the software.
# 
# A “contributor” is any person that distributes its contribution under
# this license.
# 
# “Licensed patents” are a contributor’s patent claims that read directly
# on its contribution.
# 
# 2. Grant of Rights
# 
# (A) Copyright Grant - Subject to the terms of this license, including the
# license conditions and limitations in section 3, each contributor grants
# you a non-exclusive, worldwide, royalty-free copyright license to
# reproduce its contribution, prepare derivative works of its contribution,
# and distribute its contribution or any derivative works that you create.
# 
# (B) Patent Grant - Subject to the terms of this license, including the
# license conditions and limitations in section 3, each contributor grants
# you a non-exclusive, worldwide, royalty-free license under its licensed
# patents to make, have made, use, sell, offer for sale, import, and/or
# otherwise dispose of its contribution in the software or derivative works
# of the contribution in the software.
# 
# 3. Conditions and Limitations
# 
# (A) No Trademark License- This license does not grant you rights to use
# any contributors’ name, logo, or trademarks.
# 
# (B) If you bring a patent claim against any contributor over patents that
# you claim are infringed by the software, your patent license from such
# contributor to the software ends automatically.
# 
# (C) If you distribute any portion of the software, you must retain all
# copyright, patent, trademark, and attribution notices that are present in
# the software.
# 
# (D) If you distribute any portion of the software in source code form,
# you may do so only under this license by including a complete copy of
# this license with your distribution. If you distribute any portion of the
# software in compiled or object code form, you may only do so under a
# license that complies with this license.
# 
# (E) The software is licensed “as-is.” You bear the risk of using it. The
# contributors give no express warranties, guarantees or conditions. You may
# have additional consumer rights under your local laws which this license
# cannot change. To the extent permitted under your local laws, the
# contributors exclude the implied warranties of merchantability, fitness
# for a particular purpose and non-infringement.
# 
# (F) Platform Limitation - The licenses granted in sections 2(A) and 2(B)
# extend only to the software or derivative works that you create that run
# on a Microsoft Windows operating system product.

function New-SelfSignedCertificate {
	param(
		$subject
	)

	$name = new-object -com "X509Enrollment.CX500DistinguishedName.1"
	$name.Encode($subject, 0)
	
	$key = new-object -com "X509Enrollment.CX509PrivateKey.1"
	$key.ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
	$key.KeySpec = 1
	$key.Length = 1024
	$key.SecurityDescriptor = "D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)"
	$key.MachineContext = 1
	$key.Create()
	
	$serverauthoid = new-object -com "X509Enrollment.CObjectId.1"
	$serverauthoid.InitializeFromValue("1.3.6.1.5.5.7.3.1")
	$ekuoids = new-object -com "X509Enrollment.CObjectIds.1"
	$ekuoids.add($serverauthoid)
	$ekuext = new-object -com "X509Enrollment.CX509ExtensionEnhancedKeyUsage.1"
	$ekuext.InitializeEncode($ekuoids)
	
	$cert = new-object -com "X509Enrollment.CX509CertificateRequestCertificate.1"
	$cert.InitializeFromPrivateKey(2, $key, "")
	$cert.Subject = $name
	$cert.Issuer = $cert.Subject
	$cert.NotBefore = get-date
	$cert.NotAfter = $cert.NotBefore.AddDays(90)
	$cert.X509Extensions.Add($ekuext)
	$cert.Encode()
	
	$enrollment = new-object -com "X509Enrollment.CX509Enrollment.1"
	$enrollment.InitializeFromRequest($cert)
	$certdata = $enrollment.CreateRequest(0)
	$enrollment.InstallResponse(2, $certdata, 0, "")
}

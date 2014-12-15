---
layout: default
title: "Generating QR Codes in HTML"
date: 2014-12-15
keywords: html, javascript
published: true
---

> TL;DR - When you generate QR codes which contain sensitive (confidential) information, do *not* use an external service to render the QR code images, but do it yourself. Thanks in the name of all your future customers. 

Yesterday, I tried 2-factor authentication (2FA) using the [Windows Phone Authenticator](http://www.windowsphone.com/en-us/store/app/authenticator/e7994dbc-2336-4950-91ba-ca22d653759b) app, and wondered how the overall system worked: Basically, it is an implementation of the [RFC6238 - TOTP: Time-Based One-Time Password Algorithm](http://tools.ietf.org/html/rfc6238) spec, which takes the UNIX epoch time in seconds modulo 30, and uses the rounded seconds and a symmetric key to derive a time based hash, and takes some bits from the resulting hash as integer-based PIN. 

For UX reasons, the symmetric key is imported into the Authenticator app via a QR code. The content of the QR code is a URI like ```otpauth://totp/Microsoft:user%40outlook.com?secret=AAAABBBBCCCCDDDD```. In this sample, the string ```Microsoft:user%40outlook.com``` is a textual identifier of the symmetric key (without any cryptographic significance), and the string ```AAAABBBBCCCCDDDD``` is the symmetric (secret, i.e. highly sensitive and confidential!!!) key, in [BASE32 encoding](http://www.crockford.com/wrmg/base32.html), i.e. just case-insensitive text and decimal digits. 

Looking for a sample, I found the cool [ASPNETIdentity_GoogleAuthenticator](https://github.com/beabigrockstar/ASPNETIdentity_GoogleAuthenticator) demo, which shows how to leverage 2FA in an ASP.NET app. The only bummer I found was the [view which displayed the QR code](https://github.com/beabigrockstar/ASPNETIdentity_GoogleAuthenticator/blob/067873f2aa7bfb3e0309e9f125cc3429b0b20932/ASPNETIdentity_GoogleAuthenticator/Views/Manage/EnableGoogleAuthenticator.cshtml): 

```HTML
<div class="col-md-4"> 
     <img src="http://qrcode.kaywa.com/img.php?s=4&d=@(Model.BarcodeUrl)"/> 
</div> 
```

To display the QR code with the embedded cryptographic key to the user, the sample used an external service to render the confidential URI. Drilling a bit deeper, the [ASPNETIdentity_GoogleAuthenticator](https://github.com/beabigrockstar/ASPNETIdentity_GoogleAuthenticator) uses the [OtpSharp NuGet package](https://bitbucket.org/devinmartin/otp-sharp/), and there, it [was again](https://bitbucket.org/devinmartin/otp-sharp/src/2820254eb66d6b04361655580d8d2c9f75960198/GoogleAuthenticatorTotpTest/GoogleAuthenticatorTotpTest.cs?at=default): 

```csharp
private void ResetTotp()
{
    this.totp = new Totp(rfcKey, this.stepSize, totpSize: this.digits);
    var name = this.textBoxKeyLabel.Text;
    if (string.IsNullOrWhiteSpace(name)) name = "OtpSharp@test.com";

    string url = KeyUrl.GetTotpUrl(rfcKey, name, step: this.stepSize, totpSize: this.digits);
    this.pictureBox1.ImageLocation = string.Format("http://qrcode.kaywa.com/img.php?s=4&d={0}", HttpUtility.UrlEncode(url));
}
```

The same thing: Using an existing service to display the probably most sensitive information a user has: The cryptographic key for a proof-of-possession token. *Don't do that* :-/. For pure browser-based QR code generation, a quick search surfaced two JavaScript libraries, [neocotic/qr.js](https://github.com/neocotic/qr.js/) (which is GPL3 licensed) and [davidshimjs/qrcodejs](https://github.com/davidshimjs/qrcodejs/) (which is MIT licensed). In the [QRCodeInHTML](https://github.com/chgeuer/QRCodeInHTML) repository, I played around with generating QR codes purely in a web app. You can try it out [here](/code/qr/). 


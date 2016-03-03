---
layout: default
title: "How to create a file share in Azure Files"
date: 2016-02-29 23:31:00
keywords: azure storage, curl, openssl
---

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">How to create a file share in <a href="https://twitter.com/Azure">@Azure</a> Files on a Linux box <a href="https://t.co/AcwWc5jgGy">https://t.co/AcwWc5jgGy</a></p>&mdash; Chris Geuer-Pollmann (@chgeuer) <a href="https://twitter.com/chgeuer/status/705415421323821056">March 3, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>




Sometimes you just want to call Azure Storage REST API to create an Azure Files share, no questions asked, no SDK installed, just do it, please... 

Requirements: 

- `bash`
- `curl` (for making the REST call)
- `OpenSSL` (for doing the crypto operations)
- `xxd` from the `vim-common` package 

```bash
#!/bin/bash

# yum -y install vim-common samba-client samba-common cifs-utils

# storage_account="mystorageaccount"
# access_key="deadbeedd+longBase64EncodedStuffWhichIsTotallySecretAndGetsInjectedViaCustomScriptExte=="
# share_name="meinshare"

storage_account="$1"
access_key="$2"
share_name="$3"

request_method="PUT"
storage_service_version="2015-02-21"
content_encoding=""
content_language=""
content_length=""
content_md5=""
content_type=""
date=""
if_modified_since=""
if_match=""
if_none_match=""
if_unmodified_since=""
range=""
request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
x_ms_date_h="x-ms-date:$request_date"
x_ms_version_h="x-ms-version:$storage_service_version"
canonicalized_headers="${x_ms_date_h}\n${x_ms_version_h}\n"
canonicalized_resource="/${storage_account}/${share_name}\nrestype:share"
string_to_sign="${request_method}\n${content_encoding}\n${content_language}\n${content_length}\n${content_md5}\n${content_type}\n${date}\n${if_modified_since}\n${if_match}\n${if_none_match}\n${if_unmodified_since}\n${range}\n${canonicalized_headers}${canonicalized_resource}"
decoded_hex_key="$(printf $access_key | base64 -d -w0 | xxd -p -c256)"
signature=$(printf "$string_to_sign" | openssl sha256 -mac HMAC -macopt "hexkey:$decoded_hex_key" -binary | base64 -w0)

#
# Create the file share via REST call
#
cat /dev/null | curl --data @- \
  -X $request_method \
  -H "Content-Type: ${content_type}" \
  -H "Authorization: SharedKey $storage_account:$signature" \
  -H "$x_ms_date_h" \
  -H "$x_ms_version_h" \
  "https://${storage_account}.file.core.windows.net/${share_name}?restype=share"

#
# Locally mount the file share
#
mkdir "/mnt/${share_name}"

mount -t cifs \
	"//${storage_account}.file.core.windows.net/${share_name}" \
	"/mnt/${share_name}" \
	-o "vers=3.0,user=${storage_account},password=${access_key},dir_mode=0777,file_mode=0777"
```

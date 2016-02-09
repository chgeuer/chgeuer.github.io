---
layout: default
title: "Code snippets"
date: 2016-01-07
keywords: 
published: true
---

# Storage Account custom CNAME

```json
{
  "type": "Microsoft.Storage/storageAccounts"
  "name": "geuerpollmann",
  "location": "West Europe",
  "properties": {
    "accountType": "Standard_LRS",
    "customDomain": { "name": "download.geuer-pollmann.de" }
  }
}
```


- [F# Cheatsheet](http://dungpa.github.io/fsharp-cheatsheet/)

```fsharp
open System


[ "Tick"; "Trick"; "Track" ] 
    |> List.map (fun x -> sprintf "Hello %s" x) 
    |> List.iter (printfn "%s")

let greet = List.map (fun x -> sprintf "Hello %s" x) 
let spitout = List.iter (printfn "%s")

let qq = 
    List.map (fun x -> sprintf "Hello %s" x) >> 
    List.iter (printfn ">> %s")

[ "1"; "Trick2"; "3" ]  |> (greet >> spitout)
```


```fsharp
let negate x = x * -1 
let square x = x * x 
let print x = printfn "The number is: %d" x

let squareNegateThenPrint x = print (negate (square x)) 
let squareNegateThenPrint2 = square >> negate >> print
let ``square, negate, then print 3`` x = x |> square |> negate |> print

squareNegateThenPrint 6
squareNegateThenPrint2 7
``square, negate, then print 3`` 5
```


```
[ "Tick"; "Trick"; "Track" ] 
    |> Seq.map (fun x -> sprintf "Hello %s" x) 
    |> Seq.iter (printfn "%s")

let greet = (fun x -> sprintf "Hello %s" x) 
let print = printfn "%s"

let a = Array.map greet >> Array.iter print
let l = List.map greet >> List.iter print
let s = Seq.map greet >> Seq.iter print

[ "Tick"; "Trick"; "Track" ]  |>  Seq.map greet |> Seq.iter print
[ "Tick"; "Trick"; "Track" ]  |> (Seq.map greet >> Seq.iter print)
[ "Tick"; "Trick"; "Track" ]  |> s
[ "Tick"; "Trick"; "Track" ]  |> l
[| "Tick"; "Trick"; "Track" |]  |> a
```


# MD5 Crypto

```
open System
open System.Security.Cryptography
open System.Text

let md5 = 
    fun (bytes: byte[]) -> MD5.Create().ComputeHash(bytes)

let md5base64 = 
    md5 >> Convert.ToBase64String

let md5hex = 
    let hex =
        Array.map (fun (x : byte) -> String.Format("{0:X2}", x)) >> 
        String.concat String.Empty
    md5 >> hex >> (fun x -> x.ToLower())

md5base64 "hash me"B |> printfn "MD5 %s"

printfn "MD5 %s" <| md5base64 "hash me"B

[(""B, "d41d8cd98f00b204e9800998ecf8427e"); 
    ("a"B, "0cc175b9c0f1b6a831c399e269772661"); 
    ("abc"B, "900150983cd24fb0d6963f7d28e17f72");
    ("message digest"B, "f96b697d7cb7938d525a2f31aaf161d0");
    ("abcdefghijklmnopqrstuvwxyz"B, "c3fcd3d76192e4007dfb496cca67e13b");
    ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"B, "d174ab98d277d9f5a5611c2c9f419d9f");
    ("12345678901234567890123456789012345678901234567890123456789012345678901234567890"B, "57edf4a22be3c955ac49da2e2107b67a")]
    |> Seq.iter (fun (input, expected) -> Console.WriteLine("{0}", (String.Equals(expected, md5hex input), (Encoding.ASCII.GetString(input)))))
```

# Extending async with await on tasks

- src: [http://www.fssnip.net/hv](http://www.fssnip.net/hv)

``` 
// http://www.fssnip.net/hv
type Microsoft.FSharp.Control.AsyncBuilder with
  member x.Bind(t:Task<'T>, f:'T -> Async<'R>) : Async<'R>  = 
    async.Bind(Async.AwaitTask t, f)

let download(url : string) =
    async {
        let client = new WebClient()
        let! html = client.DownloadStringTaskAsync(url)
        return html 
    }

"http://www.microsoft.com/" |> download |> Async.RunSynchronously |> printfn "%s"
```

# Enumerate files

```
open System
open System.IO
open System.Security.Cryptography
open System.Text

let md5 = 
    fun (bytes: byte[]) -> MD5.Create().ComputeHash(bytes)

let md5base64 = 
    md5 >> Convert.ToBase64String

let md5hex = 
    let hex =
        Array.map (fun (x : byte) -> String.Format("{0:X2}", x)) >> 
        String.concat String.Empty
    md5 >> hex >> (fun x -> x.ToLower())

let rootDir = "D:\Password Safe"

let ds = DirectoryInfo(rootDir)
ds.Name

printfn "Root: %s" <| md5base64 "GHa"B

let bytecontent filename = 
    File.ReadAllBytes filename

let stringcontent filename = 
    File.ReadAllText filename

bytecontent "C:\Users\chgeuer\Desktop\Android Apps.txt" |> md5base64 |> printfn "%s"
stringcontent "C:\Users\chgeuer\Desktop\Android Apps.txt" |> printfn "%s"
```

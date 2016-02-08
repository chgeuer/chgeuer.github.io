---
layout: default
title: "Uploading blobs to Microsoft Azure - The robust way"
date: 2014-07-21
keywords: azure, azure storage, C#, REST API
published: true
---

On September 23, 2015, Microsoft [launched](https://azure.microsoft.com/de-de/blog/introducing-azure-storage-data-movement-library-preview-2/) the [Azure Storage Data Movement Library](https://github.com/Azure/azure-storage-net-data-movement). You might want to check that as well. 

> TL;DR - The ``LargeFileUploaderUtils.cs`` file in the associated repository ([https://github.com/chgeuer/AzureLargeFileUploader](https://github.com/chgeuer/AzureLargeFileUploader)) contains a C# upload helper class for Azure blob storage which supports resuming broken uploads, can upload multiple blocks in parallel, and is robust in the sense that you can pull the network cable during the upload, and when connectivity is restored, it just continues.  

# Azure Blob Storage Uploads - An Introduction  

A customer of mine needed to upload Mezzanine files, i.e. large video files in the 200+ GB-range, to Azure blob storage. While I appreciate the nice GUI which tools such as CloudXplorer provide me with, when it comes to handling gigantic files, these GUI tools can die in the middle of the action. My customer, sitting in some office with potentially unreliable Internet connection, wanted to upload the files across the weekend, so I was in need for a rock-solid upload process. This blog article describes the small upload utility I came up with.  

When you need to upload blobs (files) to Azure blob storage, under the hood this upload uses Azure Storage's REST API, in particular the ``PubBlock()`` and ``PutBlockList()`` functions. When you ever tried to upload a larger (couple Megabytes) file through a HTTP POST from your browser, you know there's nothing more annoying than an upload which breaks at 97%... Therefore, the Azure Storage team decided to ensure large assets are uploaded in smaller pieces. Simply speaking, you chop your file into smaller pieces, and then upload the individual pieces (each with a specific number) through the ``PutBlock()`` function, and when all pieces are successfully uploaded, you commit these using the ``PutBlockList()`` function. When Azure blob storage receives the information in which the pieces fit together, it puzzles the whole thing together, and the real file materializes in blob storage. 

## Chunk size

The problem with the previously mentioned broken upload is that you basically waste precious bandwidth and time when the network causes the upload to break. Uploading in larger chunks has the advantage that the overhead of establishing a TCP session is minimized, but that happens at the higher probability of the upload failing. Smaller upload chunks have the advantage that each upload has a higher chance of happening successfully, but at the cost of more HTTP requests and the associated TCP session establishment overhead. The maximum size of an uploaded block in Azure storage is 4 MB. 

## We're talking 'Block' Blobs

Azure blob storage supports two different types of blobs, page blobs and block blobs: 

Usually, a *page blob* is something like a virtual harddisk (a .VHD file in Microsoft lingo). The important thing about page blobs is that they can contain fewer information that the overall size, i.e. the stored information in the file can be spares. If you imagine a harddisk, while the harddisk may have 1TB in size, the used space could be 200GB. When you want to upload page blobs, please refer to tools such as csupload.exe. 

A *block blob* is what you usually expect a file to be, full with information from the beginning through the end. The upload pieces or chunks mentioned earlier are these blocks. 

# The implementation

## Integrity protection

When a single block is uploaded through the ``PutBlock()`` operation, the client needs a mechanism to ensure the stored data is equivalent to the sent data. We achieve this by calculating an MD5-checksum of the block, and sending it alongside with the payload. When receiving the payload, the Azure storage service re-calculates the checksum on its side, and only stores the blob when the client-sent and service-side re-calculated values match. Otherwise, the client receives an error indicating that the transfer was faulty. 

## Resuming a previous upload

Resuming an upload allows the client to re-start the upload at a later time, maybe after an application crash, a machine reboot or when network connectivity is restored. 

Each blob in Azure storage has a name, such as "movie.mp4". So all uploaded blocks belong to "movie.mp4". In order to differentiate between the different uploaded blocks, each block also must have a unique block ID. When we need to resume a broken transfer, we can use this block ID track which blocks have been uploaded previously: The ``DownloadBlockList(BlockListingFilter.Uncommitted, ...)`` function allows us to retrieve a list of all blocks which are already in Azure storage, but which have not yet been amalgamated to the final blob. 

To implement resume, we first determine which blocks exist in the local file: 

```csharp
var allBlockInFile = Enumerable
     .Range(0, 1 + ((int)(file.Length / NumBytesPerChunk)))
     .Select(_ => new BlockMetadata(_, fileLength, NumBytesPerChunk))
     .Where(block => block.Length > 0)
     .ToList();
```

In this code, ``NumBytesPerChunk`` denotes the block size. Imagine you have a file with 3006 bytes, and the ``NumBytesPerChunk`` was 1000, then you would have 4 blocks, three blocks with 1000 bytes each, and a last block with 6 bytes. 

The ``BlockMetadata`` type is a local data structure to keep track of some management information. 

Now that we know (in ``allBlockInFile``) the total amount of information which should end up in the cloud, we can determine which blocks are already uploaded, and therefore, which are missing: 

```csharp
   List<BlockMetadata> missingBlocks = null;
   try
   {
       var existingBlocks = (await blockBlob.DownloadBlockListAsync(
               BlockListingFilter.Uncommitted,
               AccessCondition.GenerateEmptyCondition(),
               new BlobRequestOptions { },
               new OperationContext { }))
           .Where(_ => _.Length == NumBytesPerChunk)
           .ToList();

       missingBlocks = allBlockInFile.Where(blockInFile => !existingBlocks.Any(existingBlock =>
           existingBlock.Name == blockInFile.BlockId &&
           existingBlock.Length == blockInFile.Length)).ToList();
   }
   catch (StorageException)
   {
       missingBlocks = allBlockInFile;
   }
```

The ``blockBlob.DownloadBlockListAsync(BlockListingFilter.Uncommitted, ...)`` call fetches a list of already existing, uncommitted blocks for our file, if any. 

> Here, we filter on the length of the blocks, ensuring that all already existing blocks have the same size as our desired upload size. This ensure that - if an upload resumes with a different block size - we start from scratch. So better do not change upoad size in the middle of the action. 

Finally, we take the list of all blocks in the file, remove those blocks which are already uploaded, resulting in the list of missing blocks. The ugly try/catch block is necessary because if there are no blocks at all, the ``blockBlob.DownloadBlockListAsync()`` call throws a ``StorageException`` (instead of an empty list). 

## Uploading the actual blocks

After we have determined which blocks need to be uploaded, we define a ``uploadBlockAsync()`` closure which 

- loads the block contents from disk, 
- computes the MD5 checksum, and 
- uses the ``ExecuteUntilSuccessAsync()`` function to call ``blockBlob.PutBlockAsync()`` until it worked. 

After defining this utility function, we use the ``LargeFileUploaderUtils.ForEachAsync()`` function to call ``uploadBlockAsync()`` for each of the missing blocks. You can imagine ``LargeFileUploaderUtils.ForEachAsync()`` to be like ``Parallel.ForEach()`` but with async/await support. 

```csharp
    Func<BlockMetadata, Statistics, Task> uploadBlockAsync = async (block, stats) =>
    {
        byte[] blockData = await GetFileContentAsync(file, block.Index, block.Length);
        string contentHash = md5()(blockData);

        DateTime start = DateTime.UtcNow;

        await ExecuteUntilSuccessAsync(async () =>
        {
            await blockBlob.PutBlockAsync(
                blockId: block.BlockId, 
                blockData: new MemoryStream(blockData, true),
                contentMD5: contentHash,
                accessCondition: AccessCondition.GenerateEmptyCondition(),
                options: new BlobRequestOptions 
                { 
                    StoreBlobContentMD5 = true,
                    UseTransactionalMD5 = true
                },
                operationContext: new OperationContext());
        }, consoleExceptionHandler);

        stats.Add(block.Length, start);
    };

    var s = new Statistics(missingBlocks.Sum(b => b.Length));

    await LargeFileUploaderUtils.ForEachAsync(
        source: missingBlocks,
        parallelUploads: 4,
        body: blockMetadata => uploadBlockAsync(blockMetadata, s));
```

Looking a bit more into the details, you might observe a couple of 'interesting' code: 

### MD5 generation

```csharp
string contentHash = md5()(blockData);
```

The client needs to compute the MD5 checksumm of the ``byte[]`` array with the block contents. Given that this code might run in different tasks in parallel, we need to ensure each parallel execution has it's own unique ``MD5`` object. The ``md5()`` function returns a function with a fresh unused MD5 object which does the actual computation for us.   

```csharp
internal static Func<byte[], string> md5()
{
    var hashFunction = MD5.Create();

    return (content) => Convert.ToBase64String(hashFunction.ComputeHash(content));
}
```

### Brute-forcing success

One of the goals of this utility is that I can pull the network cable in the middle of the action, and - as soon as networking is restored - the upload continues. To achieve this, I wrote ``ExecuteUntilSuccessAsync()`` as a small utility which basically swallows all exceptions, and just retries (brute-forces) until it worked. The caller needs to supply the action which should be executed. But given that we're in async/await land, we need to supply a ``Func<Task>`` instead of a syncronous ``Action``. 

```csharp
    internal static async Task ExecuteUntilSuccessAsync(
        Func<Task> action, 
        Action<Exception> exceptionHandler)
    {
        bool success = false;
        while (!success)
        {
            try
            {
                await action();
                success = true;
            }
            catch (Exception ex)
            {
                if (exceptionHandler != null) { exceptionHandler(ex); }
            }
        }
    }
```

One concept which is not used here (yet) is that of slowing down the retries, such as through a ``Task.Delay()``, optionally with an exponential backoff. In general, it's a good idea to give the system some time to relieve the stress if something went wrong, rather than hitting it again immediately after. 

> Being able to brute-force, i.e. just retry until it works, is one of the beauties which is given to use by Azure Storage and the strange concept of [idempotence](http://en.wiktionary.org/wiki/idempotence), which [Wikipedia](http://en.wikipedia.org/wiki/Idempotence) cites as "operations that can be applied multiple times without changing the result beyond the initial application". Or simply speaking, just hit it with a hammer until it worked.

### Statistics

You might have already seen that there is also a primitive statistics class, which basically keeps track of progress and remaining time. Given that I am usually interested in progress since I started the program, the statistics to not refer to the overall file (all blocks), but to the remainder (missing blocks), so that when you re-start the program after an interruption, the overall upload size is reduced. 

## Finishing the upload

In the last step, we finish the upload by calling ``blockBlob.PutBlockListAsync()``, which assembles the actual block blob. After this step, the file is available for download.  

```csharp
    await ExecuteUntilSuccessAsync(async () =>
    {
        await blockBlob.PutBlockListAsync(blockIdList);
    }, consoleExceptionHandler);
```

# How to use it

I decided against making a NuGet package out of this; this is basically one C# file, and it's quite easy to include it in your solution. 

When you launch the NuGet Package Manager, there is a quite helpful package called ``T4Include``. This package gives you an ``Include_T4Include.tt`` file. In this file, we refer to the C# file with our uploader on Github. Whenever you save this ``.tt`` file, the T4 engine reaches out to Github and downloads the most recent version of the uploader into your solution. Such a T4 file looks like this: 

```
<#
  RootPath    = @"https://github.com/";
  Namespace   = "notinuse";
  Includes    = new []
  {
    Include (@"chgeuer/AzureLargeFileUploader/raw/master/LargeFileUploaderUtils.cs", 
               noOuterNamespace: true) 
  };
#>
<#@ include file="$(SolutionDir)\packages\T4Include.1.1.2\T4\IncludeWebFile.ttinclude" #>
```



In this code, you can see the URL where T4 retrieves the C#-code from, and you see ``noOuterNamespace: true``, which instructs T4Include to include the C#-code without wrapping or nesting it in another namespace.  

So now in your own solution, you can simply call the utility function like so:

```csharp
LargeFileUploaderUtils.UploadAsync(
    inputFile: @"C:\Users\chgeuer\format504015.mp4",
    storageConnectionString: Environment.GetEnvironmentVariable("AZURE_STORAGE_CONNECTION_STRING"),
    containerName: "dummy222222",
    uploadParallelism: 2).Wait();        
```

I forgot to mention, the ``uploadParallelism: 2`` bit allows you to specify how many parallel HTTP requests you'd like to allow. 

# Powershell

Of course, you can also use Microsoft PowerShell for uploading files, although the code to load the Azure Storage bits is most certainly not yet as clean and neat as it should be. 

```powershell
$rootfolder = "C:\Users\chgeuer\github\chgeuer\AzureLargeFileUploader"
$jsonAssembly = [System.Reflection.Assembly]::LoadFrom("$rootfolder\packages\Newtonsoft.Json.6.0.3\lib\net45\Newtonsoft.Json.dll")
$storageAssembly = [System.Reflection.Assembly]::LoadFrom("$rootfolder\packages\WindowsAzure.Storage.4.1.0\lib\net40\Microsoft.WindowsAzure.Storage.dll")
$cscode = ((New-Object -TypeName System.Net.WebClient).DownloadString("https://github.com/chgeuer/AzureLargeFileUploader/raw/master/LargeFileUploaderUtils.cs"))
Add-Type -TypeDefinition $cscode -ReferencedAssemblies $jsonAssembly.Location,$storageAssembly.Location

[LargeFileUploader.LargeFileUploaderUtils]::UseConsoleForLogging()
[LargeFileUploader.LargeFileUploaderUtils]::NumBytesPerChunk = 1024

$storageaccount = [System.Environment]::GetEnvironmentVariable("AZURE_STORAGE_CONNECTION_STRING")
$containername = "dummyps1"

Write-Host "Start upload"
$task = [LargeFileUploader.LargeFileUploaderUtils]::UploadAsync("C:\Users\chgeuer\format504015.mp4", $storageaccount, $containername, 2)
Write-Host "Upload started"
$task.Wait()
Write-Host "Upload finished"
```

Hope you had fun, if you think that post was helpful, a quick comment below or on [twitter.com/chgeuer](http://twitter.com/chgeuer) would be appreciated.  

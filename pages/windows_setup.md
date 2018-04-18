# Windows setup pieces

## Software to install

- Chrome
- [Acrobat Reader](https://get.adobe.com/de/reader/otherversions/)
- TechSmith Camtasia Studio 8
- TechSmith SnagIt 9
- [Clink](https://mridgers.github.io/clink/)
- [ConEmu](https://conemu.github.io/)
  - Config in `%appdata%\ConEmu.xml`
  - Run bash: `ConEmu64.exe -basic -run {Bash::bash}`
- [Docker for Windows](https://docs.docker.com/docker-for-windows/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/): `curl -LO --insecure https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/windows/amd64/kubectl.exe`
- [Dynamics AX 2012 Expenses](https://www.microsoft.com/store/productId/9WZDNCRFJB81)
- [Git for Windows](https://git-scm.com/download/win)
- [TortoiseGit](https://tortoisegit.org/)
- Microsoft Office
- [Gvim](https://www.vim.org/download.php)
- [Microsoft Visual Studio Code](https://code.visualstudio.com/Download)
  - Azure CLI Tools
  - Azure Resource Manager Tools
  - REST Client
  - vscode-elixir
- [Process Telerik Fiddler](https://www.telerik.com/download/fiddler)
- [Visual Studio Enterprise](https://my.visualstudio.com)
- Languages
  - [Erlang OTP](https://www.erlang.org/downloads)
  - [Elixir](https://elixir-lang.org/install.html#windows)
    - `setx.exe IEX_WITH_WERL true`
    - `setx.exe IEX_WITH_WERL "" & reg.exe delete HKCU\Environment /F /V IEX_WITH_WERL`
  - [Go](https://golang.org/dl/)
  - [Python](https://www.python.org/downloads/windows/)
- [Tag&Rename](http://www.softpointer.com/download.htm)
- TrueCrypt
- [VLC Media Player](https://www.videolan.org/vlc/download-windows.html)
- [WhatsApp](https://www.whatsapp.com/download/)
- [WinRAR](https://www.winrar.de/downld.php)
- [nmap & ncat](https://nmap.org/book/inst-windows.html)
- [curl](https://curl.haxx.se/download.html)
- [putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)
- [OpenSSL](https://wiki.openssl.org/index.php/Binaries)
- [WinSCP](https://winscp.net/eng/download.php)
- [youtube-dl](https://rg3.github.io/youtube-dl/download.html)
- [ffmpeg](https://ffmpeg.zeranoe.com/builds/)
- [jq](https://stedolan.github.io/jq/)
- [SysInternals](https://download.sysinternals.com/files/SysinternalsSuite.zip)
- [GlobalProtect](https://www.microsoft.com/store/productId/9NBLGGH6BZL3)
- [Citrix Receiver](https://www.citrix.de/downloads/citrix-receiver/)

### Include drive letters in Explorer view

Same as Explorer -> View -> Options -> General -> Open File Explorer to -> This PC

```registry
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"LaunchTo"=dword:00000001
```

### Register PhotoViewer again


```registry
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations]
".png"="PhotoViewer.FileAssoc.Tiff"
".jpeg"="PhotoViewer.FileAssoc.Tiff"
".jpg"="PhotoViewer.FileAssoc.Tiff"
".gif"="PhotoViewer.FileAssoc.Tiff"
```

### Docker on WSL to talk to Docker on WIndows

Docs [1](https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly) or [2](https://medium.com/@sebagomez/installing-the-docker-client-on-ubuntus-windows-subsystem-for-linux-612b392a44c4)

```bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) edge"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER
sudo mkdir /c
echo "sudo mount --bind /mnt/c /c" >> ~/.bashrc && source ~/.bashrc
echo "export DOCKER_HOST=tcp://0.0.0.0:2375" >> ~/.bashrc && source ~/.bashrc
```

#### Add Azure AD user to local group

```powershell
Add-LocalGroupMember -Group "docker-users" -Member "AzureAD\chgeuer@microsoft.com"
```

### VS Code

#### Font

Download [FiraCode](https://github.com/tonsky/FiraCode) and configure [VS Code](https://github.com/tonsky/FiraCode/wiki/VS-Code-Instructions):

```
"editor.fontFamily": "'Fira Code'",
"editor.fontLigatures": true
```

### ConEMU

Tweak `"C:\Users\chgeuer.EUROPE\AppData\Roaming\ConEmu.xml"`

```xml
<value name="FontName" type="string" data="Fira Code"/>
<value name="FontSize" type="ulong" data="20"/>
```

# Path

```text
%SystemRoot%
%SystemRoot%\system32
%SystemRoot%\System32\Wbem
%SystemRoot%\System32\WindowsPowerShell\v1.0
%SystemRoot%\System32\OpenSSH\

%ProgramFiles%\ConEmu
%ProgramFiles%\ConEmu\ConEmu
%ProgramFiles%\ConEmu\ConEmu\Scripts
%ProgramFiles%\Docker\Docker\resources\bin
%ProgramFiles%\Docker\Docker\resources
%ProgramFiles%\Git\cmd
%ProgramFiles%\TortoiseGit\bin
%ProgramFiles(x86)%\Vim\vim80
%ProgramFiles%\Microsoft VS Code\bin
%ProgramFiles%\dotnet\
%ProgramFiles%\erl9.3\bin
%ProgramFiles(x86)%\Elixir\bin
%ProgramFiles%\Go\bin
%ProgramFiles%\Python36
%ProgramFiles%\Python36\Scripts
%ProgramFiles%\node-v8.11.1-win-x64
%ProgramFiles(x86)%\WinSCP
%ProgramFiles(x86)%\Nmap
%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\FSharp

%USERPROFILE%\AppData\Local\Microsoft\WindowsApps
%USERPROFILE%\AppData\Local\Programs\Fiddler
%USERPROFILE%\.mix\escripts
%USERPROFILE%\bin
```





## Linux setup

### `asciinema`

```bash
sudo apt-add-repository ppa:zanchey/asciinema
sudo apt-get update
sudo apt-get install asciinema
```
### `az cli`

```bash
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
sudo apt-get install apt-transport-https && apt-get update && sudo apt-get install azure-cli
```

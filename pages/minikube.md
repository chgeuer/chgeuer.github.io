# minikube

- Ensure the Hyper-V Virtual Switch for minikube to be an "external" one. 

```cmd
REM download minikube
curl -LO https://storage.googleapis.com/minikube/releases/v0.24.1/minikube-windows-amd64.exe
ren minikube-windows-amd64.exe minikube.exe

REM potentially delete existing stuff
minikube.exe delete

REM start minikube
minikube start --vm-driver=hyperv --hyperv-virtual-switch=minikube --kubernetes-version=v1.8.0


REM potentially download kubectl.exe
REM https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl
REM https://storage.googleapis.com/kubernetes-release/release/stable.txt

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.4/bin/windows/amd64/kubectl.exe





minikube update-context
minikube start
minikube status

code C:\Users\chgeuer\.kube\config


cd ~/faas
faas-cli deploy -f hello.yml --gateway http://192.168.0.73:31112
```

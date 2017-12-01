# OpenFaaS

## Download client

Alternatively to [official way to install the CLI](https://github.com/openfaas/faas-cli#get-started-install-the-cli), I did this: 

```bash
curl -LO $(curl -s https://api.github.com/repos/openfaas/faas-cli/releases/latest | jq -r ".assets[] | select(.name == \"faas-cli.exe\") | .browser_download_url")
```

## Links

- [Getting started with OpenFaaS on Minikube](https://medium.com/@lizrice/getting-started-with-openfaas-on-minikube-8d51987f5bbb)
- [Your first serverless .NET function with OpenFaaS](https://medium.com/@rorpage/your-first-serverless-net-function-with-openfaas-27573017dedb)

# OpenFaaS

## Download client

```bash
curl -LO $(curl -s https://api.github.com/repos/openfaas/faas-cli/releases/latest | jq -r ".assets[] | select(.name == \"faas-cli.exe\") | .browser_download_url")
```

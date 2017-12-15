# Elixir tips and tricks

## Have `mix` go through fiddler

```bash
mix hex.config http_proxy "http://127.0.0.1:8888"
mix hex.config https_proxy "http://127.0.0.1:8888"
mix hex.config unsafe_https: true
```

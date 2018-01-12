# Elixir tips and tricks

## Have `mix` go through fiddler

```bash
mix hex.config http_proxy "http://127.0.0.1:8888"
mix hex.config https_proxy "http://127.0.0.1:8888"
mix hex.config unsafe_https: true
```

Also see the [hex.config](https://hex.pm/docs/tasks#hex_config) docs for that. 

Undo the config via

```bash
mix hex.config --delete http_proxy 
mix hex.config --delete https_proxy 
mix hex.config --delete unsafe_https 
```

## HTTPoison using Fiddler proxy

```elixir
options = [{ :proxy, "http://127.0.0.1:8888" }]
resp = HTTPoison.get(url, [headers], options)
```


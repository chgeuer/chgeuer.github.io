---
layout: default
title: "Some learnings regarding Tesla"
---

## Use Fiddler with [Tesla v0.8](https://github.com/teamon/tesla/tree/v0.8.0)

Using the old Tesla version, because that's the one the swagger generator uses

### `mix.exs`

```elixir
  defp deps do
    [
      {:ibrowse, "~> 4.4"},
      {:tesla, "~> 0.8"},
      {:poison, ">= 1.0.0"}
    ]
  end
```

### `config/config.exs`

```elixir
use Mix.Config

# https://github.com/teamon/tesla/wiki/0.x-to-1.0-Migration-Guide#dropped-aliases-support-159
# config :tesla, 
#   adapter: Tesla.Adapter.Ibrowse 

config :tesla,
  adapter: :ibrowse
```

### `lib/sample.ex`

```elixir
defmodule Sample do
  defmodule KeepRequest do
    @behaviour Tesla.Middleware

    def call(env, next, _opts) do
      env
      |> Tesla.put_opt(:req_body, env.body)
      |> Tesla.put_opt(:req_headers, env.headers)
      |> Tesla.run(next)
    end
  end

  defmodule Client do
    use Tesla

    def new() do
      Tesla.build_client([
        {Tesla.Middleware.Headers,  %{"X-Foo" => "Foo"}},
        Sample.KeepRequest,
        {Tesla.Middleware.Opts, [proxy_host: '127.0.0.1', proxy_port: 8888]}
      ])
    end

    def keep_headers(env = %Tesla.Env{}, _stack) do
      env
      |> Tesla.put_opt(:req_body, env.body)
      |> Tesla.put_opt(:req_headers, env.headers)
    end
  end

  def run do
    Client.new()
    |> Tesla.get("http://www.microsoft.com/")
  end
end
```

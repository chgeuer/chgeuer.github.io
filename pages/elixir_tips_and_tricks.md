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

## Inspecting HTTPoison and HTTPotion using the Fiddler proxy

```elixir
  def fiddlerHTTPotion do
    # https://github.com/myfreeweb/httpotion
    
    HTTPotion.get("https://postman-echo.com/get", 
       [ ibrowse: [ proxy_host: '127.0.0.1', proxy_port: 8888 ] ]
    )
  end

  def fiddlerHTTPoison do
    # https://github.com/edgurgel/httpoison
    
    HTTPoison.get("https://postman-echo.com/get", [], [ 
      proxy: "http://127.0.0.1:8888", 
      ssl_options: [ cacertfile: "C:\\Users\\chgeuer\\Desktop\\FiddlerRoot.cer" ], 
      ssl: [ versions: [:'tlsv1.2'] ] ])
  end
```

## Playing with `HttpBuilder`

```elixir
  def callHTTPoison do
    # using  {:http_builder, "~> 0.2.7"},
    HttpBuilder.new()
      |> with_adapter(HttpBuilder.Adapters.HTTPoison)
      |> with_host("http://postman-echo.com")
      |> with_options([proxy: "http://127.0.0.1:8888", ssl_options: [ cacertfile: "C:\\Users\\chgeuer\\Desktop\\FiddlerRoot.cer" ] ])
      |> with_headers(%{"Authorization" => "Bearer token"})
      |> with_request_timeout(10_000)
      |> with_receive_timeout(5_000)
      |> post("/post")
      |> with_json_body(%{ "A" => "B" })
      |> send()
  end

  def callHTTPotion do
    HttpBuilder.new()
      |> with_adapter(HttpBuilder.Adapters.HTTPotion)
      |> with_host("https://postman-echo.com/")
      |> with_options([ { :ibrowse, [ proxy_host: '127.0.0.1', proxy_port: 8888 ] } ])
      |> with_options([    ibrowse: [ proxy_host: '127.0.0.1', proxy_port: 8888 ]   ])
      |> with_options(              [ proxy_host: '127.0.0.1', proxy_port: 8888 ])
      |> with_headers(%{"Authorization" => "Bearer token"})
      |> with_request_timeout(10_000)
      |> with_receive_timeout(5_000)
      |> post("/post")
      |> with_json_body(%{ "A" => "B" })
      |> send()
  end
```

## Metaprogramming sample

The code from [Pattern matching on binaries takes over Regex](http://rocket-science.ru/hacking/2018/01/12/parse-cumbersome-data)

```elixir
defmodule LatLon do 
    for id <- 1..2,
        im <- 1..2,
        is <- 1..12 do
        def parse(<<
                    d::binary-size(unquote(id)), "°",
                    m::binary-size(unquote(im)), "´",
                    s::binary-size(unquote(is)), "˝",
                    ss::binary-size(1)
                    >>) 
        do
            [d, m, s] 
            |> Enum.map(fn v -> with {v, ""} <- Float.parse(v), do: v end)
        end
    end

    def foo, do: parse("1°2´3456˝E")
end
```

## Hook a function into a Tesla pipeline

```elixir
  def new(token) when is_binary(token) do
    Tesla.build_client([
      {Tesla.Middleware.Headers,  %{"Authorization" => "Bearer #{token}"}}
      &use_fiddler/2
    ])
  end

  def use_fiddler(env = %Tesla.Env{}, _stack) do
    env
    |> Tesla.put_opt(:proxy_host, "127.0.0.1" |> String.to_charlist())
    |> Tesla.put_opt(:proxy_port, 8888)
  end
```

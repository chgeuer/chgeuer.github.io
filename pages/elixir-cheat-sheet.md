---
layout: default
title: "Elixir Cheat Sheet"
---

## Imports and Aliases

```elixir
import IO
	puts "foo"

alias IO, as: MyIO
	MyIO.puts "foo"
```

## tuples

```elixir
"Jim" = {"Bob", 25} |> put_elem(0, "Jim") |> elem(0)
```

## lists

```elixir
        3 = [0, 1, 2] |> Kernel.length
        1 = [0, 1, 2] |> Enum.at(1)
[0, 1, 2] = [0, 9, 2] |> List.replace_at(1, 1)
[0, 1, 2] = [0] ++ [1, 2]
[0, 1, 2] = [0, 1] ++ [2]
[0, 1, 2] = [0 | [1, 2]]
[0, 1, 2] = [0 | [1 | [2]]]
```

## maps

```elixir
bob = %{ :name => "Bob", :age => 25 }

"Bob" = bob[:name]
"Bob" = bob.name

oldr_bob = %{bob | age: 26}
extnded = Dict.put(bob, :salary, 50000)
```

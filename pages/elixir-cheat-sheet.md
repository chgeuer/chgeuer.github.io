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
[0, 1, 2] = [0 | [ 1, 2]]
```

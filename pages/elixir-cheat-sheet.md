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
	{"Bob", 25} |> put_elem(0, "Jim") |> elem(0)
```

## lists

```elixir
[1, 2, 3] |> length

[1, 2, 3] |> Enum.at(1)

```

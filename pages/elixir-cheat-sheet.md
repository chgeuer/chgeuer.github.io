---
layout: default
title: "Elixir Cheat Sheet"
---

## Atoms and module names

```elixir
Foo = Elixir.Foo = :"Elixir.Foo"

:"Elixir.System".halt   # Shuts down the BEAM VM
```

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

[0, 1, [2, 3]] = [0 | [1, [2, 3]]]
```

## maps

```elixir
bob = %{ :name => "Bob", :age => 25 }

"Bob" = bob[:name]
"Bob" = bob.name

oldr_bob = %{bob | age: 26}
extnded = Dict.put(bob, :salary, 50000)

extnded2 = Dict.put(bob, :"The salary", 50000)
50000 = extnded2."The salary"
50000 = extnded2[:"The salary"]
```

## bitstrings

```elixir
<<1, 1>> = <<257::16>>
<<1, 1>> = <<1>> <> <<1>>

<<65, 66, 67>> = "ABC"
"ABC" = <<65, 66, 67>>
```

## strings

```elixir
"Jim"

"Hallo 1" = "Hallo #{ 9 - 8 }"

"Hallo \" 1 \"" = "Hallo \" #{ 9 - 8 }" <> << 0x20, 34 >>

7 = "hełło" |> byte_size
5 = "hełło" |> String.length

a = "
A" = "\nA"

"Hello ABC"    = "Hello" <> " ABC"
"Hello ABC"    = "Hello" <> <<32, 65, 66, 67>>
"Hello ABC"    = "Hello" <> <<0x20, 65, 66, 67>>
```

### sigils

```elixir
"This is a string"          = ~s(This is a string)
"This is a string"          = ~s[This is a string]
"This is a string"          = ~s/This is a string/
"This is a string 1"        = ~s{This is a string #{ 20 - 19 }}
"This \"is\" a string"      = ~s[This "is" a string]
```

## anonymous functions

```elixir
f = fn(x) -> IO.puts(x) end
f = &(IO.puts(&1))
f = &IO.puts/1
f.("Hi")


def f(a, b) do
	a * b
end

def f(a, b), do: a * b
```

# ElixirMeta

`ElixirMeta` is a library to programmatically retrieve information related to the Elixir language.

So far the library has the following submodules:
- `ElixirMeta.Compatibility`: compatibility between Elixir and Erlang/OTP versions.
- `ElixirMeta.Release`: all the information related to releases such as published versions,
  release condidates, latest Elixir version, etc.

Additionally, there is a sister library called `ElixirMetaData` which contains the udpated data used by
this library such as the compatibility tables, and release information.


## Repository

This source code is freely available at <https://github.com/eksperimental/elixir_meta_data>


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_meta` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_meta, "~> 0.1.0"},
  ]
end
```

## Documentation

Online documentation can be found at <https://hexdocs.pm/elixir_meta>


## Contact

Eksperimental <eskperimental (at) autistici (dot) org>


## License

ElixirMeta source code is licensed under the [MIT License](LICENSE.md).
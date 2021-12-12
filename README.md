# ElixirMeta

`ElixirMeta` is a library to programmatically retrieve information related to the Elixir language.

So far the library has the following submodules:
- `ElixirMeta.Compatibility`: compatibility between Elixir and Erlang/OTP versions.
- `ElixirMeta.Release`: all the information related to releases such as published versions,
  release condidates, latest Elixir version, etc.

Additionally, there is a sister library called `ElixirMetaData` which contains the up-to-date data and one which
this library builds on such as the compatibility tables, and release information.


## Repository and Packages

This source code is freely available at <https://github.com/eksperimental/elixir_meta>

Packages are regularly updated.
All published packages can be found on Hex: <https://hex.pm/packages/elixir_meta>


## Installation

The package can be installed by adding `elixir_meta` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_meta, "~> 0.1.0"},
  ]
end
```

## Documentation

Online documentation can be found at <https://hexdocs.pm/elixir_meta>


## Feature Requests

Feel free to open up an issue <https://github.com/eksperimental/elixir_meta/issues> with your request.


## Future Plans

I am planning to include the information for all Erlang/OTP releases, same as we do for Elixir.

## Contact

Eksperimental <eskperimental (at) autistici (dot) org>


## License

ElixirMeta source code is licensed under the [MIT License](LICENSE.md).
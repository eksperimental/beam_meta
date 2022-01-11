# BeamMeta

`BeamMeta` is a library to programmatically retrieve information related to the Elixir language.

So far the library has the following submodules:
- `BeamMeta.Compatibility`: compatibility between Elixir and Erlang/OTP versions.
- `BeamMeta.Release`: all the information related to releases such as published versions,
  release condidates, latest Elixir version, etc.

Additionally, there is a sister library called
[BeamLangsMetaData](https://github.com/eksperimental/beam_langs_meta_data) which contains the
up-to-date data and one which this library builds on such as the compatibility tables,
and release information.


## Repository and Packages

This source code is freely available at <https://github.com/eksperimental/beam_meta>

Packages are regularly updated.
All published packages can be found on Hex: <https://hex.pm/packages/beam_meta>


## Installation

The package can be installed by adding `beam_meta` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:beam_meta, "~> 0.1.0"},
  ]
end
```

## Documentation

Online documentation can be found at <https://hexdocs.pm/beam_meta>


## Feature Requests

Feel free to open up an issue <https://github.com/eksperimental/beam_meta/issues> with your request.


## Development

Install the repository locally. You can run the validations by running:

`mix validate` which is an alias for:

- `mix format --check-formatted`
- `mix deps.unlock --check-unused`
- `mix compile --warnings-as-errors`
- `mix dialyzer`
- `mix docs`
- `mix credo`

Run tests by executing:
`mix test`


## Future Plans

I am planning to include the information for all Erlang/OTP releases, same as we do for Elixir.

## Contact

Eksperimental <eskperimental (at) autistici (dot) org>


## License

BeamMeta source code is licensed under the [MIT License](LICENSE.md).
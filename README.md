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

Run `git clone` install the repository locally. You can run the following tasks by running:

- `mix setup`
- `mix validate`
- `mix all`

Run tests by executing:
`mix test`


## Future Plans

I am planning to include more functions in the Erlang/OTP releases, same as we do for Elixir.

## Contact

Eksperimental <eskperimental (at) autistici (dot) org>


## License

No Copyright

This work is released to the
[Public Domain](https://creativecommons.org/publicdomain/mark/1.0/) and multi-licensed under the
[Creative Commons Zero Universal version 1.0 license](https://creativecommons.org/publicdomain/zero/1.0/),
the [MIT No Attribution license](https://spdx.org/licenses/MIT-0.html),
and the [BSD Zero Clause license](https://opensource.org/licenses/0BSD).

You can choose between one of them if you use this work.

The author, [Eksperimental](https://github.com/eksperimental) has dedicated the work to the
public domain by waiving all copyright and related or neighboring rights to this work worldwide
under copyright law including all related and neighboring rights, to the extent allowed by law.

You can copy, modify, distribute and create derivative work, even for commercial purposes, all
without asking permission. Giving credits is appreciated though;
you may link to this repository if you wish.

<p xmlns:dct="https://purl.org/dc/terms/">
  <a rel="license" href="https://creativecommons.org/publicdomain/mark/1.0/">
    <img src="https://i.creativecommons.org/p/mark/1.0/88x31.png"
       style="border-style: none;" alt="Public Domain Mark" />
  </a><br />
  <a rel="license"
     href="https://creativecommons.org/publicdomain/zero/1.0/">
    <img src="https://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="Creative Commons Zero" />
  </a>
</p>

Check the [LICENSES/LICENSE.CC0-1.0.txt](LICENSES/LICENSE.CC0-1.0.txt),
[LICENSES/LICENSE.MIT-0.txt](LICENSES/LICENSE.MIT-0.txt),
[LICENSES/LICENSE.0BSD.txt](LICENSES/LICENSE.0BSD.txt) files for more information.

`SPDX-License-Identifier: CC0-1.0 or MIT-0 or 0BSD`

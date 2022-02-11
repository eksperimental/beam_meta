# BeamMeta

## Introduction

`BeamMeta` is a library to programmatically get information related to BEAM languages.

Currently Elixir and Erlang/OTP are supported. More languages will be added if there's interest.

The library is divided into the following namespaces:

### BeamMeta.Compatibility

Provides compatibility between [`Elixir and Erlang/OTP`](`BeamMeta.Compatibility.OtpElixir`) versions.

The [`Compatibility.OtpElixir`](`BeamMeta.Compatibility.OtpElixir`) submodule has functions for returning the compatibility table, Elixir and OTP releases, and also the [`compatible?/2`](`BeamMeta.Compatibility.OtpElixir.compatible?/2`) helper than tells you whether and OTP and an Elixir release are compatible.

### BeamMeta.Release

Provides information related to releases such as published versions, release condidates, latest Elixir version, etc.

The [`Release`](`BeamMeta.Release`) submodule provides guards such as [`is_elixir_version/1`](`BeamMeta.Release.is_elixir_version/1`) or [`is_otp_version/1`](`BeamMeta.Release.is_otp_version/1`) amongst others.

- `BeamMeta.Release.Elixir` provides functions such as:
  - [`latest_version/0`](`BeamMeta.Release.Elixir.latest_version/0`)
  - [`final_releases/0`](`BeamMeta.Release.Elixir.final_releases/0`)
  - [`prereleases/0`](`BeamMeta.Release.Elixir.prereleases/0`)
  - [`release_data/0`](`BeamMeta.Release.Elixir.release_data/0`) which lists all the information in the JSON file provided by the `BeamLangsMetaData` in a nicely formatted structure;
  - [`release_data/2`](`BeamMeta.Release.Elixir.release_data/2`) which accepts a `t:Version.requirement/0` allowing you to filter the return values.

- `BeamMeta.Release.Otp` provides functions such as:
  - [`latest_version/0`](`BeamMeta.Release.Otp.latest_version/0`)
  - [`final_releases/0`](`BeamMeta.Release.Otp.final_releases/0`)
  - [`release_data/0`](`BeamMeta.Release.Otp.release_data/0`) which lists all the information in the JSON file provided by the `BeamLangsMetaData` in a nicely formatted structure;
  - [`release_data/2`](`BeamMeta.Release.Otp.release_data/2`) which accepts a `t:Version.requirement/0` allowing you to filter the return values.

Additionally, there is a sister library called `BeamLangsMetaData` which contains the
up-to-date data and the one on which this library builds on such as the compatibility tables,
and release information. The source code can be found at: <https://github.com/eksperimental/beam_langs_meta_data>


## Important Notice

Due to the nature of the project and since we have not reached `v1.0` yet, only the latest `v0.MINOR` version will be update with the latest meta-data. Older packages will be [retired](`Mix.Tasks.Hex.Retire`) and you will get a warning when using them indicating that you need to update your library.

## Repository and Packages

This source code is freely available at <https://github.com/eksperimental/beam_meta>

Packages are regularly updated.
All published packages can be found on Hex: <https://hex.pm/packages/beam_meta>


## Documentation

Online documentation can be found at <https://hexdocs.pm/beam_meta>


## Installation

The package can be installed by adding `beam_meta` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:beam_meta, "~> 0.2.1"},
  ]
end
```


## Feature Requests

Feel free to open up an issue <https://github.com/eksperimental/beam_meta/issues> with your request.


## Development

Run `git clone` install the repository locally. You can run the following tasks by running:

- `mix setup`
- `mix validate`
- `mix all`

Run tests by executing:
`mix test`


## Road Map

1. Automatic package publishing on every OTP and Elixir new release.
2. Detect update if the release data gets updated. This feature depends on `BeamLangsMetaData`, but it is planned to be included.

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

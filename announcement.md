BeamMeta and BeamLangsMetaData - Meta information about Elixir and Erlang

I have just released two libraries.

BeamLangsMetaData - is a small library which contains JSON files including:
  - every Elixir release and prerelease starting from v1.0.0.
  - and Erlang/OTP releases and prereleases starting from Erlang/OTP 17.0.
  - the compatibility table between the two languages: 
  https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp


`BeamMeta` is a library to programmatically get information related to BEAM languages.
Currently only Elixir and Erlang/OTP are supported. More languages will be added if there's interest.

The `Compatibility` submodule has functions for returning the compatibility table, Elixir and OTP releases, and also a helper than provided an Elixir and and OTP version it tells you if they are compatible.

The [`Release`](`BeamMeta.Release`) submodule provides guards such as [`is_elixir_version/1`](`BeamMeta.Release.is_elixir_version/1`) or [`is_otp_version/1`](`BeamMeta.Release.is_otp_version/1`) amongst others.

`BeamMeta.Release.Elixir` provides functions such as: [`latest_version/0`](`BeamMeta.Release.Elixir.latest_version/0`), [`final_releases/0`](`BeamMeta.Release.Elixir.final_releases/0`) and [`release_data/0`](`BeamMeta.Release.Elixir.release_data/0`) which lists all the information in the JSON file provided by the `BeamLangsMetaData` in a nicely formatted map, and [`release_data/2`](`BeamMeta.Release.Elixir.release_data/1`) which accepts a `t:Version.requirement/0` allowing you to filter the return value.

`BeamMeta.Release.Otp` provides functions such as: [`latest_version/0`](`BeamMeta.Release.Otp.latest_version/0`), [`final_releases/0`](`BeamMeta.Release.Otp.final_releases/0`) and [`release_data/0`](`BeamMeta.Release.Otp.release_data/0`) which lists all the information in the JSON file provided by the `BeamLangsMetaData` in a nicely formatted map, and [`release_data/2`](`BeamMeta.Release.Otp.release_data/1`) which accepts a `t:Version.requirement/0` allowing you to filter the return value.

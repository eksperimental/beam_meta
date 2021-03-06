defmodule BeamMeta do
  @moduledoc """
  `BeamMeta` is a library to programmatically get information related to Beam languages.

  So far the library has the following modules:
  - `BeamMeta.Compatibility.OtpElixir`: compatibility between Elixir and Erlang/OTP versions.
  - `BeamMeta.Release`, `BeamMeta.Release.Elixir`, `BeamMeta.Release.Otp`: all the information related to releases such as published versions,
    release condidates, latest Elixir version, etc.

  Additionally, there is a parent library called `BeamLangsMetaData` which contains the udpated data used by
  this library such as the compatibility tables, and release information, and this library is based on.
  """

  @typedoc """
  A non-empty keyword list with `key_type` specified.

  For example: `nonempty_keyword(version :: atom(), map())`.
  """
  @type nonempty_keyword(key_type, value_type) :: nonempty_list({key_type, value_type})

  @typedoc """
  It is a string that represents an Elixir version.

  It could be `"MAJOR.MINOR"` or a fully qualified version
  `"MAJOR.MINOR.PATCH"`, for example: `"1.2"` or `"1.2.3"`.
  """
  @type elixir_version_key :: String.t()

  @typedoc """
  An Elixir version in either a `t:Version.t/0` format or a string representation of it.
  """
  @type elixir_version_representation :: Version.t() | String.t()

  @typedoc """
  It is an integer that represents the Erlang/OTP major version.

  For example: `24`.
  """
  @type otp_version_key :: non_neg_integer

  @typedoc """
  An Erlang/OTP version in either a string or an `t:Version.t/0`.

  A note on Erlang/OTP versions:
  The format for these versions does not align with SemVer versions, which is the format supported by 
  the Elixir `Version` module.

  In order to offer the benefits of interoperability with the Elixir language, we convert these versions to `v:Version.t/0`,
  so for example the version "23.3.4.10", we convert it to version `#Version<23.3.4-10>`.
  """
  @type otp_version_representation :: Version.t() | String.t()

  @typedoc """
  Whether the release is a prerelease or a final release.
  """
  @type release_kind :: :release | :prerelease

  @type url :: String.t()
end

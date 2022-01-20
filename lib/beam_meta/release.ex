defmodule BeamMeta.Release do
  @moduledoc """
  Functions for retrieving information related to Elixir releases.

  This module does not deal with releases prior to version `1.0.0`.
  """

  use BackPort

  elixir_release_data = BeamMeta.Release.Elixir.release_data()

  @elixir_versions elixir_release_data
                   |> Enum.map(fn {_k, map} -> Map.get(map, :version) end)
                   |> Enum.sort_by(& &1, :asc)

  @elixir_prerelease_versions elixir_release_data
                              |> Enum.filter(fn {_k, map} -> map.prerelease? end)
                              |> Enum.map(fn {_k, map} -> Map.get(map, :version) end)
                              |> Enum.sort_by(& &1, {:asc, Version})

  @elixir_release_versions elixir_release_data
                           |> Enum.reject(fn {_k, map} -> map.prerelease? end)
                           |> Enum.map(fn {_k, map} -> Map.get(map, :version) end)
                           |> Enum.sort_by(& &1, {:asc, Version})

  versions_to_strings = fn list ->
    for version <- list do
      "#{version}"
    end
  end

  @doc """
  Returns `true` if `version` is an existing Elixir prerelease (release candidate). Otherwise it returns `false`.

  `version` could be a string, or `Version` struct.

  Allowed in guard tests.

  ## Examples

      iex> version = Version.parse!("1.13.0-rc.0")
      ...> BeamMeta.Release.is_elixir_prerelease(version)
      true

      iex> BeamMeta.Release.is_elixir_prerelease("1.13.0-rc.0")
      true

      iex> BeamMeta.Release.is_elixir_prerelease("1.13.0")
      false

  """
  defguard is_elixir_prerelease(version)
           when (is_struct(version, Version) and version in @elixir_prerelease_versions) or
                  (is_binary(version) and
                     version in unquote(versions_to_strings.(@elixir_prerelease_versions)))

  @doc """
  Returns `true` if `version` is an existing Elixir final release. Otherwise it returns `false`.

  `version` could be a string, or `Version` struct.

  Allowed in guard tests.

  ## Examples

      iex> version = Version.parse!("1.13.0")
      ...> BeamMeta.Release.is_elixir_release(version)
      true

      iex> BeamMeta.Release.is_elixir_release("1.13.0-rc.0")
      false

      iex> BeamMeta.Release.is_elixir_release("1.11.10")
      false

  """
  defguard is_elixir_release(version)
           when (is_struct(version, Version) and version in @elixir_release_versions) or
                  (is_binary(version) and
                     version in unquote(versions_to_strings.(@elixir_release_versions)))

  @doc """
  Returns `true` if `version` is an existing Elixir version, whether it is a final release or a release candidate.
  Otherwise it returns `false`.

  `version` could be a string, or `Version` struct.

  Allowed in guard tests.

  ## Examples

      iex> version = Version.parse!("1.13.0")
      ...> BeamMeta.Release.is_elixir_version(version)
      true

      iex> BeamMeta.Release.is_elixir_version("1.13.0-rc.0")
      true

      iex> BeamMeta.Release.is_elixir_version("1.11.10")
      false

  """
  defguard is_elixir_version(version)
           when (is_struct(version, Version) and version in @elixir_versions) or
                  (is_binary(version) and
                     version in unquote(versions_to_strings.(@elixir_versions)))

  @otp_versions BeamMeta.Release.Otp.release_data()
                |> Enum.map(fn {_k, map} -> Map.get(map, :version) end)
                |> Enum.sort_by(& &1, :asc)

  @doc """
  Returns `true` if `version` is an existing Erlang/OTP version.
  Otherwise it returns `false`.

  `version` is a string.

  Allowed in guard tests.

  ## Examples

      iex> BeamMeta.Release.is_otp_version("21.0")
      true

      iex> BeamMeta.Release.is_otp_version("10.0")
      false

  """
  defguard is_otp_version(version) when is_binary(version) and version in @otp_versions
end

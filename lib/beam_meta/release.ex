defmodule BeamMeta.Release do
  @moduledoc """
  Functions for retrieving information related to Elixir releases.

  This module does not deal with releases prior to version `1.0.0`.
  """

  use BackPort

  # This is the minimum requirement. We do not retrieve anything prior 1.0.0
  @minimal_elixir_version_requirement Version.parse_requirement!(">= 1.0.0")

  filter_asset = fn asset when is_map(asset) ->
    {:ok, created_at, 0} = DateTime.from_iso8601(asset.created_at)

    %{
      content_type: asset.content_type,
      created_at: created_at,
      id: asset.id,
      json_url: asset.url,
      name: asset.name,
      size: asset.size,
      state: asset.state,
      url: asset.browser_download_url
    }
  end

  release_data =
    BeamLangsMetaData.elixir_releases()
    |> Enum.reduce([], fn elem, acc ->
      with tag_name when is_binary(tag_name) <- elem[:tag_name],
           version_string <- String.trim_leading(tag_name, "v"),
           version <- Version.parse!(version_string),
           true <- Version.match?(version, @minimal_elixir_version_requirement),
           {:ok, published_at, 0} <- DateTime.from_iso8601(elem.published_at),
           {:ok, created_at, 0} <- DateTime.from_iso8601(elem.created_at) do
        Keyword.put(acc, String.to_atom(version_string), %{
          assets: Enum.map(elem.assets, &filter_asset.(&1)),
          created_at: created_at,
          id: elem.id,
          json_url: elem.url,
          prerelease?: version.pre != [],
          published_at: published_at,
          tarball_url: elem.tarball_url,
          url: elem.html_url,
          version: version,
          zipball_url: elem.zipball_url
        })
      else
        _ -> acc
      end
    end)

  @versions Enum.map(release_data, fn {_k, map} -> Map.get(map, :version) end)
            |> Enum.sort_by(& &1, {:asc, Version})

  @prerelease_versions release_data
                       |> Enum.filter(fn {_k, map} -> map.prerelease? end)
                       |> Enum.map(fn {_k, map} -> Map.get(map, :version) end)
                       |> Enum.sort_by(& &1, {:asc, Version})

  @release_versions release_data
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
           when (is_struct(version, Version) and version in @prerelease_versions) or
                  (is_binary(version) and
                     version in unquote(versions_to_strings.(@prerelease_versions)))

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
           when (is_struct(version, Version) and version in @release_versions) or
                  (is_binary(version) and
                     version in unquote(versions_to_strings.(@release_versions)))

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
           when (is_struct(version, Version) and version in @versions) or
                  (is_binary(version) and version in unquote(versions_to_strings.(@versions)))
end

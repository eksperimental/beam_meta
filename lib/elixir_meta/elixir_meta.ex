defmodule ElixirMeta.Release do
  @moduledoc """
  Documentation for `ElixirMeta.Release`.
  """

  @type version :: Version.version()
  @type release_data :: %{String.t() => %{atom => term()}}

  {:ok, release_json_data} =
    :code.priv_dir(:elixir_meta)
    |> Path.join("releases.json")
    |> File.read!()
    |> Jason.decode()

  filter_asset = fn asset when is_map(asset) ->
    {:ok, updated_at, 0} = DateTime.from_iso8601(asset["updated_at"])
    {:ok, created_at, 0} = DateTime.from_iso8601(asset["created_at"])

    %{
      id: asset["id"],
      name: asset["name"],
      content_type: asset["content_type"],
      state: asset["state"],
      size: asset["size"],
      created_at: created_at,
      updated_at: updated_at,
      json_url: asset["url"],
      url: asset["browser_download_url"]
    }
  end

  version_requirement = Version.compile_requirement(">= 1.0.0")

  release_data =
    Enum.reduce(release_json_data, %{}, fn elem, acc ->
      version_string =
        elem["tag_name"]
        |> String.trim_leading("v")

      version = Version.parse!(version_string)

      if Version.match?(version, version_requirement) do
        {:ok, published_at, 0} = DateTime.from_iso8601(elem["published_at"])
        {:ok, created_at, 0} = DateTime.from_iso8601(elem["created_at"])

        Map.put(acc, version_string, %{
          version: version,
          prerelease?: version.pre != [],
          id: elem["id"],
          url: elem["html_url"],
          json_url: elem["url"],
          created_at: created_at,
          published_at: published_at,
          tarball_url: elem["tarball_url"],
          zipball_url: elem["zipball_url"],
          assets: Enum.map(elem["assets"], &filter_asset.(&1))
        })
      else
        acc
      end
    end)

  @versions Enum.map(release_data, fn {_k, map} -> Map.get(map, :version) end)

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

  defguard is_elixir_version(version)
           when (is_struct(version, Version) and version in @versions) or
                  (is_binary(version) and version in unquote(versions_to_strings.(@versions)))

  defguard is_elixir_release(version)
           when (is_struct(version, Version) and version in @release_versions) or
                  (is_binary(version) and
                     version in unquote(versions_to_strings.(@release_versions)))

  defguard is_elixir_prerelease(version)
           when (is_struct(version, Version) and version in @prerelease_versions) or
                  (is_binary(version) and
                     version in unquote(versions_to_strings.(@prerelease_versions)))

  @doc """
  Returns a map which contains all the information that we find relevant from releases data.

  "All" means release and preselease versions above Elixir version 1.0.0
  """
  @spec release_data() :: release_data()
  def release_data(), do: unquote(Macro.escape(release_data))

  @doc """
  Returns a map which contains all the information that we find relevant from releases data 
  that matches the `version_requirement`.
  """
  @spec release_data(Version.Requirement.t()) :: release_data()
  def release_data(version_requirement, options \\ []) do
    Enum.filter(release_data(), fn {_k, map} ->
      Version.match?(map.version, version_requirement, options)
    end)
  end

  @doc """
  Returns a map with all the prereleases since Elixir v1.0.0
  """
  @spec prereleases() :: release_data()
  def prereleases() do
    release_data()
    |> Enum.filter(fn {_k, map} -> map.prerelease? end)
  end

  @doc """
  Returns a map with only final releases since Elixir v1.0.0
  """
  @spec releases() :: release_data()
  def releases() do
    release_data()
    |> Enum.reject(fn {_k, map} -> map.prerelease? end)
  end

  @doc """
  Returns a list with all the Elixir versions since v1.0.0
  """
  @spec versions() :: [version()]
  def versions(), do: @versions

  @doc """
  Returns a list Elixir versions since v1.0.0, according to `kind`.

  `kind` can be:
  - `:release`
  - `:prerelease`
  """
  @spec versions(:release | :prerelease) :: [version()]
  def versions(kind)
  def versions(:release), do: @release_versions
  def versions(:prerelease), do: @prerelease_versions

  @latest_version Enum.max(@release_versions, Version)
  @doc """
  Returns the latest stable Elixir version.
  """
  @spec latest_version() :: version()
  def latest_version(), do: @latest_version
end

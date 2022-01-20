defmodule BeamMeta.Release.Elixir do
  @moduledoc """
  Functions for retrieving information related to Elixir releases.

  This module does not deal with releases prior to version `1.0.0`.
  """

  use BackPort

  @typedoc """
  A map that information related to a release in GitHub.

  This information is originally provided by `BeamLangsMetaData.elixir_releases/0` and is transformed.
  """
  @type release_data ::
          BeamMeta.nonempty_keyword(
            version_key :: atom(),
            %{
              assets:
                nonempty_list(%{
                  content_type: String.t(),
                  created_at: DateTime.t(),
                  id: non_neg_integer(),
                  json_url: String.t(),
                  name: String.t(),
                  size: non_neg_integer(),
                  state: String.t(),
                  url: String.t()
                }),
              created_at: DateTime.t(),
              id: non_neg_integer(),
              json_url: String.t(),
              prerelease?: boolean(),
              published_at: DateTime.t(),
              tarball_url: String.t(),
              url: String.t(),
              version: Version.t(),
              zipball_url: String.t()
            }
          )

  @typedoc """
  A release version.

  It could it be a `t:Version.t/0` or a string representation of this one,
  for example: `#Version<1.0.0>` or `"1.13.0"`.
  """
  @type version :: Version.t() | String.t()

  @typedoc """
  A release version requirement.

  It could it be a `t:Version.Requirement.t/0` or a string representation of this one,
  for example: `#Version.Requirement<"~> 24.0">` or `"~> 1.13"`.
  """
  @type version_requirement :: Version.Requirement.t() | String.t()

  # Note that if `term` is a string, it does not check whether it is a valid version requirement.
  defguardp is_version_requirement(term)
            when is_struct(term, Version.Requirement) or is_binary(term)

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

  @latest_version Enum.max(@release_versions, Version)

  @doc """
  Returns the latest stable Elixir version.
  """
  @spec latest_version() :: Version.t()
  def latest_version(), do: @latest_version

  @doc """
  Returns a map with all the prereleases since Elixir v1.0.0.

  ## Examples

      > BeamMeta.Release.Elixir.prereleases()
      %{
        "1.10.0-rc.0" => %{
          assets: [
            %{
              content_type: "application/zip",
              created_at: ~U[2020-01-07 15:08:43Z],
              id: 17188069,
              json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/assets/17188069",
              name: "Docs.zip",
              size: 2119178,
              state: "uploaded",
              url: "https://github.com/elixir-lang/elixir/releases/download/v1.10.0-rc.0/Docs.zip"
            },
            %{
              content_type: "application/zip",
              created_at: ~U[2020-01-07 15:08:47Z],
              id: 17188070,
              json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/assets/17188070",
              name: "Precompiled.zip",
              size: 5666120,
              state: "uploaded",
              url: "https://github.com/elixir-lang/elixir/releases/download/v1.10.0-rc.0/Precompiled.zip"
            }
          ],
          created_at: ~U[2020-01-07 14:10:04Z],
          id: 22650172,
          json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/22650172",
          prerelease?: true,
          published_at: ~U[2020-01-07 15:09:40Z],
          tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.10.0-rc.0",
          url: "https://github.com/elixir-lang/elixir/releases/tag/v1.10.0-rc.0",
          version: #Version<1.10.0-rc.0>,
          zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.10.0-rc.0"
        },
        ...
      }


  """
  @spec prereleases() :: release_data()
  def prereleases() do
    # TODO: Replace with Map.filter/2 when Elixir v1.13 is exclusively supported
    Enum.reduce(release_data(), [], fn
      {k, map}, acc ->
        if map.prerelease? do
          Keyword.put(acc, k, map)
        else
          acc
        end
    end)
  end

  @doc """
  Returns a map with only final releases since Elixir v1.0.0.

  ## Examples

      > BeamMeta.Release.Elixir.releases()
      %{
          "1.12.1" => %{
            assets: [
              %{
                content_type: "application/zip",
                created_at: ~U[2021-05-28 15:51:16Z],
                id: 37714034,
                json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/assets/37714034",
                name: "Docs.zip",
                size: 5502033,
                state: "uploaded",
                url: "https://github.com/elixir-lang/elixir/releases/download/v1.12.1/Docs.zip"
              },
              %{
                content_type: "application/zip",
                created_at: ~U[2021-05-28 15:51:27Z],
                id: 37714052,
                json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/assets/37714052",
                name: "Precompiled.zip",
                size: 6049663,
                state: "uploaded",
                url: "https://github.com/elixir-lang/elixir/releases/download/v1.12.1/Precompiled.zip"
              }
            ],
            created_at: ~U[2021-05-28 15:34:14Z],
            id: 43775368,
            json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/43775368",
            prerelease?: false,
            published_at: ~U[2021-05-28 15:51:54Z],
            tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.12.1",
            url: "https://github.com/elixir-lang/elixir/releases/tag/v1.12.1",
            version: #Version<1.12.1>,
            zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.12.1"
          },
          ...
        }

  """
  @spec releases() :: release_data()
  def releases() do
    # TODO: Replace with Map.reject/2 when Elixir v1.13 is exclusively supported
    Enum.reduce(release_data(), [], fn
      {k, map}, acc ->
        if map.prerelease? do
          acc
        else
          Keyword.put(acc, k, map)
        end
    end)
  end

  @doc """
  Returns a map which contains all the information that we find relevant from releases data.

  Includes data from final releases and preseleases starting from Elixir version 1.0.0.

  ## Examples

      > BeamMeta.Release.Elixir.release_data()
      %{
        "1.12.1" => %{
          assets: [
            %{
              content_type: "application/zip",
              created_at: ~U[2021-05-28 15:51:16Z],
              id: 37714034,
              json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/assets/37714034",
              name: "Docs.zip",
              size: 5502033,
              state: "uploaded",
              url: "https://github.com/elixir-lang/elixir/releases/download/v1.12.1/Docs.zip"
            },
            %{
              content_type: "application/zip",
              created_at: ~U[2021-05-28 15:51:27Z],
              id: 37714052,
              json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/assets/37714052",
              name: "Precompiled.zip",
              size: 6049663,
              state: "uploaded",
              url: "https://github.com/elixir-lang/elixir/releases/download/v1.12.1/Precompiled.zip"
            }
          ],
          created_at: ~U[2021-05-28 15:34:14Z],
          id: 43775368,
          json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/43775368",
          prerelease?: false,
          published_at: ~U[2021-05-28 15:51:54Z],
          tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.12.1",
          url: "https://github.com/elixir-lang/elixir/releases/tag/v1.12.1",
          version: #Version<1.12.1>,
          zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.12.1"
        },
        ...
      }

  """
  @spec release_data() :: release_data()
  def release_data(), do: unquote(Macro.escape(release_data))

  @doc """
  Returns a map which contains all the information that we find relevant from releases data 
  that matches the `elixir_version_requirement`.

  Includes data from final releases and preseleases starting from Elixir version 1.0.0.

  `options` are options supported by `Version.match?/3`. Currently the only key supported
  is `:allow_pre` which accepts `true` or `false` values. Defaults to `true`.

  ## Examples

      > BeamMeta.Release.Elixir.release_data("~> 1.12", allow_pre: false)
      %{
        "1.12.1" => %{
          assets: [
            %{
              content_type: "application/zip",
              created_at: ~U[2021-05-28 15:51:16Z],
              id: 37714034,
              json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/assets/37714034",
              name: "Docs.zip",
              size: 5502033,
              state: "uploaded",
              url: "https://github.com/elixir-lang/elixir/releases/download/v1.12.1/Docs.zip"
            },
            %{
              content_type: "application/zip",
              created_at: ~U[2021-05-28 15:51:27Z],
              id: 37714052,
              json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/assets/37714052",
              name: "Precompiled.zip",
              size: 6049663,
              state: "uploaded",
              url: "https://github.com/elixir-lang/elixir/releases/download/v1.12.1/Precompiled.zip"
            }
          ],
          created_at: ~U[2021-05-28 15:34:14Z],
          id: 43775368,
          json_url: "https://api.github.com/repos/elixir-lang/elixir/releases/43775368",
          prerelease?: false,
          published_at: ~U[2021-05-28 15:51:54Z],
          tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.12.1",
          url: "https://github.com/elixir-lang/elixir/releases/tag/v1.12.1",
          version: #Version<1.12.1>,
          zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.12.1"
        },
        ...
      }

  """
  @spec release_data(version_requirement) :: release_data()
  def release_data(elixir_version_requirement, options \\ [])
      when is_version_requirement(elixir_version_requirement) do
    # TODO: replace with Map.filter/2 when we require Elixir 1.13 exclusively
    Enum.reduce(release_data(), [], fn
      {k, map}, acc ->
        if Version.match?(map.version, elixir_version_requirement, options) do
          Keyword.put(acc, k, map)
        else
          acc
        end
    end)
  end

  @doc """
  Returns a list with all the Elixir versions since v1.0.0.

  The list contains the versions in the `t:Version.t/0` format, sorted ascendenly.

  ## Examples:

      > BeamMeta.Release.Elixir.versions()
      [#Version<1.0.0>, #Version<1.0.1>, #Version<1.0.2>, #Version<1.0.3>, #Version<1.0.4>,
       #Version<1.0.5>, #Version<1.1.0>, #Version<1.1.1>, #Version<1.2.0>, #Version<1.2.1>,
       #Version<1.2.2>, #Version<1.2.3>, #Version<1.2.4>, #Version<1.2.5>, #Version<1.2.6>, ...]

  """
  @spec versions() :: [Version.t()]
  def versions(), do: @versions

  @doc """
  Returns a list Elixir versions since v1.0.0, according to `kind`.

  The list contains the versions in the `t:Version.t/0` format, sorted ascendenly.

  `kind` can be:
  - `:release`
  - `:prerelease`

  ## Examples

      > BeamMeta.Release.Elixir.versions(:release)
      [#Version<1.0.0>, #Version<1.0.1>, #Version<1.0.2>, #Version<1.0.3>, #Version<1.0.4>,
       #Version<1.0.5>, #Version<1.1.0>, #Version<1.1.1>, #Version<1.2.0>, #Version<1.2.1>,
       #Version<1.2.2>, #Version<1.2.3>, #Version<1.2.4>, #Version<1.2.5>, #Version<1.2.6>, ...]

      > BeamMeta.Release.Elixir.versions(:prerelease)
      [#Version<1.3.0-rc.0>, #Version<1.3.0-rc.1>, #Version<1.4.0-rc.0>, #Version<1.4.0-rc.1>,
       #Version<1.5.0-rc.0>, #Version<1.5.0-rc.1>, #Version<1.5.0-rc.2>, #Version<1.6.0-rc.0>,
       #Version<1.6.0-rc.1>, #Version<1.7.0-rc.0>, #Version<1.7.0-rc.1>, #Version<1.8.0-rc.0>, ...]

  """
  @spec versions(BeamMeta.release_kind()) :: [Version.t()]
  def versions(kind)
  def versions(:release), do: @release_versions
  def versions(:prerelease), do: @prerelease_versions
end

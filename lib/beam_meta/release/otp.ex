defmodule BeamMeta.Release.Otp do
  @moduledoc """
  Functions for retrieving information related to Erlang/OTP releases.

  This module does not deal with releases prior to version OTP 17.
  """

  use BackPort
  alias BeamMeta.Util
  import Util, only: [to_version!: 1]

  @type asset :: :doc_html | :doc_man | :readme | :tarball | :win32 | :win64

  @type asset_data :: %{
          content_type: mime_type :: String.t(),
          name: file_name :: String.t(),
          url: String.t()
        }

  @typedoc """
  A map that information related to a release in GitHub.

  This information is originally provided by `BeamLangsMetaData.otp_releases/0` and is transformed.
  """
  @type release_data ::
          BeamMeta.nonempty_keyword(
            version_key :: atom(),
            %{
              optional(:assets) => BeamMeta.nonempty_keyword(asset, asset_data),
              required(:created_at) => DateTime.t(),
              optional(:id) => pos_integer,
              optional(:json_url) => BeamMeta.url(),
              required(:latest?) => boolean(),
              optional(:prerelease?) => boolean(),
              optional(:published_at) => DateTime.t(),
              optional(:tarball_url) => BeamMeta.url(),
              optional(:url) => BeamMeta.url(),
              required(:version) => version,
              optional(:zipball_url) => BeamMeta.url()
            }
          )

  @typedoc """
  An Erlang/OTP release version.

  For example: `#Version<24.2.0>` or `"24.2"`.
  """
  @type version :: Version.t() | String.t()

  @typedoc """
  A release version requirement.

  It could it be a `t:Version.Requirement.t/0` or a string representation of this one,
  for example: `#Version.Requirement<"~> 24.0">` or `"~> 1.13"`.
  """
  @type version_requirement :: Version.Requirement.t() | String.t()

  # # Note that if `term` is a string, it does not check whether it is a valid version requirement.
  # defguardp is_version_requirement(term)
  #           when is_struct(term, Version.Requirement) or is_binary(term)

  # This is the minimum requirement. We do not retrieve anything prior 17.0
  @minimal_otp_version_requirement Version.parse_requirement!(">= 17.0.0")

  build_assets = fn elem ->
    content_types = %{
      doc_html: "application/gzip",
      doc_man: "application/gzip",
      readme: "text/plain",
      tarball: "application/gzip",
      win32: "application/octet-stream",
      win64: "application/octet-stream"
    }

    for {key, content_type} when is_map_key(elem, key) <- content_types do
      url = elem[key]

      {key,
       %{
         content_type: content_type,
         name: Path.basename(url),
         url: url
       }}
    end
  end

  put_release_data_entry = fn
    # Skip
    map, :assets, [] ->
      map

    map, :published_at, value when is_binary(value) ->
      date_time = value |> NaiveDateTime.from_iso8601!() |> DateTime.from_naive!("Etc/UTC")
      Map.put(map, :published_at, date_time)

    map, key, value when value != nil ->
      Map.put(map, key, value)

    map, _key, _value ->
      map
  end

  trim_tag_name = fn tag_name ->
    tag_name
    |> String.trim_leading("OTP-")
    |> String.trim_leading("OTP_")
  end

  release_data =
    for {_major_minor_atom, %{latest: latest_version, releases: releases}} <-
          :lists.reverse(BeamLangsMetaData.otp_releases()) do
      Enum.reduce(releases, [], fn {version_atom, elem}, acc ->
        assets = build_assets.(elem)

        with tag_name when is_binary(tag_name) <- elem[:tag_name],
             version_string <- trim_tag_name.(tag_name),
             version <- to_version!(version_string),
             true <- Version.match?(version, @minimal_otp_version_requirement),
             {:ok, created_at, 0} <- DateTime.from_iso8601(elem.created_at) do
          entry =
            %{}
            |> put_release_data_entry.(:assets, assets)
            |> put_release_data_entry.(:created_at, created_at)
            |> put_release_data_entry.(:id, elem[:id])
            |> put_release_data_entry.(:json_url, elem[:url])
            |> put_release_data_entry.(:prerelease?, String.contains?(version_string, "-"))
            |> put_release_data_entry.(:tarball_url, elem[:tarball_url])
            |> put_release_data_entry.(:url, elem[:release_url])
            |> put_release_data_entry.(:version, version)
            |> put_release_data_entry.(:zipball_url, elem[:zipball_url])
            |> put_release_data_entry.(:published_at, elem[:published_at])
            |> put_release_data_entry.(:version, to_version!(version_string))
            |> put_release_data_entry.(:latest?, latest_version == version_string)

          Keyword.put(acc, version_atom, entry)
        else
          _ -> acc
        end
      end)
    end
    |> Enum.reject(&(&1 == []))
    |> List.flatten()
    |> Enum.sort()

  @release_data release_data

  # TODO: Replace with Map.reject/2 when Elixir v1.13 is exclusively supported
  release_data_prerelease =
    Enum.reduce(release_data, [], fn
      {k, map}, acc ->
        if map[:prerelease?] == true do
          Keyword.put(acc, k, map)
        else
          acc
        end
    end)

  @release_data_prerelease release_data_prerelease

  # TODO: Replace with Map.reject/2 when Elixir v1.13 is exclusively supported
  release_data_release =
    Enum.reduce(release_data, [], fn
      {k, map}, acc ->
        if map[:prerelease?] == false do
          Keyword.put(acc, k, map)
        else
          acc
        end
    end)

  @release_data_release release_data_release

  @versions Enum.map(release_data, fn {_k, map} -> to_version!(map[:version]) end)
            |> Enum.sort_by(& &1, :asc)

  @prerelease_versions release_data
                       |> Enum.filter(fn {_k, map} -> map[:prerelease?] end)
                       |> Enum.map(fn {_k, map} -> map[:version] end)
                       |> Enum.sort_by(& &1, {:asc, Version})

  @release_versions release_data
                    |> Enum.reject(fn {_k, map} -> map[:prerelease?] end)
                    |> Enum.map(fn {_k, map} -> to_version!(map[:version]) end)
                    |> Enum.sort_by(& &1, :asc)

  @latest_version Enum.max(@release_versions)

  @doc """
  Returns the latest stable Erlang/OTP version.

  ## Examples

      > BeamMeta.Release.Otp.latest_version()
      #Version<24.2.0>

  """
  @spec latest_version() :: version
  def latest_version(), do: @latest_version

  @doc """
  Returns a map with all the prereleases since Erlang/OTP 17.

  ## Examples

      > BeamMeta.Release.Otp.prereleases()
      [
        "24.0-rc3": %{
          created_at: ~U[2021-04-21 10:00:17Z],
          id: 41767908,
          json_url: "https://api.github.com/repos/erlang/otp/releases/41767908",
          latest?: false,
          prerelease?: true,
          published_at: ~U[2021-04-21 10:31:19Z],
          tarball_url: "https://api.github.com/repos/erlang/otp/tarball/OTP-24.0-rc3",
          url: "https://github.com/erlang/otp/releases/tag/OTP-24.0-rc3",
          version: #Version<24.0.0-rc3>,
          zipball_url: "https://api.github.com/repos/erlang/otp/zipball/OTP-24.0-rc3"
        },
        "24.0-rc2": %{
          created_at: ~U[2021-03-26 07:38:27Z],
          id: 40524774,
          json_url: "https://api.github.com/repos/erlang/otp/releases/40524774",
          latest?: false,
          prerelease?: true,
          published_at: ~U[2021-03-26 08:05:13Z],
          tarball_url: "https://api.github.com/repos/erlang/otp/tarball/OTP-24.0-rc2",
          url: "https://github.com/erlang/otp/releases/tag/OTP-24.0-rc2",
          version: #Version<24.0.0-rc2>,
          zipball_url: "https://api.github.com/repos/erlang/otp/zipball/OTP-24.0-rc2"
        },
        ...
      ]


  """
  @spec prereleases() :: release_data()
  def prereleases(), do: @release_data_prerelease

  @doc """
  Returns a map with only final releases since Erlang/OTP 17.

  ## Examples

      > BeamMeta.Release.Otp.releases()
      [
        "24.0-rc3": %{
          created_at: ~U[2021-04-21 10:00:17Z],
          id: 41767908,
          json_url: "https://api.github.com/repos/erlang/otp/releases/41767908",
          latest?: false,
          prerelease?: true,
          published_at: ~U[2021-04-21 10:31:19Z],
          tarball_url: "https://api.github.com/repos/erlang/otp/tarball/OTP-24.0-rc3",
          url: "https://github.com/erlang/otp/releases/tag/OTP-24.0-rc3",
          version: #Version<24.0.0-rc3>,
          zipball_url: "https://api.github.com/repos/erlang/otp/zipball/OTP-24.0-rc3"
        },
        ...
        "20.3.8.9": %{
          created_at: ~U[2018-09-11 13:14:17Z],
          latest?: true,
          version: #Version<20.3.8-9>
        },
        ...
      ]

  """
  @spec final_releases() :: release_data()
  def final_releases(), do: @release_data_release

  @doc """
  Returns a map which contains all the information that we find relevant from releases data.

  Includes data from final releases and preseleases starting from OTP 17.

  ## Examples

      > BeamMeta.Release.Otp.release_data()
      [
         "17.0": %{
          assets: [
            doc_html: %{
              content_type: "application/gzip",
              name: "otp_doc_html_17.0.tar.gz",
              url: "https://erlang.org/download/otp_doc_html_17.0.tar.gz"
            },
            doc_man: %{
              content_type: "application/gzip",
              name: "otp_doc_man_17.0.tar.gz",
              url: "https://erlang.org/download/otp_doc_man_17.0.tar.gz"
            },
            win32: %{
              content_type: "application/octet-stream",
              name: "otp_win32_17.0.exe",
              url: "https://erlang.org/download/otp_win32_17.0.exe"
            },
            win64: %{
              content_type: "application/octet-stream",
              name: "otp_win64_17.0.exe",
              url: "https://erlang.org/download/otp_win64_17.0.exe"
            }
          ],
          latest?: false,
          version: #Version<17.0.0>
        },
        "17.0.1": %{latest?: false, version: #Version<17.0.1>},
        "17.0.2": %{latest?: false, version: #Version<17.0.2>},
        "17.1": %{
          assets: [
            doc_html: %{...},
            doc_man: %{...},
            win32: %{...},
            win64: %{...},
          ],
          latest?: false,
          version: #Version<17.1.0>
        },
        ...,
        "24.1.7": %{
          assets: [
            doc_html: %{...},
            doc_man: %{...},
            win32: %{...},
            win64: %{...},
          ],
          latest?: false,
          published_at: ~U[2021-11-22 09:04:55Z], 
          url: "https://github.com/erlang/otp/releases/tag/OTP-24.1.7",
          version: #Version<24.1.7>
        },
        "24.2": %{
          assets: [
            doc_html: %{...},
            doc_man: %{...},
            win32: %{...},
            win64: %{...},
          ],
          latest?: true,
          published_at: ~U[2021-12-15 14:31:36Z],
          url: "https://github.com/erlang/otp/releases/tag/OTP-24.2",
          version: #Version<24.2.0>
        }
      ]

  """
  @spec release_data() :: release_data()
  def release_data(), do: @release_data

  @doc """
  Returns a filtered map from `releases_data/0` that matches the `otp_version_requirement` and `options`.

  `options` are options supported by `Version.match?/3`. Currently the only supported key
  is `:allow_pre` which accepts `true` or `false` values. Defaults to `true`.
  Note the currently no prereleases are listed in the `release_data/0`, so this option has no effect.

  See `releases_data/0` for more information.

  ## Examples

      > BeamMeta.Release.Otp.release_data("~> 24.1") 
      [
        "24.2": %{
          assets: [
            doc_html: %{
              content_type: "application/gzip",
              name: "otp_doc_html_24.2.tar.gz",
              url: "https://github.com/erlang/otp/releases/download/OTP-24.2/otp_doc_html_24.2.tar.gz"
            },
            doc_man: %{
              content_type: "application/gzip",
              name: "otp_doc_man_24.2.tar.gz",
              url: "https://github.com/erlang/otp/releases/download/OTP-24.2/otp_doc_man_24.2.tar.gz"
            },
            win32: %{
              content_type: "application/octet-stream",
              name: "otp_win32_24.2.exe",
              url: "https://github.com/erlang/otp/releases/download/OTP-24.2/otp_win32_24.2.exe"
            },
            win64: %{
              content_type: "application/octet-stream",
              name: "otp_win64_24.2.exe",
              url: "https://github.com/erlang/otp/releases/download/OTP-24.2/otp_win64_24.2.exe"
            }
          ],
          latest?: true,
          published_at: ~U[2021-12-15 14:31:36Z],
          url: "https://github.com/erlang/otp/releases/tag/OTP-24.2",
          version: #Version<24.2.0>
        },
        "24.1.7": %{
          assets: [
            doc_html: %{...},
            doc_man: %{...},
            win32: %{...},
            win64: %{...},
          ],
          latest?: false,
          published_at: ~U[2021-11-22 09:04:55Z],
          url: "https://github.com/erlang/otp/releases/tag/OTP-24.1.7",
          version: #Version<24.1.7>
        },
        "24.1.6": %{...},
        "24.1.5": %{...},
        "24.1.4": %{...},
        "24.1.3": %{...},
        "24.1.2": %{...},
        "24.1.1": %{...},
        "24.1": %{...},
      ]

  """
  @spec release_data(version_requirement) :: release_data()
  def release_data(otp_version_requirement, options \\ [])

  def release_data(otp_version_requirement, options) when is_binary(otp_version_requirement) do
    otp_version_requirement
    |> Version.parse_requirement!()
    |> do_release_data(options)
  end

  def release_data(otp_version_requirement, options)
      when is_struct(otp_version_requirement, Version.Requirement) do
    otp_version_requirement
    |> do_release_data(options)
  end

  defp do_release_data(otp_version_requirement, options) do
    # TODO: replace with Map.filter/2 when we require Elixir 1.13 exclusively
    Enum.reduce(release_data(), [], fn
      {k, map}, acc ->
        if Version.match?(map.version, otp_version_requirement, options) do
          [{k, map} | acc]
        else
          acc
        end
    end)
    |> :lists.reverse()
  end

  @doc """
  Returns a list with all the Erlang/OTP versions since OTP 17.

  The list contains the versions in string format, sorted ascendenly.

  ## Examples:

      > BeamMeta.Release.Otp.versions()
      ["17.0", "17.0.1", "17.0.2", "17.1", "17.1.1", "17.1.2", "17.2", "17.2.1",
       "17.2.2", "17.3", "17.3.1", "17.3.2", "17.3.3", "17.3.4", "17.4", "17.4.1",
       "17.5", "17.5.1", "17.5.2", "17.5.3", "17.5.4", "17.5.5", "17.5.6", ...]

  """
  @spec versions() :: [version, ...]
  def versions(), do: @versions

  @doc """
  Returns a list versions since Erlang/OTP 17, according to `kind`.

  The list contains the versions in the `t:Version.t/0` format, sorted ascendenly.

  `kind` can be:
  - `:release`
  - `:prerelease`

  ## Examples

      > BeamMeta.Release.Otp.versions(:release)

      > BeamMeta.Release.Otp.versions(:prerelease)

  """
  @spec versions(BeamMeta.release_kind()) :: [Version.t()]
  def versions(kind)
  def versions(:release), do: @release_versions
  def versions(:prerelease), do: @prerelease_versions

  @doc """
  Convert an Erlang/OTP version to the original string representation.

  ## Examples

      iex> Version.parse!("23.3.4-10") |> BeamMeta.Release.Otp.to_original_string()
      "23.3.4.10"

      iex> Version.parse!("23.3.4-10.3") |> BeamMeta.Release.Otp.to_original_string()
      "23.3.4.10.3"

      iex> Version.parse!("25.0.0-rc0") |> BeamMeta.Release.Otp.to_original_string()
      "25.0.0-rc0"
  """
  @spec to_original_string(Version.t()) :: String.t()
  def to_original_string(%Version{} = version) do
    Util.to_original_string(version)
  end
end

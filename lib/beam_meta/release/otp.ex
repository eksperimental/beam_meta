defmodule BeamMeta.Release.Otp do
  @moduledoc """
  Functions for retrieving information related to Erlang/OTP releases.

  This module does not deal with releases prior to version OTP 17.
  """

  use BackPort
  import BeamMeta.Util, only: [to_version!: 1]

  @type asset :: :doc_html | :doc_man | :win32 | :win64

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
              required(:latest?) => boolean(),
              optional(:published_at) => DateTime.t(),
              optional(:url) => String.t(),
              required(:version) => version
            }
          )

  @typedoc """
  An Erlang/OTP release version.

  For example: `#Version<24.2.0>`.
  """
  @type version :: Version.t()

  build_assets = fn elem ->
    keys = [:doc_html, :doc_man, :win32, :win64, :readme]

    content_types = %{
      doc_html: "application/gzip",
      doc_man: "application/gzip",
      win32: "application/octet-stream",
      win64: "application/octet-stream",
      readme: "text/plain"
    }

    for key when is_map_key(elem, key) <- keys do
      {
        key,
        %{
          content_type: content_types[key],
          name: Path.basename(elem[key]),
          url: elem[key]
        }
      }
    end
  end

  release_data =
    for {_major_minor_atom, %{latest: latest_version, releases: releases}} <-
          BeamLangsMetaData.otp_releases() do
      Enum.reduce(releases, [], fn {_version_atom, elem}, acc ->
        if version_string = elem[:name] do
          assets = build_assets.(elem)

          map = %{
            version: to_version!(version_string),
            latest?: latest_version == version_string
          }

          map =
            if published_at = elem[:published_at] do
              {:ok, published_at, 0} = DateTime.from_iso8601(published_at)
              Map.put(map, :published_at, published_at)
            else
              map
            end

          map =
            if url = elem[:release_url] do
              Map.put(map, :url, url)
            else
              map
            end

          map =
            if assets != [] do
              Map.put(map, :assets, assets)
            else
              map
            end

          Keyword.put(acc, String.to_atom(version_string), map)
        else
          acc
        end
      end)
    end
    |> Enum.reject(&(&1 == []))
    |> List.flatten()
    |> Enum.sort()

  @versions Enum.map(release_data, fn {_k, map} -> to_version!(map[:version]) end)
            |> Enum.sort_by(& &1, :asc)

  # @prerelease_versions release_data
  #                      |> Enum.filter(fn {_k, map} -> map.prerelease? end)
  #                      |> Enum.map(fn {_k, map} -> Map.get(map, :version) end)
  #                      |> Enum.sort_by(& &1, {:asc, Version})

  @release_versions release_data
                    # |> Enum.reject(fn {_k, map} -> map.prerelease? end)
                    |> Enum.map(fn {_k, map} -> Map.get(map, :version) |> to_version!() end)
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
  def release_data(), do: unquote(Macro.escape(release_data))

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
    version_string = to_string(version)

    if String.match?(version_string, ~R/^\d+\.\d+\.\d+-\d/) do
      String.replace(version_string, "-", ".", global: false)
    else
      version_string
    end
  end
end

defmodule BeamMeta.Release.Otp do
  @moduledoc """
  Functions for retrieving information related to Erlang/OTP releases.

  This module does not deal with releases prior to version OTP 17.
  """

  use BackPort

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
              latest?: boolean(),
              published_at: DateTime.t(),
              url: String.t(),
              version: version
            }
          )

  @typedoc """
  An Erlang/OTP release version.

  For example: `24.2`.
  """
  @type version :: String.t()

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
          map =
            if published_at = elem[:published_at] do
              {:ok, published_at, 0} = DateTime.from_iso8601(published_at)

              %{
                assets: build_assets.(elem),
                url: elem.release_url,
                version: version_string,
                published_at: published_at,
                latest?: latest_version == version_string
              }
            else
              %{
                version: version_string,
                published_at: published_at,
                latest?: latest_version == version_string
              }
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

  @versions Enum.map(release_data, fn {_k, map} -> map[:version] end)
            |> Enum.sort_by(& &1, :asc)

  # @prerelease_versions release_data
  #                      |> Enum.filter(fn {_k, map} -> map.prerelease? end)
  #                      |> Enum.map(fn {_k, map} -> Map.get(map, :version) end)
  #                      |> Enum.sort_by(& &1, {:asc, Version})

  @release_versions release_data
                    # |> Enum.reject(fn {_k, map} -> map.prerelease? end)
                    |> Enum.map(fn {_k, map} -> Map.get(map, :version) end)
                    |> Enum.sort_by(& &1, :asc)

  @latest_version Enum.max(@release_versions)

  @doc """
  Returns the latest stable Erlang/OTP version.

  ## Examples

      > BeamMeta.Release.Otp.latest_version()
      "24.2"

  """
  @spec latest_version() :: version
  def latest_version(), do: @latest_version

  @doc """
  Returns a map which contains all the information that we find relevant from releases data.

  Includes data from final releases and preseleases starting from OTP 17.

  ## Examples

      > BeamMeta.Release.Otp.release_data()
      [
        "17.0": %{latest?: false, published_at: nil, version: "17.0"},
        "17.0.1": %{latest?: false, published_at: nil, version: "17.0.1"},
        "17.0.2": %{latest?: false, published_at: nil, version: "17.0.2"},
        "17.1": %{latest?: false, published_at: nil, version: "17.1"},
        ...,
        "24.1.7": %{
          assets: [
            doc_html: %{
              content_type: "application/gzip",
              name: "otp_doc_html_24.1.7.tar.gz",
              url: "https://github.com/erlang/otp/releases/download/OTP-24.1.7/otp_doc_html_24.1.7.tar.gz"
            },
            doc_man: %{
              content_type: "application/gzip",
              name: "otp_doc_man_24.1.7.tar.gz",
              url: "https://github.com/erlang/otp/releases/download/OTP-24.1.7/otp_doc_man_24.1.7.tar.gz"
            },
            win32: %{
              content_type: "application/octet-stream",
              name: "otp_win32_24.1.7.exe",
              url: "https://github.com/erlang/otp/releases/download/OTP-24.1.7/otp_win32_24.1.7.exe"
            },
            win64: %{
              content_type: "application/octet-stream",
              name: "otp_win64_24.1.7.exe",
              url: "https://github.com/erlang/otp/releases/download/OTP-24.1.7/otp_win64_24.1.7.exe"
            }
          ],
          latest?: false,
          published_at: ~U[2021-11-22 09:04:55Z], 
          url: "https://github.com/erlang/otp/releases/tag/OTP-24.1.7",
          version: "24.1.7"
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
          version: "24.2"
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
end

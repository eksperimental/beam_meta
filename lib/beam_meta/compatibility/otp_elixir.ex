defmodule BeamMeta.Compatibility.OtpElixir do
  @moduledoc """
  Compatibility between Erlang/OTP and Elixir.

  Main documentation page:
  [Compatibility between Elixir and Erlang/OTP](https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp)
  """

  use BackPort

  import BeamMeta.Util, only: [to_version!: 1, to_version_requirement: 1]

  @typedoc """
  Represents an Elixir version.

  It could be:

  - a string in the shape of `"MAJOR.MINOR"`, for example: `"1.13"`;
  - a `t:Version.t/0` or string representation of this one, for example: `#Version<1.13.0>` or `"1.13.0"`.

  """
  @type elixir_version :: BeamMeta.elixir_version_key() | BeamMeta.elixir_version_representation()

  @typedoc """
  Represents an Erlang/OTP version.

  It could be:

  - an integer that represents the Erlang/OTP major version, for example: `24`.
  - a `t:Version.t/0` or string representation of this one, for example: `#Version<24.0.0>` or `"24.0.0"`.
  """
  @type otp_version :: BeamMeta.otp_version_key() | BeamMeta.otp_version_representation()

  @doc """
  Determines whether the given Elang/OTP and Elixir versions are compatible.

  The results are based on the [compatibility table](`table/0`). This function does not check
  that the Elixir and Erlang/OTP actually exists.

  `elixir_version` can be a `t:Version.t/0` or a string.
  `otp_version` can be  a `t:Version.t/0`, a string or an integer.
  `BeamMeta.Compatibility.OtpElixir.compatible?("1.11.999", 24)` will return `true` since
  Elixir v1.11 is compatible with OTP 24. If you want to make sure the Elixir
  version actually exist, please use the guards
  `BeamMeta.Release.is_elixir_version/1`. For example:

      iex> require BeamMeta.Release
      ...> elixir_version = "1.11.999"
      ...> BeamMeta.Release.is_elixir_version(elixir_version) and BeamMeta.Compatibility.OtpElixir.compatible?(24, elixir_version)
      false

  ## Examples

      iex> BeamMeta.Compatibility.OtpElixir.compatible?(24, "1.13")
      true

      iex> BeamMeta.Compatibility.OtpElixir.compatible?(24, "1.11")
      false

      iex> BeamMeta.Compatibility.OtpElixir.compatible?(24, "1.11.4")
      true

      iex> BeamMeta.Compatibility.OtpElixir.compatible?(24, "1.11.999")
      true

  """
  @spec compatible?(otp_version(), elixir_version()) :: boolean
  def compatible?(%Version{} = otp_version, %Version{} = elixir_version) do
    otp_releases(elixir_version, :version_requirement)
    |> Enum.any?(&Version.match?(otp_version, &1, allow_pre: true))
  end

  def compatible?(otp_version, elixir_version) when is_binary(elixir_version) do
    elixir_version = to_version!(elixir_version)
    compatible?(otp_version, elixir_version)
  end

  def compatible?(otp_version, elixir_version)
      when is_binary(otp_version) or is_integer(otp_version) do
    otp_version = to_version!(otp_version)
    compatible?(otp_version, elixir_version)
  end

  @doc """
  Returns a list of all the Elixir releases available for the given Erlang/OTP version.

  `otp_version` can be a `t:Version.t/0`, a string, or an integer.

  `return_type` determines the type of values returned. These could be:
  - `:key` : The string by which the Elixir version is identified.
    Ex: "1.12". This is the default value is not value is provided.
  - `:version` : The Elixir version in `t:Version.t/0`  format.
  - `:version_requirement` : The Elixir versions in `t:Version.Required.t/0`  format.

  The results are sorted ascendenly.

  ## Examples

      iex> BeamMeta.Compatibility.OtpElixir.elixir_releases(21)
      ["1.6", "1.7", "1.8", "1.9", "1.10", "1.10.3", "1.11", "1.11.4"]

      iex> BeamMeta.Compatibility.OtpElixir.elixir_releases("17.1", :key)
      ["1.0", "1.0.5", "1.1"]

      > BeamMeta.Compatibility.OtpElixir.elixir_releases("17.1", :version)
      [#Version<1.0.0>, #Version<1.0.5>, #Version<1.1.0>]

      > BeamMeta.Compatibility.OtpElixir.elixir_releases("17.1", :version_requirement)
      [#Version.Requirement<~> 1.0.0>, #Version.Requirement<~> 1.0.5-0>, #Version.Requirement<~> 1.1.0-0>]

      iex> BeamMeta.Compatibility.OtpElixir.elixir_releases(16)
      []

  """
  @spec elixir_releases(otp_version(), return_type :: :key | :version | :version_requirement) ::
          [BeamMeta.elixir_version_key() | Version.t() | Version.Requirement.t()]
  def elixir_releases(otp_version, return_type \\ :key)

  def elixir_releases(%Version{} = otp_version, return_type) when is_atom(return_type) do
    Enum.reduce(table({:elixir, :otp}), [], fn
      {elixir_key, map}, acc ->
        filter_elixir_releases(otp_version, return_type, elixir_key, map, acc)
    end)
    |> Enum.sort_by(fn {version, _} -> version end, {:asc, Version})
    |> Enum.map(fn {_, r_type} -> r_type end)
    |> Enum.uniq()
  end

  def elixir_releases(otp_version, return_type)
      when is_binary(otp_version) or is_integer(otp_version) do
    elixir_releases(to_version!(otp_version), return_type)
  end

  defp filter_elixir_releases(
         otp_version,
         return_type,
         elixir_key,
         %{
           version: elixir_version,
           version_requirement: elixir_requirement,
           otp_versions: otp_versions
         },
         acc
       ) do
    if Enum.any?(otp_versions, fn {_otp_key, %{version: _o_version, version_requirement: o_req}} ->
         Version.match?(otp_version, o_req)
       end) do
      value =
        case return_type do
          :key -> {elixir_version, elixir_key}
          :version -> {elixir_version, elixir_version}
          :version_requirement -> {elixir_version, elixir_requirement}
        end

      [value | acc]
    else
      acc
    end
  end

  @doc """
  Returns a list of all the Erlang/OTP releases available for the givien Elixir version.

  `elixir_version` can be a `t:Version.t/0` or a string.

  `return_type` determines the type of values returned. These could be:
  - `:key` : The string by which the Elixir version is identified. This is the default value if no return type is provided.
  - `:version` : The Elixir version in `t:Version.t/0`  format.
  - `:version_requirement` : The Elixir versions in `t:Version.Required.t/0`  format.

  The results are sorted ascendenly.

  ## Examples

      # MAJOR.MINOR
      iex> BeamMeta.Compatibility.OtpElixir.otp_releases("1.11")
      [21, 22, 23]

      # MAJOR.MINOR.PATCH
      iex> BeamMeta.Compatibility.OtpElixir.otp_releases("1.11.0")
      [21, 22, 23]

      iex> BeamMeta.Compatibility.OtpElixir.otp_releases("1.11.2")
      [21, 22, 23]

      iex> BeamMeta.Compatibility.OtpElixir.otp_releases("1.11.4")
      [21, 22, 23, 24]

      iex> BeamMeta.Compatibility.OtpElixir.otp_releases("1.11.4", :key)
      [21, 22, 23, 24]

      > BeamMeta.Compatibility.OtpElixir.otp_releases("1.11.4", :version)
      [#Version<21.0.0>, #Version<22.0.0>, #Version<23.0.0>, #Version<24.0.0>]

      > BeamMeta.Compatibility.OtpElixir.otp_releases("1.11.4", :version_requirement)
      [#Version.Requirement<~> 21.0>, #Version.Requirement<~> 22.0>, #Version.Requirement<~> 23.0>, #Version.Requirement<~> 24.0>]

      # Version do not necessarily need to exist.
      # The results are based on the compaibility table
      iex> BeamMeta.Compatibility.OtpElixir.otp_releases("1.11.999")
      [21, 22, 23, 24]

      iex> BeamMeta.Compatibility.OtpElixir.otp_releases("1.99.0")
      []

      iex> BeamMeta.Compatibility.OtpElixir.otp_releases("2.0")
      []

  """
  @spec otp_releases(elixir_version(), return_type :: :key | :version | :version_requirement) ::
          [BeamMeta.otp_version_key() | Version.t() | Version.Requirement.t()]
  def otp_releases(elixir_version, return_type \\ :key)

  def otp_releases(%Version{} = elixir_version, return_type)
      when return_type in [:key, :version, :version_requirement] do
    Enum.reduce(table({:elixir, :otp}), [], fn
      {_elixir_key,
       %{
         version_requirement: elixir_requirement,
         otp_versions: otp_versions
       }},
      acc ->
        if Version.match?(elixir_version, elixir_requirement, allow_pre: true) do
          o_versions =
            for {o_key, %{version: o_version, version_requirement: o_req}} <- otp_versions do
              case return_type do
                :key -> o_key
                :version -> o_version
                :version_requirement -> o_req
              end
            end

          [o_versions | acc]
        else
          acc
        end
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  def otp_releases(elixir_version, return_type) when is_binary(elixir_version) do
    otp_releases(to_version!(elixir_version), return_type)
  end

  table_elixir_otp =
    BeamLangsMetaData.compatibility({:elixir, :otp})
    |> Enum.into(%{}, fn
      {elixir_version, otp_version} ->
        elixir_requirement = to_version_requirement(elixir_version)

        otp_versions =
          Enum.into(otp_version, %{}, fn o_version ->
            {o_version,
             %{
               version: to_version!(o_version),
               version_requirement: Version.parse_requirement!("~> #{o_version}.0")
             }}
          end)

        {elixir_version,
         %{
           version: to_version!(elixir_version),
           version_requirement: elixir_requirement,
           otp_versions: otp_versions
         }}
    end)

  @table_elixir_otp table_elixir_otp

  table_otp_elixir =
    BeamLangsMetaData.compatibility({:otp, :elixir})
    |> Enum.into(%{}, fn
      {otp_version, elixir_version} ->
        otp_requirement = to_version_requirement(otp_version)

        elixir_versions =
          Enum.into(elixir_version, %{}, fn e_version ->
            e_version_struct = to_version!(e_version)

            {e_version,
             %{
               version: e_version_struct,
               version_requirement: Version.parse_requirement!("~> #{e_version_struct}")
             }}
          end)

        {otp_version,
         %{
           version: to_version!(otp_version),
           version_requirement: otp_requirement,
           elixir_versions: elixir_versions
         }}
    end)

  @table_otp_elixir table_otp_elixir

  @doc """
  Returns a map with the compatibility table.

  Note that this is not a table that contains every release, but
  a table that represent the MAJOR.MINOR and eventually the MAJOR.MINOR.PATCH releases listed in the page
  [Compatibility between Elixir and Erlang/OTP](https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp)

  ## Examples

      > BeamMeta.Compatibility.OtpElixir.table({:otp, :elixir})
      %{
        17 => %{
          elixir_versions: %{
            "1.0" => %{
              version: #Version<1.0.0>,
              version_requirement: #Version.Requirement<~> 1.0.0>
            },
            "1.1" => %{
              version: #Version<1.1.0>,
              version_requirement: #Version.Requirement<~> 1.1.0>
            }
          },
          version: #Version<17.0.0>,
          version_requirement: #Version.Requirement<~> 17.0.0-0>
        },
        18 => %{
          elixir_versions: %{
            "1.0.5" => %{
              version: #Version<1.0.5>,
              version_requirement: #Version.Requirement<~> 1.0.5>
            },
            "1.1" => %{...},
            "1.2" => %{...},
            "1.3" => %{...},
            "1.4" => %{...},
            "1.5" => %{...}
          },
          version: #Version<18.0.0>,
          version_requirement: #Version.Requirement<~> 18.0.0-0>
        },
        ...
      %}

      > BeamMeta.Compatibility.OtpElixir.table({:elixir, :otp})
      %{
        "1.0" => %{
          otp_versions: %{
            17 => %{
              version: #Version<17.0.0>,
              version_requirement: #Version.Requirement<~> 17.0>
            }
          },
          version: #Version<1.0.0>,
          version_requirement: #Version.Requirement<~> 1.0.0>
        },
        "1.0.5" => %{...},
        "1.1" => %{
          otp_versions: %{
            17 => %{...},
            18 => %{...}
          },
          version: #Version<1.1.0>,
          version_requirement: #Version.Requirement<~> 1.1.0-0>
        },
        ...
      }

  """
  @spec table({:elixir, :otp}) :: %{
          BeamMeta.elixir_version_key() => %{
            otp_versions: %{
              BeamMeta.otp_version_key() => %{
                version: Version.t(),
                version_requirement: Version.Requirement.t()
              }
            },
            version: Version.t(),
            version_requirement: Version.Requirement.t()
          }
        }
  @spec table({:otp, :elixir}) :: %{
          BeamMeta.otp_version_key() => %{
            elixir_versions: %{
              BeamMeta.elixir_version_key() => %{
                version: Version.t(),
                version_requirement: Version.Requirement.t()
              }
            },
            version: Version.t(),
            version_requirement: Version.Requirement.t()
          }
        }
  def table({:elixir, :otp}), do: @table_elixir_otp
  def table({:otp, :elixir}), do: @table_otp_elixir
end

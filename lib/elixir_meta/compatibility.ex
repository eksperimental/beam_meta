defmodule ElixirMeta.Compatibility do
  @moduledoc """
  Compatibility between Elixir and OTP.

  Main documentation page: [Compatibility between Elixir and Erlang/OTP](https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp)
  """

  use ElixirMeta.BackPort

  import ElixirMeta.Compatibility.Util, only: [to_elixir_version_requirement: 1]
  import ElixirMeta.Util, only: [to_version: 1]

  @type elixir_version :: ElixirMeta.elixir_version_key | ElixirMeta.version_representation()
  @type otp_version :: ElixirMeta.version_representation() | ElixirMeta.otp_version_key

  compatibility_table =
    ElixirMetaData.compatibility()
    |> Enum.into(%{}, fn
      {elixir_version, otp_version} ->
        elixir_requirement = to_elixir_version_requirement(elixir_version)

        otp_versions =
          Enum.into(otp_version, %{}, fn o_version ->
            {o_version,
             %{
               version: to_version(o_version),
               version_requirement: Version.parse_requirement!("~> #{o_version}.0")
             }}
          end)

        {elixir_version,
         %{
           version: to_version(elixir_version),
           version_requirement: elixir_requirement,
           otp_versions: otp_versions
         }}
    end)

  @compatibility_table compatibility_table
  @doc """
  Returns a map with the compatibility table.
  """
  @spec compatibility_table() :: %{
          elixir_version_key => %{
            version: Version.t(),
            version_requirement: Version.Requirement.t(),
            otp_versions: %{
              otp_version_key => %{
                version: Version.t(),
                version_requirement: Version.Requirement.t()
              }
            }
          }
        }
        when elixir_version_key: String.t(), otp_version_key: non_neg_integer()
  def compatibility_table(), do: @compatibility_table

  @doc """
  Returns a list of all the Elixir releases available for the givien Erlang/OTP version.

  `otp_version` can be a `Version.t/0`, a string, or an integer.

  `return_type` determines the type of values returned. These could be:
  - `:key` : The string by which the Elixir version is identified.
    Ex: "1.12". This is the default value is not value is provided.
  - `:version` : The Elixir version in `Version.t/0`  format.
  - `:version_requirement` : The Elixir versions in `Version.Required.t/0`  format.

  The results are sorted ascendenly.
  """
  @spec get_elixir_releases(otp_version(), return_type :: :key | :version | :version_requirement) ::
          [String.t() | Version.t() | Version.Requirement.t()]
  def get_elixir_releases(otp_version, return_type \\ :key)

  def get_elixir_releases(%Version{} = otp_version, return_type) when is_atom(return_type) do
    Enum.reduce(compatibility_table(), [], fn
      {elixir_key, map}, acc ->
        filter_get_elixir_releases(otp_version, return_type, elixir_key, map, acc)
    end)
    |> Enum.uniq()
    |> Enum.reverse()
  end

  def get_elixir_releases(otp_version, return_type)
      when is_binary(otp_version) or is_integer(otp_version) do
    get_elixir_releases(to_version(otp_version), return_type)
  end

  defp filter_get_elixir_releases(
         otp_version,
         return_type,
         elixir_key,
         %{
           version: _elixir_version,
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
          :key -> elixir_key
          :version -> elixir_requirement
          :version_requirement -> elixir_requirement
        end

      [value | acc]
    else
      acc
    end
  end

  @doc """
  Returns a list of all the Erlang/OTP releases available for the givien Elixir version.

  `elixir_version` can be a `Version.t/0` or a string.

  `return_type` determines the type of values returned. These could be:
  - `:key` : The string by which the Elixir version is identified.
    Ex: "1.12". This is the default value is not value is provided.
  - `:version` : The Elixir version in `Version.t/0`  format.
  - `:version_requirement` : The Elixir versions in `Version.Required.t/0`  format.

  The results are sorted ascendenly.
  """
  @spec get_otp_releases(elixir_version(), return_type :: :key | :version | :version_requirement) ::
          [String.t() | Version.t() | Version.Requirement.t()]
  def get_otp_releases(elixir_version, return_type \\ :key)

  def get_otp_releases(%Version{} = _elixir_version, return_type) do
    Enum.reduce(compatibility_table(), [], fn
      {_elixir_key,
       %{
         version: elixir_version,
         version_requirement: elixir_requirement,
         otp_versions: otp_versions
       }},
      acc ->
        if Version.match?(elixir_version, elixir_requirement, allow_pre: true) do
          o_versions =
            for {o_key, %{version: o_version, requirement: o_req}} <- otp_versions do
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

  def get_otp_releases(elixir_version, return_type) when is_binary(elixir_version) do
    get_otp_releases(to_version(elixir_version), return_type)
  end

  @doc """
  Determines whether the give Elixir and Elang/OTP versions are compatible.

  `elixir_version` can be a `Version.t/0` or a string.
  `otp_version` can be  a `Version.t/0`, a string or an integer.
  """
  @spec compatible?(elixir_version(), otp_version()) :: boolean
  def compatible?(%Version{} = elixir_version, %Version{} = otp_version) do
    get_otp_releases(elixir_version, :version_requirement)
    |> Enum.any?(&Version.match?(otp_version, &1, allow_pre: true))
  end

  def compatible?(elixir_version, otp_version) when is_binary(elixir_version) do
    elixir_version = to_version(elixir_version)
    compatible?(elixir_version, otp_version)
  end

  def compatible?(elixir_version, otp_version)
      when is_binary(otp_version) or is_integer(otp_version) do
    otp_version = to_version(otp_version)
    compatible?(elixir_version, otp_version)
  end
end

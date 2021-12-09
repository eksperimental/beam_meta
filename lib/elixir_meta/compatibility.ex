defmodule ElixirMeta.Compatibility do
  @moduledoc """
  Compatibility between Elixir and OTP.

  Main documentation page: [Compatibility between Elixir and Erlang/OTP](https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp)
  """

  use BackPort

  import ElixirMeta.Compatibility.Util, only: [to_elixir_version_requirement: 1]
  import ElixirMeta.Util, only: [to_version: 1]

  @typedoc """
  Represents an Elixir version.

  It could be:

  - a string in the shape of `"MAJOR.MINOR"`, for example: `"1.13"`;
  - a `t:Version.t/0` or string representation of this one, for example: `#Version<1.13.0>` or `"1.13.0"`.

  """
  @type elixir_version :: ElixirMeta.elixir_version_key() | ElixirMeta.version_representation()

  @typedoc """
  Represents an Erlang/OTP version.

  It could be:

  - Ian integer that represents the Erlang/OTP major version, for example: `24`.
  - a `t:Version.t/0` or string representation of this one, for example: `#Version<24.0.0>` or `"24.0.0"`.
  """
  @type otp_version :: ElixirMeta.otp_version_key() | ElixirMeta.version_representation()

  @doc """
  Determines whether the give Elixir and Elang/OTP versions are compatible.

  `elixir_version` can be a `t:Version.t/0` or a string.
  `otp_version` can be  a `t:Version.t/0`, a string or an integer.

  Examples:

      iex> ElixirMeta.Compatibility.compatible?("1.13", 24)
      true

      iex> ElixirMeta.Compatibility.compatible?("1.11", 24)
      false

      iex> ElixirMeta.Compatibility.compatible?("1.11.4", 24)
      true

  """
  @spec compatible?(elixir_version(), otp_version()) :: boolean
  def compatible?(%Version{} = elixir_version, %Version{} = otp_version) do
    otp_releases(elixir_version, :version_requirement)
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

  @doc """
  Returns a list of all the Elixir releases available for the given Erlang/OTP version.

  `otp_version` can be a `t:Version.t/0`, a string, or an integer.

  `return_type` determines the type of values returned. These could be:
  - `:key` : The string by which the Elixir version is identified.
    Ex: "1.12". This is the default value is not value is provided.
  - `:version` : The Elixir version in `t:Version.t/0`  format.
  - `:version_requirement` : The Elixir versions in `t:Version.Required.t/0`  format.

  The results are sorted ascendenly.

  Examples:

      iex> ElixirMeta.Compatibility.elixir_releases(21)
      ["1.6", "1.7", "1.8", "1.9", "1.10", "1.10.3", "1.11", "1.11.4"]

      iex> ElixirMeta.Compatibility.elixir_releases("17.1", :key)
      ["1.0", "1.0.5", "1.1"]

      ElixirMeta.Compatibility.elixir_releases("17.1", :version)
      #=> [#Version<1.0.0>, #Version<1.0.5>, #Version<1.1.0>]

      ElixirMeta.Compatibility.elixir_releases("17.1", :version_requirement)
      #=> [#Version.Requirement<~> 1.0.0>, #Version.Requirement<~> 1.0.5-0>, #Version.Requirement<~> 1.1.0-0>]

      iex> ElixirMeta.Compatibility.elixir_releases(16)
      []

  """
  @spec elixir_releases(otp_version(), return_type :: :key | :version | :version_requirement) ::
          [ElixirMeta.elixir_version_key() | Version.t() | Version.Requirement.t()]
  def elixir_releases(otp_version, return_type \\ :key)

  def elixir_releases(%Version{} = otp_version, return_type) when is_atom(return_type) do
    Enum.reduce(table(), [], fn
      {elixir_key, map}, acc ->
        filter_elixir_releases(otp_version, return_type, elixir_key, map, acc)
    end)
    |> Enum.sort_by(fn {version, _} -> version end, {:asc, Version})
    |> Enum.map(fn {_, r_type} -> r_type end)
    |> Enum.uniq()
  end

  def elixir_releases(otp_version, return_type)
      when is_binary(otp_version) or is_integer(otp_version) do
    elixir_releases(to_version(otp_version), return_type)
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

  Examples:

      # MAJOR.MINOR
      iex> ElixirMeta.Compatibility.otp_releases("1.11")
      [21, 22, 23]

      # MAJOR.MINOR.PATCH
      iex> ElixirMeta.Compatibility.otp_releases("1.11.0")
      [21, 22, 23]

      iex> ElixirMeta.Compatibility.otp_releases("1.11.2")
      [21, 22, 23]

      iex> ElixirMeta.Compatibility.otp_releases("1.11.4")
      [21, 22, 23, 24]

      iex> ElixirMeta.Compatibility.otp_releases("1.11.4", :key)
      [21, 22, 23, 24]

      ElixirMeta.Compatibility.otp_releases("1.11.4", :version)
      #=> [#Version<21.0.0>, #Version<22.0.0>, #Version<23.0.0>, #Version<24.0.0>]

      ElixirMeta.Compatibility.otp_releases("1.11.4", :version_requirement)
      #=> [#Version.Requirement<~> 21.0>, #Version.Requirement<~> 22.0>, #Version.Requirement<~> 23.0>, #Version.Requirement<~> 24.0>]

      # Version do not necessarily need to exist.
      # The results are based on the compaibility table
      iex> ElixirMeta.Compatibility.otp_releases("1.11.999")
      [21, 22, 23, 24]

      iex> ElixirMeta.Compatibility.otp_releases("1.99.0")
      []

      iex> ElixirMeta.Compatibility.otp_releases("2.0")
      []

  """
  @spec otp_releases(elixir_version(), return_type :: :key | :version | :version_requirement) ::
          [ElixirMeta.otp_version_key() | Version.t() | Version.Requirement.t()]
  def otp_releases(elixir_version, return_type \\ :key)

  def otp_releases(%Version{} = elixir_version, return_type)
      when return_type in [:key, :version, :version_requirement] do
    Enum.reduce(table(), [], fn
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
    otp_releases(to_version(elixir_version), return_type)
  end

  table =
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

  @table table
  @doc """
  Returns a map with the compatibility table.

  Note that this is not a table that contains every release, but
  a table that represent the MAJOR.MINOR and eventually the MAJO.MINOR.PATCH releases listed in the page
  [Compatibility between Elixir and Erlang/OTP](https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp)
  """
  @spec table() :: %{
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
  def table(), do: @table
end

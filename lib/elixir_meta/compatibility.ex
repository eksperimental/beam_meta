defmodule ElixirMeta.Compatibility do
  @moduledoc """
  This modules deals with compatibility between Elixir and OTP.
  """

  import ElixirMeta.Compatibility.Util
  # alias ElixirMeta.Release

  elixir_otp =
    %{
      "1.0" => 17,
      "1.0.5" => 17..18,
      "1.1" => 17..18,
      "1.2" => 18,
      "1.2.6" => 18..19,
      "1.3" => 18..19,
      "1.4" => 18..19,
      "1.4.5" => 18..20,
      "1.5" => 18..20,
      "1.6" => 19..21,
      "1.7" => 19..22,
      "1.8" => 20..22,
      "1.9" => 20..22,
      "1.10" => 21..22,
      "1.10.3" => 21..23,
      "1.11" => 21..23,
      "1.11.4" => 21..24,
      "1.12" => 22..24,
      "1.13" => 22..24
    }
    |> Enum.map(fn
      {elixir_version, otp_version} ->
        elixir_requirement = to_elixir_version_requirement(elixir_version)

        otp_versions =
          case otp_version do
            _.._ ->
              Enum.map(otp_version, fn o_version ->
                {o_version, Version.parse_requirement!("~> #{o_version}.0")}
              end)

            otp_version when is_integer(otp_version) ->
              req =
                "~> #{otp_version}.0"
                |> Version.parse_requirement!()

              [{otp_version, req}]
          end

        {{elixir_version, elixir_requirement}, otp_versions}
    end)

  @elixir_otp elixir_otp
  def elixir_opt(), do: @elixir_otp

  def get_elixir_releases(otp_version) when is_integer(otp_version) and otp_version >= 0 do
    get_elixir_releases(Version.parse!("#{otp_version}.0.0"))
  end

  def get_elixir_releases(%Version{} = otp_version, return_requirements \\ false) do
    Enum.reduce(elixir_opt(), [], fn
      {{elixir_version, elixir_requirement}, otp_requirements}, acc ->
        if Enum.any?(otp_requirements, fn {_o_version, o_req} ->
             Version.match?(otp_version, o_req)
           end) do
          if return_requirements do
            [elixir_requirement | acc]
          else
            [elixir_version | acc]
          end
        else
          acc
        end
    end)
    |> Enum.uniq()
    |> Enum.reverse()
  end

  def get_otp_releases(elixir_version) when is_binary(elixir_version) do
    get_otp_releases(to_elixir_version(elixir_version))
  end

  def get_otp_releases(%Version{} = elixir_version, return_requirements \\ false) do
    Enum.reduce(elixir_opt(), [], fn
      {{_e_version, e_requirement}, otp_requirements}, acc ->
        if Version.match?(elixir_version, e_requirement, allow_pre: true) do
          # IO.inspect( {elixir_version, e_requirement})
          o_versions =
            for {o_version, o_req} <- otp_requirements do
              if return_requirements do
                o_req
              else
                o_version
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

  def compatible?(%Version{} = elixir_version, %Version{} = otp_version) do
    get_otp_releases(elixir_version, true)
    |> Enum.any?(&Version.match?(otp_version, &1, allow_pre: true))
  end

  def compatible?(elixir_version, otp_version) when is_binary(elixir_version) do
    elixir_version = ElixirMeta.Util.to_version(elixir_version)
    compatible?(elixir_version, otp_version)
  end

  def compatible?(elixir_version, otp_version) when is_binary(otp_version) or is_integer(otp_version) do
    otp_version = ElixirMeta.Util.to_version(otp_version)
    compatible?(elixir_version, otp_version)
  end
end

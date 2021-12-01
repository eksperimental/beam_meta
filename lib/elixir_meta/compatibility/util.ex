defmodule ElixirMeta.Compatibility.Util do
  @moduledoc false
  
  use ElixirMeta.BackPort

  def to_elixir_version(version) when is_binary(version) do
    Version.parse!(standardized_version(version))
  end

  def to_elixir_version_requirement(version) when is_binary(version) do
    standardized_version = standardized_version(version)
    parsed = Version.parse!(standardized_version)

    standardized_version =
      if parsed.pre != [] or parsed.build != nil do
        standardized_version
      else
        # THIS IS A TRICK TO MATCH ALL PRERELEASES
        standardized_version <> "-0"
      end

    Version.parse_requirement!("~> #{standardized_version}")
  end

  defp standardized_version(version) do
    case String.split(version, ".") do
      [_major, _minor] ->
        "#{version}.0"

      [_major, _minor, _rest] ->
        version
    end
  end
end

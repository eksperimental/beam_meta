defmodule BeamMeta.Util do
  @moduledoc false

  @spec to_version(BeamMeta.elixir_version_representation() | non_neg_integer()) :: Version.t()

  def to_version(version) when is_integer(version) do
    Version.parse!("#{version}.0.0")
  end

  def to_version(version) when is_binary(version) do
    version =
      case String.split(version, ".") do
        # [_major] ->
        #   "#{version}.0.0"

        [_major, _minor] ->
          "#{version}.0"

        [_major, _minor, _rest] ->
          to_string(version)
      end

    Version.parse!(version)
  end

  def to_version(%Version{} = version) do
    version
  end
end

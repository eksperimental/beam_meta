defmodule BeamMeta.Util do
  @moduledoc false

  @spec to_version!(BeamMeta.elixir_version_representation() | non_neg_integer()) :: Version.t()

  def to_version!(version) when is_integer(version) do
    Version.parse!("#{version}.0.0")
  end

  def to_version!(version) when is_binary(version) do
    case Version.parse(version) do
      {:ok, version_struct} ->
        version_struct

      :error ->
        parse_version!(version)
    end
  end

  def to_version!(%Version{} = version) do
    version
  end

  defp parse_version!(version) do
    version =
      case String.split(version, ".", parts: 3) do
        [_major] ->
          "#{version}.0.0"

        [_major, _minor] ->
          "#{version}.0"

        [major, minor, patch] ->
          major <> "." <> minor <> "." <> String.replace(patch, ".", "-", global: false)
      end

    Version.parse!(version)
  end

  def to_version_requirement(version) when is_integer(version) or is_binary(version) do
    version
    |> to_version!()
    |> to_version_requirement()
  end

  def to_version_requirement(%Version{} = version) do
    version_string = to_string(version)

    standardized_version =
      if version.pre != [] or version.build != nil do
        version_string
      else
        # THIS IS A TRICK TO MATCH ALL PRERELEASES
        case version_string do
          "1.0.0" -> "1.0.0"
          _ -> version_string <> "-0"
        end
      end

    Version.parse_requirement!("~> #{standardized_version}")
  end
end

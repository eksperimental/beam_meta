defmodule BeamMeta.Util do
  @moduledoc false

  use BackPort

  @spec to_version!(BeamMeta.elixir_version_representation() | non_neg_integer()) :: Version.t()
  defdelegate to_version!(version), to: BeamLangsMetaData.Helper

  @spec to_version_requirement(Version.t() | String.t() | non_neg_integer()) ::
          Version.requirement()
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

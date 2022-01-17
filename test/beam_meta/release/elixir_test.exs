defmodule BeamMeta.Release.Elixir.Test do
  use ExUnit.Case, async: true

  doctest BeamMeta.Release
  @min_version_count 85
  @min_release_count 65
  @min_prerelease_count 20

  require BeamMeta.Release
  alias BeamMeta.Release

  defp mapper({key, _value}) do
    key
    |> Atom.to_string()
    |> Version.parse!()
  end

  defp get(keyword, ordinal) when is_atom(ordinal) do
    keyword
    |> Enum.sort_by(&mapper/1, Version)
    |> get_ordinal(ordinal)
    |> elem(0)
    |> to_string()
  end

  defp get_ordinal(list, :first), do: List.first(list)
  defp get_ordinal(list, :last), do: List.last(list)

  test "latest_version/0" do
    assert Version.compare(Release.Elixir.latest_version(), "1.13.0") in [:gt, :eq]
    assert Release.Elixir.latest_version() == Release.Elixir.versions() |> List.last()
  end

  test "prereleases/0" do
    assert Release.Elixir.prereleases() |> get(:first) == "1.3.0-rc.0"
  end

  test "releases/0" do
    assert Release.Elixir.releases() |> get(:first) == "1.0.0"

    version = Release.Elixir.releases() |> get(:last)
    assert BeamMeta.Util.to_version(version) == Release.Elixir.latest_version()
  end

  test "release_data/0" do
    assert Release.Elixir.release_data() |> Keyword.has_key?(:"1.0.0") == true
    assert Release.Elixir.release_data() |> Keyword.has_key?(:"1.13.0-rc.1") == true
    assert Release.Elixir.release_data() |> Keyword.has_key?(:"1.13.0") == true
    assert Release.Elixir.release_data() |> Enum.count() >= @min_version_count
  end

  test "release_data/1" do
    assert Release.Elixir.release_data("~> 1.12") |> Keyword.has_key?(:"1.13.0-rc.1") == true

    assert Release.Elixir.release_data("~> 1.12", allow_pre: false)
           |> Keyword.has_key?(:"1.13.0-rc.1") ==
             false
  end

  test "versions/0" do
    assert Release.Elixir.versions() |> List.first() == Version.parse!("1.0.0")
    assert Release.Elixir.versions() |> List.last() == Release.Elixir.latest_version()
  end

  test "versions/1" do
    assert Release.Elixir.versions(:release) |> List.first() == Version.parse!("1.0.0")
    assert Release.Elixir.versions(:release) |> List.last() == Release.Elixir.latest_version()
    assert Release.Elixir.versions(:release) |> Enum.count() >= @min_release_count

    assert Release.Elixir.versions(:prerelease) |> List.first() == Version.parse!("1.3.0-rc.0")
    assert Release.Elixir.versions(:prerelease) |> Enum.count() >= @min_prerelease_count
  end
end

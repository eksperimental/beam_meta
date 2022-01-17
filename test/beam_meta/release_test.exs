defmodule Release.Test do
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

  test "is_elixir_prerelease/1" do
    assert Release.is_elixir_prerelease("1.13.0-rc.0") == true
    assert Release.is_elixir_prerelease("1.13.0-rc.3") == false
    assert Release.is_elixir_prerelease("1.13.0") == false
    assert Release.is_elixir_prerelease("1.99.0-rc.0") == false

    assert Release.is_elixir_prerelease(Version.parse!("1.13.0-rc.0")) == true
    assert Release.is_elixir_prerelease(Version.parse!("1.13.0-rc.3")) == false
    assert Release.is_elixir_prerelease(Version.parse!("1.13.0")) == false
    assert Release.is_elixir_prerelease(Version.parse!("1.99.0-rc.0")) == false
  end

  test "is_elixir_release/1" do
    assert Release.is_elixir_release("1.13.0") == true
    assert Release.is_elixir_release("1.13.0-rc.0") == false
    assert Release.is_elixir_release("1.13.0-rc.3") == false
    assert Release.is_elixir_release("1.99.0") == false

    assert Release.is_elixir_release(Version.parse!("1.13.0")) == true
    assert Release.is_elixir_release(Version.parse!("1.13.0-rc.0")) == false
    assert Release.is_elixir_release(Version.parse!("1.13.0-rc.3")) == false
    assert Release.is_elixir_release(Version.parse!("1.99.0")) == false
  end

  test "is_elixir_version/1" do
    assert Release.is_elixir_version("1.13.0") == true
    assert Release.is_elixir_version("1.13.0-rc.0") == true
    assert Release.is_elixir_version("1.13.0-rc.3") == false
    assert Release.is_elixir_version("1.99.0") == false

    assert Release.is_elixir_version(Version.parse!("1.13.0")) == true
    assert Release.is_elixir_version(Version.parse!("1.13.0-rc.0")) == true
    assert Release.is_elixir_version(Version.parse!("1.13.0-rc.3")) == false
    assert Release.is_elixir_version(Version.parse!("1.99.0")) == false
  end

  test "latest_version/0" do
    assert Version.compare(Release.latest_version(), "1.13.0") in [:gt, :eq]
    assert Release.latest_version() == Release.versions() |> List.last()
  end

  test "prereleases/0" do
    assert Release.prereleases() |> get(:first) == "1.3.0-rc.0"
  end

  test "releases/0" do
    assert Release.releases() |> get(:first) == "1.0.0"

    version = Release.releases() |> get(:last)
    assert BeamMeta.Util.to_version(version) == Release.latest_version()
  end

  test "release_data/0" do
    assert Release.release_data() |> Keyword.has_key?(:"1.0.0") == true
    assert Release.release_data() |> Keyword.has_key?(:"1.13.0-rc.1") == true
    assert Release.release_data() |> Keyword.has_key?(:"1.13.0") == true
    assert Release.release_data() |> Enum.count() >= @min_version_count
  end

  test "release_data/1" do
    assert Release.release_data("~> 1.12") |> Keyword.has_key?(:"1.13.0-rc.1") == true

    assert Release.release_data("~> 1.12", allow_pre: false) |> Keyword.has_key?(:"1.13.0-rc.1") ==
             false
  end

  test "versions/0" do
    assert Release.versions() |> List.first() == Version.parse!("1.0.0")
    assert Release.versions() |> List.last() == Release.latest_version()
  end

  test "versions/1" do
    assert Release.versions(:release) |> List.first() == Version.parse!("1.0.0")
    assert Release.versions(:release) |> List.last() == Release.latest_version()
    assert Release.versions(:release) |> Enum.count() >= @min_release_count

    assert Release.versions(:prerelease) |> List.first() == Version.parse!("1.3.0-rc.0")
    assert Release.versions(:prerelease) |> Enum.count() >= @min_prerelease_count
  end
end

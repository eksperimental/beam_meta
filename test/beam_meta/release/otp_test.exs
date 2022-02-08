defmodule BeamMeta.Release.Otp.Test do
  use ExUnit.Case, async: true

  doctest BeamMeta.Release.Otp
  @min_version_count 334

  alias BeamMeta.{Release, Util}

  defp mapper({key, _value}) do
    key
    |> Atom.to_string()
  end

  defp get(keyword, ordinal) when is_atom(ordinal) do
    keyword
    |> Enum.sort_by(&mapper/1)
    |> get_ordinal(ordinal)
    |> elem(0)
    |> to_string()
  end

  defp get_ordinal(list, :first), do: List.first(list)
  defp get_ordinal(list, :last), do: List.last(list)

  test "latest_version/0" do
    assert Version.compare(Release.Otp.latest_version(), "24.2.0") in [:gt, :eq]
    assert Release.Otp.latest_version() == Release.Otp.versions() |> List.last()
  end

  test "prereleases/0" do
    assert Release.Otp.prereleases() |> get(:first) == "18.0-rc1"
  end

  test "final_releases/0" do
    assert Release.Otp.final_releases() |> get(:first) == "17.0"

    version = Release.Otp.final_releases() |> get(:last)
    assert BeamMeta.Util.to_version!(version) == Release.Otp.latest_version()
  end

  test "release_data/0" do
    results = Release.Otp.release_data()
    assert get(results, :first) == "17.0"
    assert Keyword.has_key?(results, :"17.0") == true
    assert Keyword.has_key?(results, :"20.3.8.25") == true
    assert Keyword.has_key?(results, :"20.3.8.27") == false
    assert Enum.count(results) >= @min_version_count
  end

  test "release_data/1" do
    results = Release.Otp.release_data("~> 24.1")
    assert Keyword.has_key?(results, :"24.1.6") == true
    assert Keyword.has_key?(results, :"24.2") == true
    assert Keyword.has_key?(results, :"24.0") == false
  end

  test "release_data/1 +" do
    assert Release.Otp.release_data("~> 24.1", allow_pre: false)
           |> Keyword.has_key?(:"24.1.6") ==
             true
  end

  test "versions/0" do
    assert Release.Otp.versions() |> List.first() == Version.parse!("17.0.0")
    assert Release.Otp.versions() |> List.last() == Release.Otp.latest_version()
  end

  test "to_original_string/1" do
    assert Version.parse!("23.3.4-10") |> Release.Otp.to_original_string() == "23.3.4.10"
    assert Version.parse!("25.0.0-rc0") |> Release.Otp.to_original_string() == "25.0.0-rc0"
    assert Version.parse!("23.3.4") |> Release.Otp.to_original_string() == "23.3.4"

    assert Util.to_version!("12.34.56.78-rc0") |> Release.Otp.to_original_string() ==
             "12.34.56.78-rc0"

    "12.34.56-78-rc0"
  end
end

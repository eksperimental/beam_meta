defmodule BeamMeta.Release.Otp.Test do
  use ExUnit.Case, async: true

  doctest BeamMeta.Release.Otp
  @min_version_count 334

  alias BeamMeta.Release

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
    assert Release.Otp.latest_version() >= "24.2"
    assert Release.Otp.latest_version() == Release.Otp.versions() |> List.last()
  end

  test "release_data/0" do
    assert Release.Otp.release_data() |> get(:first) == "17.0"
    assert Release.Otp.release_data() |> Keyword.has_key?(:"17.0") == true
    assert Release.Otp.release_data() |> Keyword.has_key?(:"20.3.8.25") == true
    assert Release.Otp.release_data() |> Keyword.has_key?(:"20.3.8.27") == false
    assert Release.Otp.release_data() |> Enum.count() >= @min_version_count
  end

  test "versions/0" do
    assert Release.Otp.versions() |> List.first() == "17.0"
    assert Release.Otp.versions() |> List.last() == Release.Otp.latest_version()
  end
end

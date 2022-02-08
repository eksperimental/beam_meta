defmodule BeamMeta.Util.Test do
  use ExUnit.Case, async: true

  doctest BeamMeta.Util

  require BeamMeta.Util
  alias BeamMeta.Util

  test "to_version!/1" do
    assert Util.to_version!(17) == Version.parse!("17.0.0")

    assert_raise(FunctionClauseError, fn ->
      Util.to_version!(17.0)
    end)

    # Incomplete versions
    assert Util.to_version!("17") == Version.parse!("17.0.0")
    assert Util.to_version!("17.0") == Version.parse!("17.0.0")
    assert Util.to_version!("17.0-rc2.0") == Version.parse!("17.0.0-rc2.0")

    assert Util.to_version!("17.0.0") == Version.parse!("17.0.0")
    assert Util.to_version!("17.0.0-0") == Version.parse!("17.0.0-0")
    assert Util.to_version!("17.0.0.0") == Version.parse!("17.0.0-0")
    assert Util.to_version!("12.34.56.78") == Version.parse!("12.34.56-78")
    assert Util.to_version!("12.34.56.78-rc0") == Version.parse!("12.34.56-78-rc0")
    assert Util.to_version!("1.13.0-rc.0") == Version.parse!("1.13.0-rc.0")

    assert_raise(Version.InvalidVersionError, "invalid version: \"1.2.3-04\"", fn ->
      Util.to_version!("1.2.3-04")
    end)

    assert Util.to_version!("1.2.3-0a4") == Version.parse!("1.2.3-0a4")
    assert Util.to_version!("1.2.3-0a4-04") == Version.parse!("1.2.3-0a4-04")
  end
end

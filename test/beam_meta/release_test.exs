defmodule BeamMeta.Release.Test do
  use ExUnit.Case, async: true

  doctest BeamMeta.Release

  require BeamMeta.Release
  alias BeamMeta.Release

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

  test "is_otp_version/1" do
    assert Release.is_otp_version("17.0") == true
    assert Release.is_otp_version("17.99") == false
    assert Release.is_otp_version("20.3.8.25") == true
    assert Release.is_otp_version("20.3.8.26") == true
    assert Release.is_otp_version("20.3.8.27") == false
    assert Release.is_otp_version("24.2") == true
  end
end

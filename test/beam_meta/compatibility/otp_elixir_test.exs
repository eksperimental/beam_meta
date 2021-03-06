defmodule BeamMeta.Compatibility.OtpElixir.Test do
  use ExUnit.Case, async: true

  doctest BeamMeta.Compatibility.OtpElixir

  test "table/1" do
    assert Map.get(BeamMeta.Compatibility.OtpElixir.table({:elixir, :otp}), "1.0") ==
             %{
               otp_versions: %{
                 17 => %{
                   version: Version.parse!("17.0.0"),
                   version_requirement: Version.parse_requirement!("~> 17.0")
                 }
               },
               version: Version.parse!("1.0.0"),
               version_requirement: Version.parse_requirement!("~> 1.0.0")
             }

    assert Map.get(BeamMeta.Compatibility.OtpElixir.table({:elixir, :otp}), "1.12") ==
             %{
               otp_versions: %{
                 22 => %{
                   version: Version.parse!("22.0.0"),
                   version_requirement: Version.parse_requirement!("~> 22.0")
                 },
                 23 => %{
                   version: Version.parse!("23.0.0"),
                   version_requirement: Version.parse_requirement!("~> 23.0")
                 },
                 24 => %{
                   version: Version.parse!("24.0.0"),
                   version_requirement: Version.parse_requirement!("~> 24.0")
                 }
               },
               version: Version.parse!("1.12.0"),
               version_requirement: Version.parse_requirement!("~> 1.12.0-0")
             }

    assert Map.get(BeamMeta.Compatibility.OtpElixir.table({:otp, :elixir}), 20) ==
             %{
               elixir_versions: %{
                 "1.4.5" => %{
                   version: Version.parse!("1.4.5"),
                   version_requirement: Version.parse_requirement!("~> 1.4.5")
                 },
                 "1.5" => %{
                   version: Version.parse!("1.5.0"),
                   version_requirement: Version.parse_requirement!("~> 1.5.0")
                 },
                 "1.6" => %{
                   version: Version.parse!("1.6.0"),
                   version_requirement: Version.parse_requirement!("~> 1.6.0")
                 },
                 "1.7" => %{
                   version: Version.parse!("1.7.0"),
                   version_requirement: Version.parse_requirement!("~> 1.7.0")
                 },
                 "1.8" => %{
                   version: Version.parse!("1.8.0"),
                   version_requirement: Version.parse_requirement!("~> 1.8.0")
                 },
                 "1.9" => %{
                   version: Version.parse!("1.9.0"),
                   version_requirement: Version.parse_requirement!("~> 1.9.0")
                 }
               },
               version: Version.parse!("20.0.0"),
               version_requirement: Version.parse_requirement!("~> 20.0.0-0")
             }
  end

  test "compatible?/2" do
    assert BeamMeta.Compatibility.OtpElixir.compatible?(24, "1.13") == true
    assert BeamMeta.Compatibility.OtpElixir.compatible?(24, "1.13.999") == true
    assert BeamMeta.Compatibility.OtpElixir.compatible?(24, "1.99") == false

    v1_11_0 = Version.parse!("1.11.0")
    v1_11_4 = Version.parse!("1.11.4")
    v1_13_1 = Version.parse!("1.13.1")
    v1_99_999 = Version.parse!("1.99.999")
    v23_0_1 = Version.parse!("23.0.1")
    v24_0_0 = Version.parse!("24.0.0")
    v24_0_1 = Version.parse!("24.0.1")

    assert BeamMeta.Compatibility.OtpElixir.compatible?(v24_0_1, v1_99_999) == false
    assert BeamMeta.Compatibility.OtpElixir.compatible?(v24_0_1, v1_13_1) == true
    assert BeamMeta.Compatibility.OtpElixir.compatible?(v24_0_1, v1_11_0) == false
    assert BeamMeta.Compatibility.OtpElixir.compatible?(v24_0_0, v1_11_4) == true
    assert BeamMeta.Compatibility.OtpElixir.compatible?(v24_0_1, v1_11_4) == true
    assert BeamMeta.Compatibility.OtpElixir.compatible?(v23_0_1, "1.11") == true
    assert BeamMeta.Compatibility.OtpElixir.compatible?("24.0", v1_11_4) == true
  end

  test "elixir_releases/2" do
    assert BeamMeta.Compatibility.OtpElixir.elixir_releases(19) ==
             ["1.2.6", "1.3", "1.4", "1.4.5", "1.5", "1.6", "1.7"]

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases("19.0") ==
             ["1.2.6", "1.3", "1.4", "1.4.5", "1.5", "1.6", "1.7"]

    v19_0_1 = Version.parse!("19.0.1")

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases(v19_0_1) ==
             ["1.2.6", "1.3", "1.4", "1.4.5", "1.5", "1.6", "1.7"]

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases("19.1") ==
             ["1.2.6", "1.3", "1.4", "1.4.5", "1.5", "1.6", "1.7"]

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases("19.1.1") ==
             ["1.2.6", "1.3", "1.4", "1.4.5", "1.5", "1.6", "1.7"]

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases(Version.parse!("19.1.1")) ==
             ["1.2.6", "1.3", "1.4", "1.4.5", "1.5", "1.6", "1.7"]

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases(21) ==
             ["1.6", "1.7", "1.8", "1.9", "1.10", "1.10.3", "1.11", "1.11.4"]

    # OTP version doesn't exist
    v16_0_1 = Version.parse!("16.0.1")
    assert BeamMeta.Compatibility.OtpElixir.elixir_releases(v16_0_1) == []
    assert BeamMeta.Compatibility.OtpElixir.elixir_releases(16) == []
    assert BeamMeta.Compatibility.OtpElixir.elixir_releases("16.0") == []

    # Test all return_type values
    assert BeamMeta.Compatibility.OtpElixir.elixir_releases("17.1") ==
             ["1.0", "1.0.5", "1.1"]

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases("17.1", :key) ==
             ["1.0", "1.0.5", "1.1"]

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases("17.1", :version) ==
             [Version.parse!("1.0.0"), Version.parse!("1.0.5"), Version.parse!("1.1.0")]

    assert BeamMeta.Compatibility.OtpElixir.elixir_releases("17.1", :version_requirement) == [
             Version.parse_requirement!("~> 1.0.0"),
             Version.parse_requirement!("~> 1.0.5-0"),
             Version.parse_requirement!("~> 1.1.0-0")
           ]
  end

  test "otp_releases/2" do
    assert BeamMeta.Compatibility.OtpElixir.otp_releases("1.0.0") == [17]
    assert BeamMeta.Compatibility.OtpElixir.otp_releases("1.0") == [17]

    assert BeamMeta.Compatibility.OtpElixir.otp_releases("1.2") ==
             [18]

    assert BeamMeta.Compatibility.OtpElixir.otp_releases("1.2.6") ==
             [18, 19]

    # Test all return_type values
    v1_2_6 = Version.parse!("1.2.6")

    assert BeamMeta.Compatibility.OtpElixir.otp_releases(v1_2_6) ==
             [18, 19]

    assert BeamMeta.Compatibility.OtpElixir.otp_releases(v1_2_6, :key) ==
             [18, 19]

    assert BeamMeta.Compatibility.OtpElixir.otp_releases("1.2.6", :version) ==
             [Version.parse!("18.0.0"), Version.parse!("19.0.0")]

    assert BeamMeta.Compatibility.OtpElixir.otp_releases("1.2.6", :version_requirement) == [
             Version.parse_requirement!("~> 18.0"),
             Version.parse_requirement!("~> 19.0")
           ]

    # Elixir version doesn't exist
    v2_0_1 = Version.parse!("2.0.1")
    assert BeamMeta.Compatibility.OtpElixir.otp_releases(v2_0_1) == []
    assert BeamMeta.Compatibility.OtpElixir.otp_releases("2.0") == []
    assert BeamMeta.Compatibility.OtpElixir.otp_releases("2.0.1") == []
  end
end

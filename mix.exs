defmodule ElixirMeta.MixProject do
  use Mix.Project

  @repo_url "https://github.com/eksperimental/elixir_meta"

  def project do
    [
      app: :elixir_meta,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description:
        "A library to programmatically retrieve information related to the Elixir language.",
      aliases: aliases(),
      package: package(),
      deps: deps(),

      # Docs
      name: "ElixirMeta",
      source_url: @repo_url,
      homepage_url: @repo_url,
      docs: [
        # The main page in the docs
        main: "ElixirMeta",
        # logo: "path/to/logo.png",
        extras: [
          "README.md": [filename: "readme", title: "Readme"],
          "LICENSE.md": [filename: "license", title: "License"]
        ],
        source_ref: revision()
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      validate: ["format --check-formatted", "dialyzer", "docs", "credo"]
    ]
  end

  defp package do
    [
      maintainers: ["Eksperimental"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url},
      files: ~w(
          lib/
          LICENSE.md
          mix.exs
          README.md
          .formatter.exs
        )
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_meta_data,
       git: "https://github.com/eksperimental/elixir_meta_data.git", branch: "main"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.26", only: :dev, runtime: false}
    ]
  end

  # Originally taken from: https://github.com/elixir-lang/elixir/blob/2b0abcebbe9acee4a103c9d02c6bae707f0e9e73/lib/elixir/lib/system.ex#L1019
  # Tries to run "git rev-parse --short=7 HEAD". In the case of success returns
  # the short revision hash. If that fails, returns an empty string.
  defp revision do
    null =
      case :os.type() do
        {:win32, _} -> 'NUL'
        _ -> '/dev/null'
      end

    'git rev-parse --short=7 HEAD 2> '
    |> Kernel.++(null)
    |> :os.cmd()
    |> strip
  end

  defp strip(iodata) do
    :re.replace(iodata, "^[\s\r\n\t]+|[\s\r\n\t]+$", "", [:global, return: :binary])
  end
end

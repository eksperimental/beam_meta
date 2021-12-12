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
        ]
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
    ]  end

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
end
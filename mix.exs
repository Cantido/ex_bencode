defmodule ExBencode.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_bencode,
      version: "2.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: "An Elixir library for encoding and decoding BitTorrent's bencoding.",
      package: package(),
      deps: deps(),
      source_url: "https://github.com/Cantido/ex_bencode",
      dialyzer: [ flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 0.11", only: :test},
      {:bento, "~> 0.9.2", only: :test},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  def package do
    [ name: :ex_bencode,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Rosa Richter"],
      licenses: ["GPL-3"],
      links: %{"Github" => "https://github.com/Cantido/ex_bencode"},
    ]
  end
end

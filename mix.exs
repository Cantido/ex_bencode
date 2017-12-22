defmodule ExBencode.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_bencode,
      version: "1.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: "An Elixir library for encoding and decoding BitTorrent's bencoding.",
      package: package(),
      deps: deps(),
      source_url: "https://github.com/Cantido/ex_bencode"
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
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  def package do
    [ name: :ex_bencode,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Rosa Richter"],
      licenses: ["GPL v3"],
      links: %{"Github" => "https://github.com/Cantido/ex_bencode"},
    ]
  end
end

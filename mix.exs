defmodule ExBencode.Mixfile do
  use Mix.Project

  @source_url "https://github.com/Cantido/ex_bencode"
  @version "2.0.2"

  def project do
    [
      app: :ex_bencode,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      description: "An Elixir library for encoding and decoding BitTorrent's bencoding.",
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      name: :ex_bencode,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Rosa Richter"],
      licenses: ["MIT"],
      links: %{"Github" => @source_url}
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:bento, "~> 1.0.0", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "ExBencode",
      api_reference: false,
      extra_section: [],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp dialyzer do
    [
      flags: [
        "-Wunmatched_returns",
        :error_handling,
        :race_conditions,
        :underspecs
      ]
    ]
  end
end

defmodule ExBencode.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_bencode,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps()
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  def package do
    [ name: :ex_bencode,
      files: ["lib", "mix.exs"],
      maintainers: ["Rosa Richter"],
      licenses: ["GPL v3"],
      links: %{"Github" => "https://github.com/Cantido/ex_bencode"},
    ]
  end
end

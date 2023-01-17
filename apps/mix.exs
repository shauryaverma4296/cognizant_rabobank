defmodule Apps.MixProject do
  use Mix.Project

  def project do
    [
      app: :apps,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.sdfsdf
  def application do
    [
      extra_applications: [:logger],
      mod: {Apps.Application, []}
    ]
  end

  # |> xpath( ~x"//records/record"l, name: ~x"./name/text()", accountNumber: ~x"./accountNumber/text()", description: ~x"./description/text()", startBalance: ~x"./startBalance/text()", mutation: ~x"./mutation/text()", endBalance: ~x"./endBalance/text()" )

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:xlsxir, "~> 1.6.4"},
      {:sax_map, "~> 1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

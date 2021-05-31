defmodule ExBetter.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_better_new,
      version: "0.0.1",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:tesla, "~> 1.4.0"},
      # optional, required by JSON middleware
      {:jason, ">= 1.0.0"},
      {:hackney, "~> 1.17.0"},
      {:exvcr, "~> 0.10", only: :test}
    ]
  end

  defp description do
    """
    Library for using BETTER API.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/morgz/ex_better_new.git",
        "Changelog" => "https://github.com/morgz/"
      },
      maintainers: ["Morgz"]
    ]
  end
end

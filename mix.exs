defmodule Porta.Mixfile do
  use Mix.Project

  def project do
    [app: :porta,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases(),
     package: package(),
     description: description()
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ecto, "~> 2.1.3", only: :test},
     {:ex_doc, "~> 0.10", only: :dev}]
  end

  defp aliases do
    ["test": &warn/1]
  end

  defp warn(_), do: raise "run tests in test/app instead"

  defp description do
    """
    Utilities for Phoenix and Ecto
    """
  end

  defp package do
    [
     name: :porta,
     files: ["lib", "priv", "web", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Bob"],
     licenses: ["MPL 2.0"],
     links: %{"GitHub" => "https://github.com/bopjesvla/porta"}]
  end
end

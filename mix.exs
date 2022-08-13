defmodule Concur.MixProject do
  use Mix.Project

  def project do
    [
      app: :concur,
      version: "0.1.0",
      elixir: "~> 1.13",
      description: "Concurrency and streams utilities",
      package: package(),
      docs: docs(),
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:stream_split, "~> 0.1.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      flags: [
        :race_conditions,
        :no_opaque,
        :error_handling,
        :underspecs,
        :unknown,
        :unmatched_returns
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Sebastian Borrazas"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sborrazas/concur"}
    ]
  end

  defp docs do
    [
      main: "Concur",
      source_url: "https://github.com/sborrazas/concur",
      extras: ["README.md"]
    ]
  end
end

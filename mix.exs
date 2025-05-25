defmodule ChatApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_app,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(), # Agregamos aliases para ejecución automática
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ChatApp.Application, []},
      extra_applications: [:logger, :mnesia]
    ]
  end

  defp aliases do
  [
    start: ["run -e ChatApp.Menu.start"]
  ]
 end

  defp deps do
    [
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:pbkdf2_elixir, "~> 2.0"},
      {:libcluster, "~> 3.3"}
    ]
  end
end

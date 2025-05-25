import Config

# Configuración de la base de datos
config :chat_app, ChatApp.Repo,
  username: "postgres",
  password: "tu_contraseña",
  database: "chat_app_dev",
  hostname: "127.0.0.1",
  port: 5432,
  pool_size: 10

config :chat_app,
  ecto_repos: [ChatApp.Repo]

# Configuración de nodos
config :libcluster,
  topologies: [
    epmd_example: [
      strategy: Cluster.Strategy.Epmd,
      config: [hosts: [:"nodo1@Vanessa", :"nodo2@Vanessa", :"nodo3@Vanessa"]],
    ]
  ]

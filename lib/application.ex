# Este modulo inicia la aplicación ChatApp y gestiona los procesos supervisados.
defmodule ChatApp.Application do
  use Application
  require Logger

  def start(_type, _args) do
    # Cargar la configuración de Libcluster para gestionar los nodos
    topologies = Application.get_env(:libcluster, :topologies, [])   # Topologies sirve para la configuración de Libcluster

    # Children es para definir los procesos que se iniciarán al arrancar la aplicación
    children = [
      {Cluster.Supervisor, [topologies, [name: ChatApp.ClusterSupervisor]]}, # Supervisor de nodos
      ChatApp.Repo,       # Base de datos
      ChatApp.Server,     # Servidor de chat
      {ChatApp.Auth,[]},  # Autenticación de usuarios, pasando argumentos
    ]

    # opts sirve para definir las opciones del supervisor
    opts = [strategy: :one_for_one, name: ChatApp.Supervisor]

   case Supervisor.start_link(children, opts) do
  {:ok, pid} ->           # esto indica que el supervisor se ha iniciado correctamente
    # Solo inicia el menú si no es el nodo principal (nodo1)
    if Node.self() != :"nodo1@Vanessa" do
      Task.start(fn ->
        # Pequeño retraso para asegurar que todo esté inicializado
        Process.sleep(500)
        ChatApp.Menu.start()
      end)
    end

    {:ok, pid}

  {:error, {:already_started, pid}} ->
    Logger.warning("Supervisor ya estaba iniciado (PID: #{inspect(pid)})")
    {:ok, pid}

  {:error, reason} ->
    Logger.error("No se pudo iniciar el supervisor: #{inspect(reason)}")
    {:error, reason}
  end

  end

end

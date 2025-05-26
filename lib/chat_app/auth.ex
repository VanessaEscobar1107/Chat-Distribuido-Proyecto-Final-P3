# Este modulo maneja la autenticación de usuarios en la aplicación ChatApp.
defmodule ChatApp.Auth do
  use GenServer       # GenServer es para manejar procesos concurrentes en Elixir
  require Logger      # Logger es para registrar mensajes de log


  @doc """
  Inicia el proceso Auth como parte del árbol de supervisión.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{usuario: nil}, name: __MODULE__)  #  Mantiene sesión en el GenServer
  end

  @impl true
  def init(state) do
    Logger.info("[INFO] Módulo Auth inicializado correctamente.")
    {:ok, state}
  end

  @doc """
  Especificación para el supervisor.
  """
  # `child_spec/1` define cómo se debe iniciar el proceso Auth.
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  Autentica un usuario o crea uno nuevo si no existe.
  """
  def login(username, password) when is_binary(username) and is_binary(password) do
    case ChatApp.Repo.get_by(ChatApp.Schemas.User, username: username) do
      %ChatApp.Schemas.User{password_hash: hash} ->
        if Pbkdf2.verify_pass(password, hash) do
          guardar_sesion(username)  #  Guarda sesión al autenticar
          Logger.info("[INFO] Usuario '#{username}' autenticado correctamente.")
          {:ok, "Bienvenido #{username}!"}
        else
          Logger.warning("[WARN] Contraseña incorrecta para '#{username}'.")
          {:error, "Contraseña incorrecta"}
        end

      nil ->
        Logger.info("[INFO] Usuario '#{username}' no encontrado, creando nuevo...")
        with {:ok, msg} <- create_user(username, password) do
          guardar_sesion(username)  #  Guarda sesión al crear usuario nuevo
          {:ok, msg}
        end
    end
  end

  @doc """
  Crea un nuevo usuario en la base de datos.
  """
  def create_user(username, password) do
    changeset = ChatApp.Schemas.User.changeset(   # changeset es para validar y transformar datos antes de insertarlos en la base de datos
      %ChatApp.Schemas.User{},          # Schemas es para definir la estructura de datos
      %{
        username: username,
        password_hash: Pbkdf2.hash_pwd_salt(password)
      }
    )

    case ChatApp.Repo.insert(changeset) do   # ChatApp.Repo es para interactuar con la base de datos
      {:ok, _user} ->
        Logger.info("[INFO] Usuario '#{username}' creado exitosamente.")
        {:ok, "Usuario creado. Por favor inicie sesión nuevamente."}
      {:error, changeset} ->
        Logger.error("[ERROR] Error al crear usuario: #{inspect(changeset.errors)}")
        {:error, "Error al registrar el usuario"}
    end
  end

  @doc """
  Guarda el usuario en la sesión activa.
  """
  def guardar_sesion(username) when is_binary(username) do
    GenServer.cast(__MODULE__, {:guardar_usuario, username})  #  Ahora se guarda en el GenServer
  end

  @doc """
  Verifica si hay una sesión activa y devuelve el usuario.
  """
  def usuario_activo() do
    GenServer.call(__MODULE__, :obtener_usuario)
  end


  # handle_cast es para manejar mensajes asíncronos enviados al GenServer
  @impl true
  def handle_cast({:guardar_usuario, username}, state) do
    Logger.info("[INFO] Sesión guardada para '#{username}'.")
    {:noreply, %{state | usuario: username}}
  end

  # handle_call es para manejar mensajes síncronos enviados al GenServer
  @impl true
  def handle_call(:obtener_usuario, _from, state) do
    Logger.info("[INFO] Usuario activo: '#{state.usuario}'.")
    {:reply, state.usuario, state}
  end
end

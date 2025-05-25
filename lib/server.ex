defmodule ChatApp.Server do
  use GenServer
  alias ChatApp.Schemas.User

  defmodule Estado do
    defstruct salas: %{}, usuarios: %{}
  end

  def estado do
  GenServer.call(__MODULE__, :estado)
end

  ##  Inicio del servidor
  def start_link(_) do
    GenServer.start_link(__MODULE__, %Estado{}, name: __MODULE__)
  end

  def init(state) do
    IO.puts("[INFO]  Servidor iniciado correctamente...")
    {:ok, state}
  end

  ## Obtener historial de mensajes de una sala
 def historial_mensajes(sala) do
  GenServer.call(__MODULE__, {:historial_mensajes, sala})
 end

  ## Registrar un nuevo usuario
  def handle_call({:nuevo_usuario, username, password}, _from, state) do
    password_hash = Pbkdf2.hash_pwd_salt(password)
    usuario = %User{username: username, password_hash: password_hash}

    IO.puts("[INFO]  Registrando usuario: #{username}")

    nuevo_estado = %Estado{state | usuarios: Map.put(state.usuarios, username, usuario)}
    {:reply, :ok, nuevo_estado}
  end

  ##  Obtener usuarios conectados
  def handle_call(:usuarios_activos, _from, state) do
    {:reply, Map.keys(state.usuarios), state}
  end

  ##  Buscar usuario por nombre
  def handle_call({:buscar_usuario, username}, _from, state) do
    {:reply, Map.get(state.usuarios, username), state}
  end

    def handle_call(:estado, _from, %Estado{} = state) do
  {:reply, state, state}
  end

  def handle_call({:historial_mensajes, sala}, _from, state) do
  mensajes = Map.get(state.salas, sala, [])

  IO.puts("[HISTORIAL]  Mensajes en '#{sala}':")
  Enum.each(mensajes, &IO.puts("[historial] #{&1}"))

  {:reply, mensajes, state}

end

  ##  Crear sala
  def handle_cast({:crear_sala, sala}, state) do
  sala = String.trim(sala)

  if Map.has_key?(state.salas, sala) do
    IO.puts("[INFO]  La sala '#{sala}' ya existe.")
    {:noreply, state}
  else
    salas_actualizadas = Map.put(state.salas, sala, [])
    IO.puts("[INFO]  Sala '#{sala}' creada exitosamente.")

    #  Difundir el estado actualizado a los otros nodos
    Enum.each(Node.list(), fn nodo ->
      GenServer.cast({ChatApp.Server, nodo}, {:actualizar_salas, salas_actualizadas})
    end)

    {:noreply, %Estado{state | salas: salas_actualizadas}}
  end
end

## Actualizar salas en otros nodos
def handle_cast({:actualizar_salas, salas}, state) do
  IO.puts("[INFO]  Estado de salas sincronizado con otros nodos.")
  {:noreply, %Estado{state | salas: salas}}
end

  ##  Unirse a sala
  def handle_cast({:unirse, usuario, sala}, state) do
    sala = String.trim(sala)

    if Map.has_key?(state.salas, sala) do
      salas_actualizadas = Map.update!(state.salas, sala, fn usuarios -> [usuario | usuarios] end)
      IO.puts("[INFO]  #{usuario} se ha unido a la sala '#{sala}'.")

      {:noreply, %Estado{state | salas: salas_actualizadas}}
    else
      IO.puts("[ERROR]  La sala '#{sala}' no existe.")
      {:noreply, state}
    end
  end

  ##  Enviar mensaje a sala
 def handle_cast({:enviar_mensaje, usuario, mensaje, sala}, state) do
  sala = String.trim(sala)

  if Map.has_key?(state.salas, sala) do
    _usuarios_en_sala = Map.get(state.salas, sala, [])
    mensajes_actualizados = Map.update(state.salas, sala, [mensaje], fn msgs -> msgs ++ ["#{usuario}: #{mensaje}"] end)

    IO.puts("[CHAT]  #{usuario} en '#{sala}': #{mensaje}")

    #  Difundir el mensaje a los otros nodos
    Enum.each(Node.list(), fn nodo ->
      GenServer.cast({ChatApp.Server, nodo}, {:propagar_mensaje, usuario, mensaje, sala})
    end)

    {:noreply, %Estado{state | salas: mensajes_actualizados}}
  else
    IO.puts("[ERROR]  No se puede enviar mensaje. La sala '#{sala}' no existe.")
    {:noreply, state}
  end
end

##  Propagar mensaje a otros nodos
def handle_cast({:propagar_mensaje, usuario, mensaje, sala}, state) do
  IO.puts("[CHAT]  Mensaje recibido de otro nodo")
  IO.puts("[CHAT]  #{usuario} en '#{sala}': #{mensaje}")

  {:noreply, state}
end



end

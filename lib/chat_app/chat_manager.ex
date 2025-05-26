# Este modulo se encarga de coordinar las salas de chat, los usuarios conectados
# y mensajes dentro del chat.
defmodule ChatApp.ChatManager do
  import Ecto.Query       # import Ecto.Query es para hacer consultas a la base de datos
  use GenServer           # GenServer es para manejar procesos concurrentes en Elixir

  alias ChatApp.Schemas.ConnectedUser  # Ecto schema para usuarios conectados
  alias ChatApp.Repo                   # Interactuar con la base de datos
  alias Bcrypt                         # Bcrypt es para el manejo de contraseñas


  # Esta funcion inicia el GenServer y lo registra con un nombre
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Esta funcion init es para inicializar el estado del GenServer
  def init(_state) do
    {:ok, %{}}
  end

  # Funcion para crear una sala de chat
  def create_room(name) do
    GenServer.call(__MODULE__, {:create_room, name})
  end

  # Funcion para unirse a una sala de chat
  def join_room(user, room) do
    GenServer.call(__MODULE__, {:join_room, user, room})
  end

  # Funcion para enviar un mensaje a una sala de chat
  def send_message(user, room, content) do
    GenServer.call(__MODULE__, {:send_message, user, room, content})
  end

  # Funcion para obtener los mensajes de una sala de chat
  def get_messages(room) do
    GenServer.call(__MODULE__, {:get_messages, room})
  end

  # Funcion para que un usuario salga de una sala de chat
  def leave_room(user, room) do
    GenServer.call(__MODULE__, {:leave_room, user, room})
  end

  # Funcion para listar los usuarios conectados a una sala de chat
  def list_users(room) do
    GenServer.call(__MODULE__, {:list_users, room})
  end

  # Funcion para guardar el chat de una sala en un formato especificado
  def save_chat(room, format) do
  GenServer.call(__MODULE__, {:save_chat, room, format})
end

# Funcion para guardar el historial de mensajes de una sala en un formato especificado
defp save_as_txt(room, messages) do
  File.mkdir_p!("saved_chats")  # Asegurar que la carpeta existe

  content =
    Enum.map(messages, fn {msg, timestamp} -> "[#{timestamp}] #{msg}" end)
    |> Enum.join("\n")

  file_path = "saved_chats/#{room}.txt"
  File.write!(file_path, content)

  :ok  #  Cambiado para evitar errores con GenServer
end

# Funcion para guardar el historial de mensajes de una sala en formato JSON
defp save_as_json(room, messages) do
  File.mkdir_p!("saved_chats")  # Asegurar que la carpeta existe

  json_content =
    Enum.map(messages, fn {msg, timestamp} ->
      %{message: msg, timestamp: timestamp}
    end)
    |> Jason.encode!()

  file_path = "saved_chats/#{room}.json"
  File.write!(file_path, json_content)

  :ok  #  Cambiado para evitar errores con GenServer
end

# Funcion para obtener el historial de chat de una sala
def get_chat_history(room) do
  GenServer.call(__MODULE__, {:get_chat_history, room})
end

# Funcion para que un usuario salga del chat
def exit_chat(user) do
  GenServer.call(__MODULE__, {:exit_chat, user})
end

# Funcion para registrar un nuevo usuario
def register_user(username, password) do
  password_hash = Pbkdf2.hash_pwd_salt(password)

  %ChatApp.Schemas.User{}
  |> ChatApp.Schemas.User.changeset(%{username: username, password_hash: password_hash})
  |> ChatApp.Repo.insert()
end

# Funcion para autenticar un usuario con su nombre de usuario y contraseña
def authenticate_user(username, password) do
  user = ChatApp.Repo.get_by(ChatApp.Schemas.User, username: username)

  case user do
    nil -> {:error, "Usuario no encontrado"}
    _ ->
      if Pbkdf2.verify_pass(password, user.password_hash) do  # Usamos Pbkdf2
        {:ok, "Autenticación exitosa"}
      else
        {:error, "Contraseña incorrecta"}
      end
  end
end

## ---- Manejo de llamadas ---- ##


# Funcion para salir del chat
def handle_call({:exit_chat, user}, _from, state) do
  # Eliminar de la base de datos
  Repo.delete_all(from cu in ConnectedUser, where: cu.username == ^user)

  # Eliminar de memoria en GenServer
  new_state =
    Enum.reduce(state, %{}, fn {room, users}, acc ->
      updated_users = List.delete(users, user)
      Map.put(acc, room, updated_users)
    end)

  {:reply, :ok, new_state}
end


# Funcion para obtener el historial de chat de una sala
def handle_call({:get_chat_history, room}, _from, state) do
  chat_room_struct = ChatApp.Repo.get_by(ChatApp.Schemas.ChatRoom, name: room)

  if chat_room_struct do
    messages =
      ChatApp.Repo.all(
        from m in ChatApp.Schemas.Message,
        where: m.chat_room_id == ^chat_room_struct.id,
        order_by: [asc: m.inserted_at],
        select: {m.content, m.inserted_at}
      )

    {:reply, messages, state}
  else
    {:reply, {:error, "Sala no encontrada en la base de datos"}, state}
  end
end


# Funcion para guardar el chat de una sala en un formato especificado
def handle_call({:save_chat, room, format}, _from, state) do
  chat_room_struct = ChatApp.Repo.get_by(ChatApp.Schemas.ChatRoom, name: room)

  if chat_room_struct do
    messages =
      ChatApp.Repo.all(
        from m in ChatApp.Schemas.Message,
        where: m.chat_room_id == ^chat_room_struct.id,
        order_by: [asc: m.inserted_at],
        select: {m.content, m.inserted_at}
      )

    case format do
      "txt" -> save_as_txt(room, messages)
      "json" -> save_as_json(room, messages)
      _ -> {:reply, {:error, "Formato no soportado"}, state}
    end

    {:reply, :ok, state}  # GenServer solo devuelve `:ok`
  else
    {:reply, {:error, "Sala no encontrada en la base de datos"}, state}
  end
end


 # Funcon para crear una sala de chat
  def handle_call({:create_room, name}, _from, state) do
    new_state = Map.put(state, name, [])
    {:reply, :ok, new_state}
  end

  # Funcion para unirse a una sala de chat
  def handle_call({:join_room, user, room}, _from, state) do
    case Repo.get_by(ConnectedUser, username: user, room: room) do
      nil ->
        Repo.insert(%ConnectedUser{username: user, room: room})
        new_state = Map.put(state, room, [user | Map.get(state, room, [])])
        {:reply, :ok, new_state}

      _ ->
        {:reply, {:error, "El usuario ya está en la sala"}, state}
    end
  end

  # Funcion para enviar un mensaje a una sala de chat
  def handle_call({:send_message, user, room, content}, _from, state) do
    chat_room_struct = Repo.get_by(ChatApp.Schemas.ChatRoom, name: room)
    user_struct = Repo.get_by(ChatApp.Schemas.User, username: user)

    if chat_room_struct && user_struct do
      timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      IO.puts("[#{room}] #{user}: #{content} (#{timestamp})")

      Repo.insert(%ChatApp.Schemas.Message{
        content: content,
        user_id: user_struct.id,
        chat_room_id: chat_room_struct.id,
        inserted_at: timestamp,
        updated_at: timestamp
      })

      #  Notificar a los usuarios conectados
      connected_users = Map.get(state, room, [])
      Enum.each(connected_users, fn _u ->
        IO.puts(" [#{room}] Nuevo mensaje de #{user}: '#{content}' a las #{timestamp}")
      end)

      {:reply, :ok, state}
    else
      {:reply, {:error, "Sala o usuario no encontrado en la base de datos"}, state}
    end
  end

  # Funcion para obtener los mensajes de una sala de chat
  def handle_call({:get_messages, room}, _from, state) do
    chat_room_struct = Repo.get_by(ChatApp.Schemas.ChatRoom, name: room)

    if chat_room_struct do
      messages =
        Repo.all(
          from m in ChatApp.Schemas.Message,
          where: m.chat_room_id == ^chat_room_struct.id,
          order_by: [asc: m.inserted_at],
          select: {m.content, m.inserted_at}
        )

      {:reply, messages, state}
    else
      {:reply, {:error, "Sala no encontrada en la base de datos"}, state}
    end
  end

  # Funcion para que un usuario salga de una sala de chat
  def handle_call({:leave_room, user, room}, _from, state) do
    Repo.delete_all(from cu in ConnectedUser, where: cu.username == ^user and cu.room == ^room)

    new_users = List.delete(Map.get(state, room, []), user)
    new_state = Map.put(state, room, new_users)

    {:reply, :ok, new_state}
  end

  # Funcion para listar los usuarios conectados a una sala de chat
  def handle_call({:list_users, room}, _from, state) do
    users = Repo.all(from cu in ConnectedUser, where: cu.room == ^room, select: cu.username)
    {:reply, users, state}
  end
end

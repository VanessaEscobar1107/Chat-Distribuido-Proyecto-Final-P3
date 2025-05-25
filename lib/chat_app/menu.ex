defmodule ChatApp.Menu do

  def start do

    case ChatApp.Auth.usuario_activo() do
      nil -> iniciar_sesion()
      username ->
        IO.puts("\n Sesión iniciada como #{username}.. Entrando al menú principal")
        mostrar_menu(username)

      end

    end

    def iniciar_sesion() do

      IO.puts("\n ====== INCIO DE SESIÓN ======")
      username = IO.gets("Usuario: ") |> String.trim()
      password = IO.gets("Contraseña: ") |> String.trim()

      case ChatApp.Auth.login(username, password) do
        {:ok, _user} ->
          ChatApp.Auth.guardar_sesion(username)
          IO.puts("\n Bienvenid@, #{username}")
          mostrar_menu(username)

          {:error, reason} ->
            IO.puts("\n Error: #{reason}")
            iniciar_sesion()

      end
    end

      def mostrar_menu(username) do

        IO.puts("""
        ________________________________________
        Usuario: #{username}
        1. Ver usuarios conectados
        2. Unirse a una sala
        3. Crear una sala
        4. Consultar historial de mensajes
        5. Salir
        ________________________________________
        """)

        opcion = IO.gets("Seleccione una opción: ") |> String.trim()
        handle_option(username, opcion)
      end


      def handle_option(username, opcion) do
        case opcion do
          "1" -> list_users(username)
          "2" -> join_room(username)
          "3" -> create_room(username)
          "4" -> consult_history(username)
          "5" ->
            IO.puts("\n El usuario #{username} ha salido ...")
            System.halt(0)

            _ ->
              IO.puts("\n Opción no válida. Intente nuevamente.")
              mostrar_menu(username)
        end
      end

  # Los usuarios pueden registrarse y unirse a salas de chat
 def chat_loop(username, sala) do
  IO.puts("\n Has ingresado a la sala '#{sala}'. Escribe '/salir' para salir del chat.")
  loop_chat(username, sala)
 end

 def loop_chat(username, sala) do

  mensaje = IO.gets("\n #{username}: ") |> String.trim()

  case mensaje  do
    "/usuarios" ->
      IO.puts("\n Lista de los usuarios conectados:")
      IO.inspect(Node.list(), label: "Usuarios activos")
      loop_chat(username, sala)

      "/historial" ->
        IO.puts("\n Historial de mensajes en '#{sala}': ")
        ChatApp.Server.historial_mensajes(sala)
        loop_chat(username, sala)

        "/salir" ->
          IO.puts("\n Has salido de la sala...")
          mostrar_menu(username)

          _ ->
            GenServer.cast(ChatApp.Server, {:enviar_mensaje, username, mensaje, sala})
            loop_chat(username, sala)
  end
 end

 def list_users(username) do
  IO.puts("Lista de usuarios conectados:")
  IO.inspect(Node.list(), label: "Usuarios activos")
  mostrar_menu(username)
 end

def join_room(username) do
  sala = IO.gets("Ingrese el nombre de la sala a la que desea unirse: ") |> String.trim()
  GenServer.cast(ChatApp.Server, {:unirse, username, sala})
  IO.puts(" Has ingresado a la sala '#{sala}'. Puedes comenzar a chatear.")

  chat_loop(username, sala)  #  Inicia el chat en tiempo real
end

 def create_room(username) do
  sala = IO.gets("Ingrese el nombre de la sala que desea crear: ") |> String.trim()
  GenServer.cast(ChatApp.Server, {:crear_sala, sala})
  mostrar_menu(username)
end

def consult_history(username) do
  sala = IO.gets("Ingrese el nombre de la sala para ver el historial: ") |> String.trim()
  ChatApp.Server.historial_mensajes(sala)

  mostrar_menu(username)
end

end

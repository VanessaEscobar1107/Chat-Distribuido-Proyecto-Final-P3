```elixir```

## Introducción ##
Este documento describe cómo instalar, configurar y admisnitrar el "Servidor de Chat"
Distribuido en Elixir. 

✓ El servidor se encarga de:
 
 → Gestionar  la conexión entre nodos en la red distribuida.
 → Supervisar la autenticación y almacenamiento de sesiones de usuario.
 → Administrar las salas de chat y procesar los mensajes.
 → Garantizar la tolerancia a fallos ante desconexiones inesperadas.

## Instalación y Configuración ##
Antes de iniciar el servidor, instala las dependencias necesarias:

    mix deps.get
    mix compile

✓ Ejecutar el servidor:
                         iex --sname nodo1@Vanessa -S mix

 Esto iniciará el nodo principal (nodo1), encargado de gestionar las conexiones. 

→ Verificar los nodos conectados:
                                 Node.list()

→ Si los nodos no aparecen, conectarlos manualmente:

                         Node.connect(:nodo2@Vanessa)
                         Node.connect(:nodo3@Vanessa)                    

## Gestión de Usuarios y Autenticación ##
El servidor maneja la autenticación con ChatApp.Auth, almacenando sesiones de usuario mediante GenServer.

° Registrar o autenticar un usuario:

            ChatApp.Auth.login("Jimena", 123)
   
    → Si el usuario no existe, se crea automáticamente.

° Ver sesión activa:

                  ChatApp.Auth.usuario_activo()

° Administración de Salas de Chat:

 → Crear una nueva sala: 
                        
                        ChatApp.Menu.create_room("General")
 
 → Unirse a una sala existente:
                  
                       ChatApp.Menu.join_room("General")

→ Ver el historial de mensajes:
      
                    ChatApp.Menu.consult_history("General")

## Supervisión del Sistema ##
El servidor es supervisado para reiniciar procesos en caso de fallos.

✓ Para revisar logs de actividad:
        Logger.info("Verificando actividad del servidor...")

✓ Para verficar que ChatApp.Auth está funcionando:
        Process.whereis(ChatApp.Auth)
 
 → Si devulve nil, el servidor debe ser reiniciado.

 ## Tolerancia a fallos y Recuperación ##
 Si un nodo se desconecta inesperadamente, el servidor sigue funcionando.

 ✓ Reconectar un nodo manualmente:

             Node.connect(:nodoX@Vanessa)

✓  Verificar la lista de nodos activos:

             Node.list()

✓ Si el nodo sigue desconectado, reiniciar:

              iex --sname nodoX@Vanessa -S mix





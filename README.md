
```elixir```

## Manual de Usuario - ChatApp ##

Sistema de Chat Distribuido en Elixir.


**Introducción**
  ChatApp es una aplicación de comunicación en tiempo real que permite a los usuarios  comunicarse 
  en diferentes nodos: 

  ° Ver usuarios conectados
  ° Unirse a una sala de chat
  ° Crear una nueva sala de chat
  ° Consultar el historial de mensajes 
  ° Salir del chat
  
 Este manual guiará paso a paso en cómo usarlo correctamente.

# Inicio del Sistema

  1. Abrir tres terminales y ejecutar los siguientes comandos:

    ✓ Nodo 1:
               iex --sname nodo1@Vanessa -S mix

    ✓ Nodo 2:
               iex --sname nodo2@Vanessa -S mix

    ✓ Nodo 3:
               iex --sname nodo3@Vanessa -S mix

    ✓ Nodo 4(+): 
              iex --sname nodo4@Vanessa -S mix
               

   **Confirmar la conexión de los nodos:**

                Node.list()

  2. Si los nodos no aparecen en la lista [], conéctarlos manualmente:

      ✓ Nodo 1:
                 Node.connect(:nodo2@Vanessa)
                 Node.connect(:nodo3@Vanessa)

      ✓ Nodo 2:
                 Node.connect(:nodo1@Vanessa)
                 Node.connect(:nodo3@Vanessa)

      ✓ Nodo 3:
                 Node.connect(:nodo1@Vanessa)
                 Node.connect(:nodo2@Vanessa)    

  → Verificar que todos los nodos esten conectados:

                  Node.list()               

# Uso del chat 

   Iniciar sesión o registrase:
   
   Al arrancar el sistema, aparece una pantalla de inicio de sesión:

    • Usuarios nuevos:     Escribir el nombre y la contraseña. Si el usuario no existe
                           se creará automáticamente.
    • Usuarios existentes: Ingresar su nombre y contraseña. 

   ejemplo:
  
   == INICIO DE SESIÓN ==
   Usuario: Jimena
   Contraseña: *****

# Crear una sala de chat 

  Para crear una nueva sala, selecciona la opción  "3. Crear una sala" en el menú principal.

  ejemplo:               
                 ChatApp.Menu.create_room("General")

  Nota: La sala 'General' estará disponible para los otros usuarios.               

# Unirse a una sala 

  Para chatear en una sala existente, selecciona  "2. Unirse a una sala" e ingresar
  el  nombre de la sala.

  ejemplo: 
                 ChatApp.Menu.join_room("Ana")

  De está manera se puede enviar los mensajes y hablar con los demás.

# Enviar los mensajes 

  Para chatear, simplemente "escribe el mensaje en la terminal  después de unirse a una
  sala.

  ejemplo:   Ana: Hola, amigo
             [CHAT] Ana en 'General': Hola, amigo

# Historial de mensajes 

  Si desea ver el historial de chat enviados anteriormente en una sala, usar la opcion
  "4. Consultar historial de mensajes".

  ejemplo: 
              ChatApp.Menu.consult_history("General")

  Esto mostrará los mensajes previos de la sala ("General").

  ejemplo:
              [12:30] Ana: Hola, amigo  
              [12:32] Carlos: ¿Cómo estás?  


# Ver los usuarios conectados 

  Para conocer cuántos usuarios están activos, selecciona 1. Ver usuarios conectados
  en el menú.

# Salir del chat 

  Si en cualquier momento desea salir de la sala actual, simplemente escribes "/salir".
  Se devolverá al menú principal.


```markdown

## Sección de Tolerancia a Fallos ##

 El sistema es distribuido, así que podemos indicar qué hacer si un nodo se desconecta.

 Si un nodo se desconecta inesperadamente, los demás nodos siguen funcionando.
 Para reconectar el nodo manualmente, se usa el siguiente comando desde cualquier
 nodo activo.

 
         Node.connect(:nodoX@Vanessa)

  ejemplo: Si nodo2@Vanessa se desconectó en nodo1@Vanessa      -> ejecuta:

            Node.connect(:nodo2@Vanessa)

  → También puedes verificar los nodos conectados con:

            Node.list()
 
  → Si el nodo sigue desconectado, reinicia la terminal con:

          iex --sname nodoX@Vanessa -S mix




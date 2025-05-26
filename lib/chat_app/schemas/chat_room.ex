# Este modulo sirve para definir el esquema de la sala de chat.
defmodule ChatApp.Schemas.ChatRoom do
  use Ecto.Schema                        # use Ecto.Schema para definir el esquema
  alias ChatApp.Schemas.Message

  schema "chat_rooms" do
    field :name, :string             # field para el nombre de la sala
    has_many :messages, Message      # has_many para las relaciones con los mensajes
    timestamps()                     # timestamps para crear campos de fecha y hora
  end
end

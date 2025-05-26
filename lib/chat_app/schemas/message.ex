# Este modulo se encarga de manejar la logica de los mensajes dentro
# del sistema de chat.
defmodule ChatApp.Schemas.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    belongs_to :user, ChatApp.Schemas.User
    belongs_to :chat_room, ChatApp.Schemas.ChatRoom
    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id, :chat_room_id])
    |> validate_required([:content, :user_id, :chat_room_id])
  end
end

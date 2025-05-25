defmodule ChatApp.Schemas.ChatRoom do
  use Ecto.Schema
  alias ChatApp.Schemas.Message

  schema "chat_rooms" do
    field :name, :string
    has_many :messages, Message
    timestamps()
  end
end

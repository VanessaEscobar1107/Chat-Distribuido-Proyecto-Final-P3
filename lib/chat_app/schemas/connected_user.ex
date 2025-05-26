# Este modulo ConnectedUser define el esquema para los usuarios conectados
# en la aplicación ChatApp.
defmodule ChatApp.Schemas.ConnectedUser do
 #alias ChatApp.Schemas.ConnectedUser
  use Ecto.Schema

  schema "connected_users" do
    field :username, :string
    field :room, :string

    timestamps()
  end
end

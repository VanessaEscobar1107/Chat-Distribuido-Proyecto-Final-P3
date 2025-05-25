defmodule ChatApp.Schemas.ConnectedUser do
  use Ecto.Schema

  schema "connected_users" do
    field :username, :string
    field :room, :string

    timestamps()
  end
end
defmodule ChatApp.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :password_hash, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password_hash])
    |> validate_required([:username, :password_hash])
    |> update_change(:password_hash, &Pbkdf2.hash_pwd_salt/1)
    |> unique_constraint(:username)
  end
end

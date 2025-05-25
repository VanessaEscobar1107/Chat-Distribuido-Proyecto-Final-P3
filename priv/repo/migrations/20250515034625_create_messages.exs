defmodule ChatApp.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :chat_room_id, references(:chat_rooms, on_delete: :delete_all), null: false
      timestamps()
    end
  end
end

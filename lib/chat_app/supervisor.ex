defmodule ChatApp.Supervisor do

  use Supervisor

  def start_link(_) do       # Start_link inicia el supervisor
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

 def init(_) do       # init define la estrategia de supervisión
    children = [
      {ChatApp.ChatManager, []}  # Agregamos ChatManager como proceso supervisado
    ]

    Supervisor.init(children, strategy: :one_for_one) # Si un proceso falla, solo se reinicia ese proceso

  end
end

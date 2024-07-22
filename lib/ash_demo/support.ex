defmodule AshDemo.Support do
  @moduledoc false
  use Ash.Domain

  resources do
    resource AshDemo.Support.Ticket
    resource AshDemo.Support.Representative
  end
end

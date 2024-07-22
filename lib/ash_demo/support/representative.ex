defmodule AshDemo.Support.Representative do
  @moduledoc false
  use Ash.Resource,
    otp_app: :ash_demo,
    domain: AshDemo.Support

  actions do
    defaults [:read, create: [:name]]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end
  end

  relationships do
    has_many :tickets, AshDemo.Support.Ticket do
      public? true
    end
  end
end

defmodule AshDemo.Blog.Comment do
  @moduledoc false
  use Ash.Resource,
    otp_app: :ash_demo,
    domain: AshDemo.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "comments"
    repo AshDemo.Repo
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :body, :string do
      allow_nil? false
      public? true
    end
  end

  relationships do
    belongs_to :post, AshDemo.Blog.Post
  end
end

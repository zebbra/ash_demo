defmodule AshDemo.Blog.Comment do
  @moduledoc false

  use Ash.Resource,
    otp_app: :ash_demo,
    domain: AshDemo.Blog,
    data_layer: AshPostgres.DataLayer

  alias AshDemo.Blog.Post

  postgres do
    table "comments"
    repo AshDemo.Repo

    references do
      reference :post,
        on_delete: :delete,
        on_update: :update,
        index?: true
    end
  end

  resource do
    plural_name :comments
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :text, :string, allow_nil?: false, public?: true
  end

  relationships do
    belongs_to :post, Post
  end
end

defmodule AshDemo.Blog.Category do
  @moduledoc false

  use Ash.Resource,
    otp_app: :ash_demo,
    domain: AshDemo.Blog,
    data_layer: AshPostgres.DataLayer

  alias AshDemo.Blog.Post

  postgres do
    table "categories"
    repo AshDemo.Repo
  end

  resource do
    plural_name :categories
  end

  code_interface do
    define :list, action: :read
  end

  actions do
    defaults [:destroy, create: :*, update: :*]

    read :read do
      primary? true
      prepare build(sort: :name)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
  end

  relationships do
    has_many :posts, Post
  end

  aggregates do
    count :posts_count, :posts
  end

  identities do
    identity :name, [:name]
  end
end

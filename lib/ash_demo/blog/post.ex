defmodule AshDemo.Blog.Post do
  @moduledoc false
  use Ash.Resource,
    otp_app: :ash_demo,
    domain: AshDemo.Blog,
    data_layer: AshPostgres.DataLayer

  alias AshDemo.Blog.Comment

  postgres do
    table "posts"
    repo AshDemo.Repo
  end

  resource do
    plural_name :posts
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    update :publish do
      change set_attribute(:published_at, &DateTime.utc_now/0)
    end

    update :unpublish do
      change set_attribute(:published_at, nil)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, allow_nil?: false, public?: true
    attribute :body, :string, allow_nil?: false, public?: true
    attribute :published_at, :utc_datetime, allow_nil?: true, public?: false

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :comments, Comment
  end

  calculations do
    calculate :published?, :boolean do
      calculation expr(not is_nil(published_at))
    end
  end

  aggregates do
    count :comments_count, :comments
  end
end

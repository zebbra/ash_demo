defmodule AshDemo.Blog.Post do
  @moduledoc false
  use Ash.Resource,
    otp_app: :ash_demo,
    domain: AshDemo.Blog,
    data_layer: AshPostgres.DataLayer

  alias AshDemo.Blog.Category
  alias AshDemo.Blog.Comment

  postgres do
    table "posts"
    repo AshDemo.Repo

    references do
      reference :category,
        index?: true,
        on_delete: :nilify,
        on_update: :update
    end
  end

  resource do
    plural_name :posts
  end

  code_interface do
    define :read
    define :get_by_id, action: :read, get_by: :id
    define :publish
    define :unpublish
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    update :publish do
      change set_attribute(:published_at, &DateTime.utc_now/0)
      change load(:published?)
    end

    update :unpublish do
      change set_attribute(:published_at, nil)
      change load(:published?)
    end

    update :add_comment do
      require_atomic? false
      argument :comment, :string, allow_nil?: false, public?: true
      change manage_relationship(:comment, :comments, type: :create, value_is_key: :text)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, allow_nil?: false, public?: true
    attribute :body, :string, allow_nil?: false, public?: true
    attribute :published_at, :utc_datetime, allow_nil?: true, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :comments, Comment
    belongs_to :category, Category, attribute_public?: true
  end

  calculations do
    calculate :category_name, :string do
      calculation expr(category.name)
    end

    calculate :published?, :boolean do
      calculation expr(not is_nil(published_at))
    end

    calculate :tsv, AshPostgres.Tsvector do
      calculation expr(
                    fragment(
                      "to_tsvector('simple', ?) || to_tsvector('simple', ?)",
                      title,
                      body
                    )
                  )
    end

    calculate :matching?, :boolean do
      argument :search, :search_query, allow_nil?: false
      calculation expr(fragment("? @@ to_tsquery(?)", tsv, ^arg(:search)))
    end
  end

  aggregates do
    count :comments_count, :comments
  end
end

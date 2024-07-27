defmodule AshDemo.Blog.Post.Filter do
  @moduledoc false

  use AshDemo.Search.Filter,
    apply: AshDemo.Blog.Post.Filter.Apply

  alias AshDemo.Blog.Category

  require Ash.Query

  defmodule Apply do
    @moduledoc false

    use Ash.Resource.Actions.Implementation

    require Ash.Query

    @impl true
    def run(input, ctx, _opts) do
      %{query: query, filter: filter} = input.params

      query = Enum.reduce(filter.params, query, &apply_filter(&1, &2, ctx))

      {:ok, query}
    end

    @spec apply_filter({atom, any}, Ash.Query.t(), any) :: Ash.Query.t()

    defp apply_filter({_, nil}, query, _ctx), do: query

    defp apply_filter({:search, string}, query, _ctx) do
      Ash.Query.filter(query, matching?(search: ^string))
    end

    defp apply_filter({:with_comments, true}, query, _ctx) do
      Ash.Query.filter(query, comments_count > 0)
    end

    defp apply_filter({:status, :draft}, query, _ctx) do
      Ash.Query.filter(query, not published?)
    end

    defp apply_filter({:status, :published}, query, _ctx) do
      Ash.Query.filter(query, published?)
    end

    defp apply_filter({:category_id, category_id}, query, _ctx) do
      Ash.Query.filter(query, category_id == ^category_id)
    end

    defp apply_filter(_filter, query, _ctx), do: query
  end

  defmodule Status do
    @moduledoc false
    use Ash.Type.Enum, values: [:all, :draft, :published]
  end

  code_interface do
    domain AshDemo.Blog
    define :new
    define :update
  end

  actions do
    defaults [:read]
    default_accept :*

    create :new do
      primary? true
      argument :category_id, :string
      change manage_relationship(:category_id, :category, type: :append_and_remove)
    end

    update :update do
      primary? true
      argument :category_id, :string
      change manage_relationship(:category_id, :category, type: :append_and_remove)
    end
  end

  changes do
    change load(:category)
    change load(:categories)
  end

  attributes do
    attribute :search, :string, allow_nil?: true, public?: true
    attribute :with_comments, :boolean, default: false, public?: true
    attribute :status, Status, default: :all, public?: true
  end

  relationships do
    has_many :categories, Category do
      no_attributes? true
    end

    belongs_to :category, Category
  end
end

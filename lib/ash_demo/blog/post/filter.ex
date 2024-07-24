defmodule AshDemo.Blog.Post.Filter do
  @moduledoc false

  use Ash.Resource,
    data_layer: :embedded,
    embed_nil_values?: false

  alias Ash.Changeset
  alias Ash.Resource.Info
  alias AshDemo.Blog.Category

  require Ash.Query
  require Ash.Resource.Change.Builtins

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
    define :apply, args: [:query, :filter]
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

    action :apply, :struct do
      constraints instance_of: Ash.Query
      argument :query, :term, allow_nil?: false
      argument :filter, :struct, allow_nil?: false
      run Apply
    end
  end

  preparations do
    prepare build(load: :params)
    prepare build(load: :count)
    prepare build(load: :active?)
  end

  changes do
    change load(:params)
    change load(:count)
    change load(:active?)
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

  calculations do
    calculate :params, :map do
      calculation fn filters, _ctx ->
        attrs = __MODULE__ |> Info.attributes() |> Enum.map(& &1.name)

        for filter <- filters do
          filter
          |> Map.from_struct()
          |> Map.take(attrs)
          |> Enum.reject(fn {_, v} -> v == nil end)
          |> Map.new()
        end
      end
    end

    calculate :count, :integer do
      load :params

      calculation fn filters, _ctx ->
        blank = changeset_to_new()

        for filter <- filters do
          Enum.count(filter.params, fn {k, v} -> blank.attributes[k] != v end)
        end
      end
    end

    calculate :active?, :boolean do
      calculation expr(count > 0)
    end
  end
end

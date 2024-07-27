defmodule AshDemo.Blog.Category.Filter do
  @moduledoc false

  use AshDemo.Search.Filter,
    apply: AshDemo.Blog.Category.Filter.Apply

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

    defp apply_filter({_, nil}, query, _ctx), do: query

    defp apply_filter({:search, string}, query, _ctx) do
      Ash.Query.filter(query, matching?(search: ^string))
    end

    defp apply_filter(_filter, query, _ctx), do: query
  end

  code_interface do
    domain AshDemo.Blog
    define :new, action: :create
    define :update
  end

  actions do
    defaults [:read, :create, :update]
    default_accept :*
  end

  attributes do
    attribute :search, :string, allow_nil?: true, public?: true
  end
end

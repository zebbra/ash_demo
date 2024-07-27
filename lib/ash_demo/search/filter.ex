defmodule AshDemo.Search.Filter do
  @moduledoc false
  defmacro __using__(opts) do
    {apply, opts} = Keyword.pop!(opts, :apply)

    opts =
      Keyword.merge(opts,
        data_layer: :embedded,
        embed_nil_values?: false
      )

    quote location: :keep do
      use Ash.Resource, unquote(opts)

      require Ash.Query

      code_interface do
        define :apply, args: [:query, :filter]
      end

      actions do
        action :apply, :struct do
          constraints instance_of: Ash.Query
          argument :query, :term, allow_nil?: false
          argument :filter, :struct, allow_nil?: false
          run unquote(apply)
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
      end

      calculations do
        calculate :params, :map do
          calculation fn filters, _ctx ->
            attrs = __MODULE__ |> Ash.Resource.Info.attributes() |> Enum.map(& &1.name)

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
          calculation expr(false)
        end
      end
    end
  end
end

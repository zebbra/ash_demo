defmodule AshDemoWeb.Admin.PostLive.FilterForm do
  @moduledoc false
  use AshDemoWeb, :live_component

  alias AshDemo.Blog.Post

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [post_filter_form: 1]
    end
  end

  attr :id, :string, default: "post-filter"
  attr :filter, AshDemo.Blog.Post.Filter, required: true

  def post_filter_form(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@id} filter={@filter} />
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    %{filter: filter} = assigns

    categories = Enum.map(filter.categories, &{&1.name, &1.id})

    socket
    |> assign(assigns)
    |> assign(:categories, categories)
    |> assign(:form, build_form(filter))
    |> ok()
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :form, build_form(assigns.filter))

    ~H"""
    <div>
      <.simple_form for={@form} phx-target={@myself} phx-change="updated" phx-submit="updated">
        <div class="flex items-center gap-2 border-y border-base-300 px-2 py-1 h-14">
          <.icon name="tabler-search" />

          <input
            type="text"
            placeholder="Search"
            class="grow focus:outline-0 focus:ring-0"
            value={@form[:search].value}
            name={@form[:search].name}
          />

          <.filter_dropdown filter={@filter}>
            <%!-- <.input type="checkbox" label="With Comments" field={@form[:with_comments]} /> --%>

            <.input
              type="select"
              label="Category"
              prompt="All"
              field={@form[:category_id]}
              options={@categories}
            />

            <div class="form-control">
              <.label>Status</.label>
              <div class="join grid grid-cols-3">
                <.input
                  field={@form[:status]}
                  class="join-item btn"
                  type="radio"
                  label="All"
                  value={:all}
                />
                <.input
                  field={@form[:status]}
                  class="join-item btn"
                  type="radio"
                  label="Draft"
                  value={:draft}
                />
                <.input
                  field={@form[:status]}
                  class="join-item btn"
                  type="radio"
                  label="Published"
                  value={:published}
                />
              </div>
            </div>
          </.filter_dropdown>
        </div>
      </.simple_form>
    </div>
    """
  end

  attr :filter, Post.Filter, required: true
  slot :inner_block, required: true

  defp filter_dropdown(assigns) do
    ~H"""
    <div class="dropdown dropdown-end">
      <div class="indicator">
        <span
          :if={@filter.active?}
          class="indicator-item indicator-top indicator-start bg-primary text-primary-content rounded-full text-xs p-1 h-5 w-5 flex items-center justify-center"
        >
          <%= @filter.count %>
        </span>
        <div tabindex="0" role="button" class="btn btn-circle btn-sm">
          <.icon name="tabler-filter" />
        </div>
      </div>

      <div tabindex="0" class="dropdown-content card card-compact z-[100] p-2 shadow bg-base-100 w-96">
        <div class="card-body">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  defp build_form(filter) do
    filter
    |> AshPhoenix.Form.for_update(:update,
      domain: AshDemo.Blog,
      as: "filter",
      forms: [auto?: true]
    )
    |> to_form()
  end

  @impl true
  def handle_event("updated", %{"filter" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, filter} ->
        notify_parent({:updated, filter})
        noreply(socket)

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

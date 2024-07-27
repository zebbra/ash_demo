defmodule AshDemoWeb.Admin.CategoryLive.Index do
  @moduledoc false

  use AshDemoWeb, :live_view
  use AshDemoWeb.Admin.CategoryLive.FilterForm

  alias AshDemo.Blog.Category
  alias AshDemoWeb.Admin.CategoryLive.FilterForm
  alias AshDemoWeb.Admin.CategoryLive.FormComponent

  @load [:posts_count]

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Categories
      <:subtitle>Manage categories for posts</:subtitle>

      <:actions>
        <.link patch={~p"/admin/categories/new"}>
          <.button>New Category</.button>
        </.link>
      </:actions>
    </.header>

    <.category_filter_form filter={@filter} />

    <.table id="categories" rows={@streams.categories}>
      <:col :let={{_id, category}} label="Name"><%= category.name %></:col>

      <:col :let={{_id, category}} label="Posts"><%= category.posts_count %></:col>

      <:action :let={{id, category}}>
        <.link patch={~p"/admin/categories/#{category}/edit"} class="btn btn-sm btn-ghost btn-circle">
          <.icon name="tabler-edit" />
        </.link>

        <.link
          phx-click={JS.push("category:delete", value: %{id: category.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
          class="btn btn-sm btn-ghost btn-circle"
        >
          <.icon name="tabler-trash" />
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="category-modal"
      show
      on_cancel={JS.patch(~p"/admin/categories")}
    >
      <.live_component
        module={FormComponent}
        id={(@category && @category.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        category={@category}
        patch={~p"/admin/categories"}
      />
    </.modal>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> assign(:params, params)
    |> apply_filter(params)
    |> apply_action(socket.assigns.live_action, params)
    |> noreply()
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    category = get_category!(socket, id)

    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, category)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
  end

  defp apply_filter(socket, params) do
    filter = params |> Map.get("filter", %{}) |> Category.Filter.new!()
    categories = get_categories!(socket, filter)

    socket
    |> assign(:filter, filter)
    |> stream(:categories, categories, reset: true)
  end

  @impl true
  def handle_info({FormComponent, {:saved, category}}, socket) do
    socket
    |> update_category!(category)
    |> noreply()
  end

  @impl true
  def handle_info({FilterForm, {:updated, filter}}, socket) do
    params = Map.put(socket.assigns.params, "filter", filter.params)

    socket
    |> push_patch(to: ~p"/admin/categories?#{params}")
    |> noreply()
  end

  @impl true
  def handle_event("category:delete", %{"id" => id}, socket) do
    socket
    |> delete_category!(id)
    |> noreply()
  end

  defp update_category!(socket, category) do
    category = Ash.load!(category, @load, lazy?: true)
    stream_insert(socket, :categories, category)
  end

  defp delete_category!(socket, id) do
    category =
      socket
      |> get_category!(id)
      |> Ash.destroy!(actor: socket.assigns.current_user)

    stream_delete(socket, :categories, category)
  end

  defp get_categories!(socket, filter) do
    Category
    |> Category.Filter.apply!(filter)
    |> Ash.read!(load: @load, actor: socket.assigns.current_user)
  end

  defp get_category!(socket, id) do
    Ash.get!(Category, id, load: @load, actor: socket.assigns.current_user)
  end
end

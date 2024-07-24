defmodule AshDemoWeb.Admin.PostLive.PostForm do
  @moduledoc false

  use AshDemoWeb, :live_component

  alias AshDemo.Blog.Category
  alias AshDemo.Blog.Post
  alias AshPhoenix.Form

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input type="text" label="Title" field={@form[:title]} />

        <.input type="textarea" label="Once opon a time ..." field={@form[:body]} rows="5" />

        <.input type="datetime-local" label="Published at" field={@form[:published_at]} />

        <.input
          type="select"
          label="Category"
          prompt="No Category"
          field={@form[:category_id]}
          options={@categories}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_categories!()
    |> assign_form()
    |> ok()
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    form = Form.validate(socket.assigns.form, post_params)

    socket
    |> assign(:form, form)
    |> noreply()
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    case Form.submit(socket.assigns.form, params: post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        socket
        |> put_flash(:info, "Post #{socket.assigns.form.source.type}d successfully")
        |> push_patch(to: socket.assigns.patch)
        |> noreply()

      {:error, form} ->
        socket
        |> assign(form: form)
        |> noreply()
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{post: post}} = socket) do
    {action, post} =
      if post,
        do: {:update, post},
        else: {:create, Post}

    form =
      Form.for_action(post, action,
        as: "post",
        actor: socket.assigns.current_user
      )

    assign(socket, :form, to_form(form))
  end

  defp assign_categories!(socket) do
    categories =
      [actor: socket.assigns.current_user]
      |> Category.list!()
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, categories: categories)
  end
end

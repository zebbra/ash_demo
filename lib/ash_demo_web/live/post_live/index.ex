defmodule AshDemoWeb.PostLive.Index do
  @moduledoc false
  use AshDemoWeb, :live_view

  alias AshDemo.Blog.Post

  @load [:comments_count]

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Posts
      <:actions>
        <.link patch={~p"/posts/new"}>
          <.button>New Post</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="posts"
      rows={@streams.posts}
      row_click={fn {_id, post} -> JS.navigate(~p"/posts/#{post}") end}
    >
      <:col :let={{_id, post}} label="Title"><%= post.title %></:col>
      <:col :let={{_id, post}} label="Posted at"><%= format_datetime(post.inserted_at) %></:col>
      <:col :let={{_id, post}} label="Comments"><%= post.comments_count %></:col>

      <:action :let={{_id, post}}>
        <div class="sr-only">
          <.link navigate={~p"/posts/#{post}"}>Show</.link>
        </div>

        <.link patch={~p"/posts/#{post}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, post}}>
        <.link
          phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="post-modal" show on_cancel={JS.patch(~p"/posts")}>
      <.live_component
        module={AshDemoWeb.PostLive.FormComponent}
        id={(@post && @post.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        post={@post}
        patch={~p"/posts"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :current_user, "John Doe")

    {:ok,
     socket
     |> stream(:posts, read_posts(socket))
     |> assign_new(:current_user, fn -> nil end)}
  end

  defp read_posts(socket) do
    Ash.read!(Post, load: @load, actor: socket.assigns.current_user)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Ash.get!(Post, id, load: @load, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({AshDemoWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    post = Ash.load!(post, @load, lazy?: true)
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Ash.get!(Post, id, actor: socket.assigns.current_user)
    Ash.destroy!(post, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :posts, post)}
  end
end

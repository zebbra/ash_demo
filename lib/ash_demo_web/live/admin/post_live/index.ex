defmodule AshDemoWeb.Admin.PostLive.Index do
  @moduledoc false

  use AshDemoWeb, :live_view
  use AshDemoWeb.Admin.PostLive.FilterForm

  alias AshDemo.Blog.Post
  alias AshDemoWeb.Admin.PostLive.FilterForm
  alias AshDemoWeb.Admin.PostLive.PostForm

  @load [:comments_count, :published?, :category_name]

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Posts
      <:subtitle>Manage your posts</:subtitle>

      <:actions>
        <.link patch={~p"/admin/posts/new"}>
          <.button>New Post</.button>
        </.link>
      </:actions>
    </.header>

    <.post_filter_form filter={@filter} />

    <.posts_table posts={@streams.posts} />

    <.modal
      :if={@live_action in [:new, :edit]}
      id="post-modal"
      show
      on_cancel={JS.patch(~p"/admin/posts")}
    >
      <.live_component
        module={PostForm}
        id={(@post && @post.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        post={@post}
        patch={~p"/admin/posts"}
      />
    </.modal>
    """
  end

  attr :posts, :list, required: true

  def posts_table(assigns) do
    ~H"""
    <.table id="posts" rows={@posts}>
      <:col :let={{_id, post}} label="Title"><%= post.title %></:col>

      <:col :let={{_id, post}} label="Published at">
        <.time :if={post.published?} datetime={post.published_at} format={:short} />
      </:col>

      <:col :let={{_id, post}} label="Comments"><%= post.comments_count %></:col>

      <:col :let={{_id, post}} label="Category"><%= post.category_name %></:col>

      <:action :let={{id, post}}>
        <div
          class="btn btn-sm btn-ghost btn-circle"
          phx-click="post:toggle-publish"
          phx-value-id={post.id}
        >
          <.icon :if={post.published?} name="tabler-eye" />
          <.icon :if={!post.published?} name="tabler-eye-off" />
        </div>

        <.link patch={~p"/admin/posts/#{post}/edit"} class="btn btn-sm btn-ghost btn-circle">
          <.icon name="tabler-edit" />
        </.link>

        <.link
          phx-click={JS.push("post:delete", value: %{id: post.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
          class="btn btn-sm btn-ghost btn-circle"
        >
          <.icon name="tabler-trash" />
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defp read_posts(socket, filter) do
    Post
    |> Post.Filter.apply!(filter)
    |> Ash.read!(load: @load, actor: socket.assigns.current_user)
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

  defp apply_filter(socket, params) do
    filter = params |> Map.get("filter", %{}) |> Post.Filter.new!()
    posts = read_posts(socket, filter)

    socket
    |> assign(:filter, filter)
    |> stream(:posts, posts, reset: true)
  end

  @impl true
  def handle_info({PostForm, {:saved, post}}, socket) do
    post = Ash.load!(post, @load, lazy?: true)
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_info({FilterForm, {:updated, filter}}, socket) do
    params = Map.put(socket.assigns.params, "filter", filter.params)

    socket
    |> push_patch(to: ~p"/admin/posts?#{params}")
    |> noreply()
  end

  @impl true
  def handle_event("post:delete", %{"id" => id}, socket) do
    post = Ash.get!(Post, id, actor: socket.assigns.current_user)
    Ash.destroy!(post, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  def handle_event("post:toggle-publish", %{"id" => id}, socket) do
    post = Post.get_by_id!(id, load: @load, actor: socket.assigns.current_user)

    post =
      if post.published?,
        do: Post.unpublish!(post, load: @load),
        else: Post.publish!(post, load: @load)

    socket |> stream_insert(:posts, post) |> noreply()
  end
end

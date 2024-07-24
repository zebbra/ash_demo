defmodule AshDemoWeb.PostLive.Index do
  @moduledoc false

  use AshDemoWeb, :live_view

  alias AshDemo.Blog.Post

  @load []

  @impl true
  def render(assigns) do
    ~H"""
    """
  end

  attr :posts, :list, required: true

  def posts_grid(assigns) do
    ~H"""
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
end

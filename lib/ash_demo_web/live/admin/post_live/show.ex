defmodule AshDemoWeb.Admin.PostLive.Show do
  @moduledoc false

  use AshDemoWeb, :live_view

  alias AshDemo.Blog.Comment
  alias AshDemo.Blog.Post

  @load [:comments_count, :comments]

  @impl true
  def render(assigns) do
    ~H"""
    <article class="space-y-4">
      <.post_header post={@post} />

      <div class="prose">
        <%= format_markdown(@post.body) %>
      </div>
    </article>

    <h2 class="text-xl mb-4">
      <%= @post.comments_count %> Comments
    </h2>

    <.comments comments={@post.comments} />

    <div>
      <h3>Post Comment</h3>
      <.live_component
        module={AshDemoWeb.Admin.PostLive.CommentForm}
        id={@post.id}
        action={@live_action}
        current_user={@current_user}
        post={@post}
        patch={~p"/admin/posts/#{@post}"}
      />
    </div>

    <.back navigate={~p"/admin/posts"}>Back to posts</.back>

    <.modal
      :if={@live_action == :edit}
      id="post-modal"
      show
      on_cancel={JS.patch(~p"/admin/posts/#{@post}")}
    >
      <.live_component
        module={AshDemoWeb.Admin.PostLive.PostForm}
        id={@post.id}
        title="Edit Post"
        action={@live_action}
        current_user={@current_user}
        post={@post}
        patch={~p"/admin/posts/#{@post}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :post,
       Ash.get!(AshDemo.Blog.Post, id, load: @load, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"

  attr :post, Post

  defp post_header(assigns) do
    ~H"""
    <header class="flex items-start justify-between gap-x-6">
      <div class="space-y-4">
        <h1 class="text-4xl font-bold"><%= @post.title %></h1>

        <ul class="text-sm flex space-x-4 text-base-content/70 not-prose items-center not-prose">
          <li>
            John Doe
          </li>

          <li>
            <.time datetime={@post.inserted_at} format={:short} tooltip={:medium} />
          </li>

          <li>
            <.link
              patch={~p"/admin/posts/#{@post}/show/edit"}
              phx-click={JS.push_focus()}
              class="link link-hover link-neutral"
            >
              Edit
            </.link>
          </li>
        </ul>
      </div>
    </header>
    """
  end

  defp comments(assigns) do
    ~H"""
    <ol class="space-y-4">
      <li :for={comment <- @comments}>
        <.comment comment={comment} />
      </li>
    </ol>
    """
  end

  attr :comment, Comment

  defp comment(assigns) do
    ~H"""
    <div class="prose">
      <%= format_markdown(@comment.text) %>
    </div>
    """
  end
end

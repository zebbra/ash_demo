defmodule AshDemoWeb.PostLive.FilterForm do
  @moduledoc false
  use AshDemoWeb, :html

  alias AshDemo.Blog.Post

  def render(assigns) do
    ~H"""
    <form phx-submit="filter" phx-change="filter"></form>
    """
  end

  def form do
    AshPhoenix.FilterForm.new(Post)
  end
end

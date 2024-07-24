defmodule AshDemo.Blog do
  @moduledoc false
  use Ash.Domain

  resources do
    resource AshDemo.Blog.Post
    resource AshDemo.Blog.Comment
    resource AshDemo.Blog.Category
  end
end

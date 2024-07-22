defmodule AshDemo.Blog do
  @moduledoc false
  use Ash.Domain

  resources do
    resource AshDemo.Blog.Post
    resource AshDemo.Blog.Comment
  end
end

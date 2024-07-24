defmodule AshDemo.Blog.Post.FilterTest do
  use AshDemo.DataCase, async: true

  import Ash.Generator

  alias AshDemo.Blog.Category
  alias AshDemo.Blog.Post
  alias AshDemo.Blog.Post.Filter

  setup do
    categories = seed_many!(Category, 2, %{name: sequence(:category_name, &"Category #{&1}")})
    [categories: categories]
  end

  setup do
    posts = seed_many!(Post, 5, %{title: sequence(:post_title, &"Post #{&1}")})
    [posts: posts]
  end

  test "defaults" do
    assert {:ok, filter} = Filter.new()
    assert filter.status == :all
    assert length(filter.categories) == 2
  end

  test "by_category" do
    category1 = seed!(Category, %{name: "My Category"})
    category2 = seed!(Category, %{name: "Another Category"})

    seed_many!(Post, 5, %{category_id: category1.id})
    seed_many!(Post, 5, %{category_id: category2.id})

    # Create
    assert {:ok, filter} = Filter.new(%{category_id: category1.id})
    assert filter.category.name == "My Category"

    assert {:ok, posts} = Post |> Filter.apply!(filter) |> Ash.read()
    assert Enum.all?(posts, &(&1.category_id == category1.id))

    # Update
    assert {:ok, filter} = Filter.update(filter, %{category_id: category2.id})
    assert filter.category.name == "Another Category"

    assert {:ok, posts} = Post |> Filter.apply!(filter) |> Ash.read()
    assert Enum.all?(posts, &(&1.category_id == category2.id))

    # Clear
    assert {:ok, filter} = Filter.update(filter, %{category_id: nil})
    assert filter.category == nil

    assert {:ok, filter} = Filter.update(filter, %{category_id: ""})
    assert filter.category == nil

    # Invalid
    assert {:error, %Ash.Error.Invalid{}} = Filter.update(filter, %{category_id: "invalid"})
  end

  test "params" do
    assert {:ok, filter} = Filter.new()
    assert filter.params == %{status: :all}

    assert {:ok, filter} = Filter.new(%{status: :published})
    assert filter.params == %{status: :published}
  end

  test "count" do
    assert {:ok, filter} = Filter.new()
    assert filter.count == 0

    assert {:ok, filter} = Filter.new(%{status: :published})
    assert filter.count == 1
  end
end

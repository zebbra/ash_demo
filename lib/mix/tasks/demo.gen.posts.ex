defmodule Mix.Tasks.Demo.Gen.Posts do
  @shortdoc "Echoes arguments"

  @moduledoc "Printed when the user requests `mix help echo`"

  use Mix.Task

  import Ash.Generator

  alias AshDemo.Blog.Category
  alias AshDemo.Blog.Post

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    seed_posts(10)
  end

  defp post_generator do
    title = &Faker.Lorem.sentence/0
    body = fn -> Enum.join(Faker.Lorem.paragraphs(), "\n\n") end

    categories = Category.list!()

    %{
      title: StreamData.repeatedly(title),
      body: StreamData.repeatedly(body),
      category: StreamData.member_of(categories)
    }
  end

  defp seed_posts(n) do
    seed_many!(Post, n, post_generator())
  end
end

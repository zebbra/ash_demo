defmodule Mix.Tasks.Demo.Gen.Posts do
  @shortdoc "Echoes arguments"

  @moduledoc "Printed when the user requests `mix help echo`"
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    Mix.shell().info(Enum.join(args, " "))
  end
end

defmodule AshDemoWeb.Helpers do
  @moduledoc false
  def format_datetime(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%y-%m-%d %I:%M:%S %p")
  end
end

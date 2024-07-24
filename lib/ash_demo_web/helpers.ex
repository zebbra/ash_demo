defmodule AshDemoWeb.Helpers do
  @moduledoc """
  Formatting helpers.
  """

  import AshDemo.Guards

  alias AshDemoWeb.Cldr

  @placeholder Phoenix.HTML.raw("&mdash;")

  @spec format_number(number, Keyword.t()) :: String.t()
  def format_number(number, opts \\ [])
  def format_number(number, _opts) when is_blank(number), do: @placeholder
  def format_number(number, opts), do: Cldr.Number.to_string!(number, opts)

  def format_date(date, opts \\ [])
  def format_date(date, _opts) when is_blank(date), do: @placeholder
  def format_date(date, opts), do: Cldr.Date.to_string!(date, opts)

  def format_datetime(datetime, opts \\ [])
  def format_datetime(datetime, _opts) when is_blank(datetime), do: @placeholder

  def format_datetime(datetime, opts) do
    datetime
    |> Timex.local()
    |> Cldr.DateTime.to_string!(opts)
  end

  def format_percent(number, opts \\ [])
  def format_percent(number, _opts) when is_blank(number), do: @placeholder

  def format_percent(number, opts) do
    {precision, opts} = Keyword.pop(opts, :precision, 0)

    number = Float.round(number * 100.0, precision)
    opts = Keyword.merge([unit: "percent", style: :short], opts)
    Cldr.Unit.to_string!(number, opts)
  end

  def format_markdown(text) do
    text
    |> Earmark.as_html!()
    |> Phoenix.HTML.raw()
  end
end

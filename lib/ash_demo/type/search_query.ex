constraints = [
  prefix?: [
    type: :boolean,
    doc: "Match the prefix of the terms",
    default: true
  ],
  any_word?: [
    type: :boolean,
    doc: "Use OR instead of AND for the terms",
    default: false
  ]
]

defmodule AshDemo.Type.SearchQuery do
  @moduledoc """
  A type for full-text search queries.

  ### Constraints

  #{Spark.Options.docs(constraints)}
  """

  use Ash.Type

  @constraints constraints
  @disallowed_characters ~r/['?\\:‘’ʻʼ]/u

  @impl Ash.Type
  def constraints, do: @constraints

  @impl Ash.Type
  def storage_type(_), do: :tsquery

  @impl Ash.Type
  def cast_input(nil, _), do: {:ok, nil}

  def cast_input(value, constraints) do
    with {:ok, constraints} <- Spark.Options.validate(constraints, constraints()),
         {:ok, constraints} <- init(constraints),
         {:ok, string} <- Ecto.Type.cast(:string, value) do
      {:ok, to_tsquery(string, constraints)}
    end
  end

  @impl Ash.Type
  def cast_stored(nil, _), do: {:ok, nil}

  def cast_stored(value, _) do
    Ecto.Type.load(:string, value)
  end

  @impl Ash.Type
  def dump_to_native(nil, _), do: {:ok, nil}

  def dump_to_native(value, _) do
    Ecto.Type.dump(:string, value)
  end

  defp to_tsquery(query, constraints) do
    any_word? = Keyword.fetch!(constraints, :any_word?)
    op = if any_word?, do: " | ", else: " & "

    query
    |> String.replace(@disallowed_characters, "")
    |> String.split(" ", trim: true)
    |> Enum.flat_map(&to_term(&1, constraints))
    |> Enum.join(op)
  end

  defp to_term(word, constraints) do
    prefix? = Keyword.fetch!(constraints, :prefix?)
    _to_term(word, prefix?, false)
  end

  defp _to_term("", _, _), do: []

  defp _to_term("-" <> rest, prefix?, negate?) do
    _to_term(rest, prefix?, !negate?)
  end

  defp _to_term(term, prefix?, negate?) do
    term = "'" <> term <> "'"
    term = if negate?, do: "!" <> term, else: term
    term = if prefix?, do: term <> ":*", else: term
    [term]
  end
end

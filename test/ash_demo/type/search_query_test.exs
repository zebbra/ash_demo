defmodule AshDemo.Type.SearchQueryTest do
  use ExUnit.Case, async: true

  alias AshDemo.Type.SearchQuery

  describe "cast_input/1" do
    test "it returns the expected value" do
      test_cases = %{
        {"foo -bar", []} => "'foo':* & !'bar':*",
        {"foo -bar", prefix?: false} => "'foo' & !'bar'",
        {"foo -bar", any_word?: true} => "'foo':* | !'bar':*",
        {"foo -bar", any_word?: true, prefix?: false} => "'foo' | !'bar'",
        {"-- 'foo' ?' \:---bar", []} => "'foo':* & !'bar':*"
      }

      for {{input, constraints}, expected} <- test_cases do
        assert Ash.Type.cast_input(SearchQuery, input, constraints) == {:ok, expected}
      end
    end
  end
end

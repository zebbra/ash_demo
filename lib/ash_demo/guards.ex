defmodule AshDemo.Guards do
  @moduledoc """
  Custom guards for the AshDemo application.
  """

  @spec is_blank(Macro.t()) :: Macro.t()
  defguard is_blank(val) when val in [nil, ""] or is_struct(val, Ash.NotLoaded)
end

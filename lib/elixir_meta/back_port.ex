defmodule ElixirMeta.BackPort do
  @moduledoc false
  
  defmacro __using__(_options) do
    unless macro_exported?(Kernel, :is_struct, 2) do
      quote do
        import ElixirMeta.BackPort, only: [is_struct: 2]
      end
    end
  end

  @doc guard: true
  defmacro is_struct(term, _module) do
    quote do
      is_struct(unquote(term))
    end
  end
end
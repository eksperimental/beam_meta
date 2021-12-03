defmodule BackPort do
  @moduledoc false
  defmacro __using__(_options) do
    [
      import_macro_if_undefined(Kernel, :is_struct, 1),
      import_macro_if_undefined(Kernel, :is_struct, 2)
    ]
  end

  @doc guard: true
  defmacro is_struct(term) do
    quote do
      is_map(unquote(term))
    end
  end

  @doc guard: true
  defmacro is_struct(term, _module) do
    quote do
      BackPort.is_struct(unquote(term))
    end
  end

  # Helpers

  defp import_macro_if_undefined(module, name, arity, implementation_module \\ BackPort)
       when is_atom(module) and is_atom(name) and is_integer(arity) do
    unless macro_exported?(module, name, arity) do
      quote do
        import unquote(implementation_module), only: [{unquote(name), unquote(arity)}]
      end
    end
  end

  defp import_function_if_undefined(module, name, arity, implementation_module \\ BackPort)
       when is_atom(module) and is_atom(name) and is_integer(arity) do
    unless function_exported?(module, name, arity) do
      quote do
        import unquote(implementation_module), only: [{unquote(name), unquote(arity)}]
      end
    end
  end
end

#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Macros do
  defmacro eq_for(for_struct, field) do
    quote do
      alias FunPark.Eq

      defimpl FunPark.Eq, for: unquote(for_struct) do
        def eq?(
              %unquote(for_struct){unquote(field) => v1},
              %unquote(for_struct){unquote(field) => v2}
            ),
            do: Eq.eq?(v1, v2)

        def not_eq?(
              %unquote(for_struct){unquote(field) => v1},
              %unquote(for_struct){unquote(field) => v2}
            ),
            do: Eq.not_eq?(v1, v2)
      end
    end
  end


  defmacro ord_for(for_struct, field) do
    quote do
      alias FunPark.Ord

      defimpl FunPark.Ord, for: unquote(for_struct) do
        def lt?(
              %unquote(for_struct){unquote(field) => v1},
              %unquote(for_struct){unquote(field) => v2}
            ),
            do: Ord.lt?(v1, v2)

        def le?(
              %unquote(for_struct){unquote(field) => v1},
              %unquote(for_struct){unquote(field) => v2}
            ),
            do: Ord.le?(v1, v2)

        def gt?(
              %unquote(for_struct){unquote(field) => v1},
              %unquote(for_struct){unquote(field) => v2}
            ),
            do: Ord.gt?(v1, v2)

        def ge?(
              %unquote(for_struct){unquote(field) => v1},
              %unquote(for_struct){unquote(field) => v2}
            ),
            do: Ord.ge?(v1, v2)
      end
    end
  end

end

#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monoid.Eq.All do
  defstruct eq?: &FunPark.Monoid.Eq.All.default_eq?/2,
            not_eq?: &FunPark.Monoid.Eq.All.default_not_eq?/2

  def default_eq?(_, _), do: true

  def default_not_eq?(_, _), do: false
end


defimpl FunPark.Monoid, for: FunPark.Monoid.Eq.All do
  alias FunPark.Eq.Utils
  alias FunPark.Monoid.Eq.All

  def empty(_), do: %All{}

  def append(%All{} = eq1, %All{} = eq2) do
    %All{
      eq?: fn a, b -> eq1.eq?.(a, b) && eq2.eq?.(a, b) end,
      not_eq?: fn a, b -> eq1.not_eq?.(a, b) || eq2.not_eq?.(a, b) end
    }
  end

  def wrap(%All{}, eq) do
    eq = Utils.to_eq_map(eq)

    %All{
      eq?: eq.eq?,
      not_eq?: eq.not_eq?
    }
  end

  def unwrap(%All{eq?: eq?, not_eq?: not_eq?}) do
    %{eq?: eq?, not_eq?: not_eq?}
  end
end


#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monoid.Utils do
  import FunPark.Monoid, only: [empty: 1, append: 2, wrap: 2, unwrap: 1]
  import FunPark.Foldable, only: [fold_l: 3]

  def m_append(monoid, a, b) when is_struct(monoid) do
    append(wrap(monoid, a), wrap(monoid, b)) |> unwrap()
  end


  def m_concat(monoid, values) when is_struct(monoid) and is_list(values) do
    fold_l(values, empty(monoid), fn value, acc ->
      append(acc, wrap(monoid, value))
    end)
    |> unwrap()
  end

end

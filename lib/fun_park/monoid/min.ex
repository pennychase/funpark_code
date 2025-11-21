#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monoid.Min do
  defstruct value: nil, id: nil, ord: FunPark.Ord
end


defimpl FunPark.Monoid, for: FunPark.Monoid.Min do
  alias FunPark.Monoid.Min
  alias FunPark.Ord.Utils

  def empty(%Min{id: id, ord: ord}), do: %Min{value: id, id: id, ord: ord}

  def append(%Min{value: a, ord: ord} = min1, %Min{value: b}) do
    %Min{min1 | value: Utils.min(a, b, ord)}
  end

  def wrap(%Min{ord: ord}, value) do
    %Min{value: value, ord: Utils.to_ord_map(ord)}
  end

  def unwrap(%Min{value: value}), do: value
end


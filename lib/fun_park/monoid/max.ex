#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monoid.Max do
  defstruct value: nil, ord: FunPark.Ord
end


defimpl FunPark.Monoid, for: FunPark.Monoid.Max do
  alias FunPark.Monoid.Max
  alias FunPark.Ord.Utils

  def empty(%Max{value: min_value, ord: ord}) do
    %Max{value: min_value, ord: ord}
  end


  def append(%Max{value: a, ord: ord}, %Max{value: b}) do
    %Max{value: Utils.max(a, b, ord), ord: ord}
  end


  def wrap(%Max{ord: ord}, value) do
    %Max{value: value, ord: Utils.to_ord_map(ord)}
  end

  def unwrap(%Max{value: value}), do: value
end


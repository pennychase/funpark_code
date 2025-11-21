#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monoid.Predicate.Any do
  defstruct value: &FunPark.Monoid.Predicate.Any.default_pred?/1

  def default_pred?(_), do: false
end


defimpl FunPark.Monoid, for: FunPark.Monoid.Predicate.Any do
  alias FunPark.Monoid.Predicate.Any

  def empty(_), do: %Any{}

  def append(%Any{} = p1, %Any{} = p2) do
    %Any{
      value: fn value -> p1.value.(value) or p2.value.(value) end
    }
  end

  def wrap(%Any{}, value) when is_function(value, 1) do
    %Any{value: value}
  end

  def unwrap(%Any{value: value}), do: value
end


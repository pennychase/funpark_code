#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monoid.Predicate.All do
  defstruct value: &FunPark.Monoid.Predicate.All.default_pred?/1

  def default_pred?(_), do: true
end


defimpl FunPark.Monoid, for: FunPark.Monoid.Predicate.All do
  alias FunPark.Monoid.Predicate.All

  def empty(_), do: %All{}

  def append(%All{} = p1, %All{} = p2) do
    %All{
      value: fn value -> p1.value.(value) and p2.value.(value) end
    }
  end

  def wrap(%All{}, value) when is_function(value, 1) do
    %All{value: value}
  end

  def unwrap(%All{value: value}), do: value
end


#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monoid.Sum do
  defstruct value: 0
end


defimpl FunPark.Monoid, for: FunPark.Monoid.Sum do
  alias FunPark.Monoid.Sum

  def empty(_), do: %Sum{}

  def append(%Sum{value: a}, %Sum{value: b}) do
    %Sum{value: a + b}
  end

  def wrap(%Sum{}, value) when is_number(value), do: %Sum{value: value}

  def unwrap(%Sum{value: value}) when is_number(value), do: value
end


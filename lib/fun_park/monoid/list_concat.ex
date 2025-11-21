#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monoid.ListConcat do
  defstruct value: []
end

defimpl FunPark.Monoid, for: FunPark.Monoid.ListConcat do
  alias FunPark.Monoid.ListConcat

  def empty(_), do: %ListConcat{}

  def append(%ListConcat{value: a}, %ListConcat{value: b}) do
    %ListConcat{value: a ++ b}
  end

  def wrap(%ListConcat{}, value) when is_list(value), do: %ListConcat{value: value}

  def unwrap(%ListConcat{value: value}), do: value
end

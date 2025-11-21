#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Math do
  import FunPark.Monoid.Utils, only: [m_append: 3, m_concat: 2]
  alias FunPark.Monoid
  alias FunPark.Monad.Maybe

  def positive?(value) when is_number(value) do
    value > 0
  end

  def negative?(value) when is_number(value) do
    value < 0
  end

  def sum(a, b) do
    m_append(%Monoid.Sum{}, a, b)
  end

  def sum(list) when is_list(list) do
    m_concat(%Monoid.Sum{}, list)
  end


  def max(a, b) do
    m_append(%Monoid.Max{value: Float.min_finite()}, a, b)
  end

  def max(list) when is_list(list) do
    m_concat(%Monoid.Max{value: Float.min_finite()}, list)
  end


  def min(a, b) do
    m_append(%Monoid.Min{id: Float.max_finite()}, a, b)
  end

  def min(list) when is_list(list) do
    m_concat(%Monoid.Min{id: Float.max_finite()}, list)
  end


  def divide(_numerator, 0), do: Maybe.nothing()

  def divide(numerator, denominator),
    do: Maybe.just(numerator / denominator)


  def maybe_divide(_numerator, 0), do: Maybe.nothing()

  def maybe_divide(numerator, denominator),
    do: Maybe.just(numerator / denominator)

end

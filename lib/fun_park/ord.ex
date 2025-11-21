#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defprotocol FunPark.Ord do
  @fallback_to_any true

  def lt?(a, b)
  def le?(a, b)
  def gt?(a, b)
  def ge?(a, b)
end


defimpl FunPark.Ord, for: Any do
  def lt?(a, b), do: a < b
  def le?(a, b), do: a <= b
  def gt?(a, b), do: a > b
  def ge?(a, b), do: a >= b
end


defimpl FunPark.Ord, for: DateTime do
  def lt?(a, b), do: DateTime.compare(a, b) == :lt
  def le?(a, b), do: match?(x when x in [:lt, :eq], DateTime.compare(a, b))
  def gt?(a, b), do: DateTime.compare(a, b) == :gt
  def ge?(a, b), do: match?(x when x in [:gt, :eq], DateTime.compare(a, b))
end


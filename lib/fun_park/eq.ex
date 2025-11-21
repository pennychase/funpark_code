#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defprotocol FunPark.Eq do
  @fallback_to_any true

  def eq?(a, b)

  def not_eq?(a, b)
end


defimpl FunPark.Eq, for: Any do
  def eq?(a, b), do: a == b
  def not_eq?(a, b), do: a != b
end


defimpl FunPark.Eq, for: DateTime do
  def eq?(a, b), do: DateTime.compare(a, b) == :eq
  def not_eq?(a, b), do: DateTime.compare(a, b) != :eq
end


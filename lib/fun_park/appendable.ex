#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defprotocol FunPark.Appendable do
  @fallback_to_any true

  def coerce(term)

  def append(accumulator, coerced)
end


defimpl FunPark.Appendable, for: Any do
  def coerce(value) when is_list(value), do: value
  def coerce(value), do: [value]

  def append(acc, value), do: coerce(acc) ++ coerce(value)
end


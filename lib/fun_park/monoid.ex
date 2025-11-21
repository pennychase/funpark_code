#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defprotocol FunPark.Monoid do
  def empty(monoid_struct)
  def append(monoid_struct_a, monoid_struct_b)
  def wrap(monoid_struct, value)
  def unwrap(monoid_struct)
end


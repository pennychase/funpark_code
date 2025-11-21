#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Eq.Utils do
  import FunPark.Monoid.Utils, only: [m_append: 3, m_concat: 2]

  alias FunPark.Eq
  alias FunPark.Monoid

  def contramap(f, eq \\ Eq) do
    eq = to_eq_map(eq)

    %{
      eq?: fn a, b -> eq.eq?.(f.(a), f.(b)) end,
      not_eq?: fn a, b -> eq.not_eq?.(f.(a), f.(b)) end
    }
  end


  def eq?(a, b, eq \\ Eq) do
    eq = to_eq_map(eq)
    eq.eq?.(a, b)
  end


  def not_eq?(a, b, eq \\ Eq) do
    eq = to_eq_map(eq)
    eq.not_eq?.(a, b)
  end


  def append_all(a, b) do
    m_append(%Monoid.Eq.All{}, a, b)
  end


  def concat_all(eq_list) when is_list(eq_list) do
    m_concat(%Monoid.Eq.All{}, eq_list)
  end


  def append_any(a, b) do
    m_append(%Monoid.Eq.Any{}, a, b)
  end


  def concat_any(eq_list) when is_list(eq_list) do
    m_concat(%Monoid.Eq.Any{}, eq_list)
  end


  def to_predicate(target, eq \\ Eq) do
    eq = to_eq_map(eq)

    fn elem -> eq.eq?.(elem, target) end
  end


  def to_eq_map(%{eq?: eq_fun, not_eq?: not_eq_fun} = eq_map)
      when is_function(eq_fun, 2) and is_function(not_eq_fun, 2) do
    eq_map
  end

  def to_eq_map(module) when is_atom(module) do
    %{
      eq?: &module.eq?/2,
      not_eq?: &module.not_eq?/2
    }
  end

end

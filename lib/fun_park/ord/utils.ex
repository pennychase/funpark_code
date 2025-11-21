#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Ord.Utils do
  import FunPark.Monoid.Utils, only: [m_append: 3, m_concat: 2]

  alias FunPark.Ord

  def contramap(f, ord \\ Ord) do
    ord = to_ord_map(ord)

    %{
      lt?: fn a, b -> ord.lt?.(f.(a), f.(b)) end,
      le?: fn a, b -> ord.le?.(f.(a), f.(b)) end,
      gt?: fn a, b -> ord.gt?.(f.(a), f.(b)) end,
      ge?: fn a, b -> ord.ge?.(f.(a), f.(b)) end
    }
  end


  def compare(a, b, ord \\ Ord) do
    ord = to_ord_map(ord)

    cond do
      ord.lt?.(a, b) -> :lt
      ord.gt?.(a, b) -> :gt
      true -> :eq
    end
  end


  def max(a, b, ord \\ Ord) do
    case compare(a, b, ord) do
      :lt -> b
      _ -> a
    end
  end


  def min(a, b, ord \\ Ord) do
    case compare(a, b, ord) do
      :gt -> b
      _ -> a
    end
  end


  def clamp(value, min, max, ord \\ Ord) do
    value
    |> max(min, ord)
    |> min(max, ord)
  end


  def between(value, min, max, ord \\ Ord) do
    compare(value, min, ord) != :lt && compare(value, max, ord) != :gt
  end


  def reverse(ord \\ Ord) do
    ord = to_ord_map(ord)

    %{
      lt?: ord.gt?,
      le?: ord.ge?,
      gt?: ord.lt?,
      ge?: ord.le?
    }
  end


  def comparator(ord_module) do
    fn a, b -> compare(a, b, ord_module) != :gt end
  end


  def to_eq(ord \\ Ord) do
    %{
      eq?: fn a, b -> compare(a, b, ord) == :eq end,
      not_eq?: fn a, b -> compare(a, b, ord) != :eq end
    }
  end


  def append(a, b) do
    m_append(%FunPark.Monoid.Ord{}, a, b)
  end


  def concat(ord_list) when is_list(ord_list) do
    m_concat(%FunPark.Monoid.Ord{}, ord_list)
  end


  def to_ord_map(%{lt?: lt_f, le?: le_f, gt?: gt_f, ge?: ge_f} = ord_map)
      when is_function(lt_f, 2) and
             is_function(le_f, 2) and
             is_function(gt_f, 2) and
             is_function(ge_f, 2),
      do: ord_map

  def to_ord_map(module) when is_atom(module) do
    %{
      lt?: &module.lt?/2,
      le?: &module.le?/2,
      gt?: &module.gt?/2,
      ge?: &module.ge?/2
    }
  end

end

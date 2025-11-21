#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.List do
  import FunPark.Monoid.Utils, only: [m_concat: 2]

  alias FunPark.Eq
  alias FunPark.Monoid.ListConcat
  alias FunPark.Ord

  def uniq(list, eq \\ FunPark.Eq) when is_list(list) do
    list
    |> Enum.reduce([], fn item, acc ->
      if Enum.any?(acc, &Eq.Utils.eq?(item, &1, eq)),
        do: acc,
        else: [item | acc]
    end)
    |> :lists.reverse()
  end


  def union(list1, list2, eq \\ FunPark.Eq)
      when is_list(list1) and is_list(list2) do
    (list1 ++ list2) |> uniq(eq)
  end


  def intersection(list1, list2, eq \\ FunPark.Eq)
      when is_list(list1) and is_list(list2) do
    list1
    |> Enum.filter(fn item ->
      Enum.any?(list2, &Eq.Utils.eq?(item, &1, eq))
    end)
    |> uniq(eq)
  end


  def difference(list1, list2, eq \\ FunPark.Eq)
      when is_list(list1) and is_list(list2) do
    list1
    |> Enum.reject(fn item ->
      Enum.any?(list2, &Eq.Utils.eq?(item, &1, eq))
    end)
    |> uniq(eq)
  end


  def symmetric_difference(list1, list2, eq \\ FunPark.Eq)
      when is_list(list1) and is_list(list2) do
    (difference(list1, list2, eq) ++
       difference(list2, list1, eq))
    |> uniq(eq)
  end


  def subset?(small, large, eq \\ FunPark.Eq)
      when is_list(small) and is_list(large) do
    Enum.all?(small, fn item ->
      Enum.any?(large, &Eq.Utils.eq?(item, &1, eq))
    end)
  end


  def superset?(large, small, eq \\ FunPark.Eq)
      when is_list(small) and is_list(large) do
    subset?(small, large, eq)
  end


  def sort(list, ord \\ FunPark.Ord) when is_list(list) do
    Enum.sort(list, Ord.Utils.comparator(ord))
  end


  def strict_sort(list, ord \\ FunPark.Ord) when is_list(list) do
    list
    |> uniq(Ord.Utils.to_eq(ord))
    |> sort(ord)
  end


  def concat(list) when is_list(list) do
    m_concat(%ListConcat{}, list)
  end

end

defimpl FunPark.Foldable, for: List do
  def fold_l(list, acc, func), do: :lists.foldl(func, acc, list)

  def fold_r(list, acc, func), do: :lists.foldr(func, acc, list)
end


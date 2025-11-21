#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Store do
  import FunPark.Monad
  alias FunPark.Monad.Either

  def create_table(table) when is_atom(table) do
    Either.from_try(fn ->
      :ets.new(table, [:named_table, :set, :public])
    end)
  end


  def drop_table(table) when is_atom(table) do
    Either.from_try(fn ->
      :ets.delete(table)
    end)
    |> map(fn _ -> table end)
  end


  def insert_item(table, %{id: id} = item) when is_atom(table) do
    Either.from_try(fn ->
      :ets.insert(table, {id, Map.from_struct(item)})
    end)
    |> map(fn _ -> item end)
  end


  def get_item(table, id) when is_atom(table) do
    Either.from_try(fn ->
      :ets.lookup(table, id)
    end)
    |> bind(fn
      [{_id, item}] -> Either.pure(item)
      [] -> Either.left(:not_found)
    end)
  end


  def get_all_items(table) when is_atom(table) do
    Either.from_try(fn ->
      :ets.tab2list(table)
    end)
    |> map(fn items ->
      Enum.map(items, fn {_, item} -> item end)
    end)
  end


  def delete_item(table, id) when is_atom(table) do
    Either.from_try(fn ->
      :ets.delete(table, id)
    end)
    |> map(fn _ -> id end)
  end

end

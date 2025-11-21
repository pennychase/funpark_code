#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Ride.Repo do
  import FunPark.Monad
  import FunPark.Utils, only: [curry: 1]

  alias FunPark.Monad.Either
  alias FunPark.List
  alias FunPark.Ride
  alias FunPark.Store

  @table_name :rides

  def create_table do
    Store.create_table(@table_name)
  end


  def save(%Ride{} = ride) do
    insert_ride = curry(&Store.insert_item/2)

    ride
    |> Ride.validate()
    |> bind(insert_ride.(@table_name))
  end


  def get(id) when is_integer(id) do
    Store.get_item(@table_name, id)
    |> map(fn data -> struct(Ride, data) end)
    |> Either.map_left(fn _ -> :not_found end)
  end


  def list() do
    Store.get_all_items(@table_name)
    |> map(fn items ->
      items
      |> Enum.map(fn item -> struct(Ride, item) end)
      |> List.sort()
    end)
    |> Either.get_or_else([])
  end


  def delete(%Ride{id: id}) do
    Store.delete_item(@table_name, id)
    |> Either.get_or_else(:ok)
  end

end

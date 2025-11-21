#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Maintenance.Store do
  import FunPark.Monad

  alias FunPark.Monad.Effect
  alias FunPark.Ride
  alias FunPark.Store

  def create_table(table) do
    Store.create_table(table)
  end

  def add(%Ride{} = ride, table) do
    Effect.lift_either(fn -> Store.insert_item(table, ride) end)
    |> map(&simulate_delay/1)
    |> Effect.map_left(&simulate_delay/1)
  end


  def remove(%Ride{id: id}, table) do
    Effect.lift_either(fn -> Store.delete_item(table, id) end)
    |> map(&simulate_delay/1)
    |> Effect.map_left(&simulate_delay/1)
  end


  def get(%Ride{id: id}, table) do
    Effect.lift_either(fn -> Store.get_item(table, id) end)
    |> map(&simulate_delay/1)
    |> Effect.map_left(&simulate_delay/1)
  end


  defp simulate_delay(ride) do
    Process.sleep(500)
    ride
  end
end

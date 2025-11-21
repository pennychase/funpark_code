#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Maintenance.Repo do
  import FunPark.Monad, only: [bind: 2, map: 2]

  alias FunPark.Monad.Effect
  alias FunPark.Monad.Either
  alias FunPark.Maintenance.Store
  alias FunPark.Ride

  def create_store do
    Either.sequence_a([
      Store.create_table(:schedule),
      Store.create_table(:unschedule),
      Store.create_table(:lockout),
      Store.create_table(:compliance)
    ])
  end


  def add_schedule(%Ride{} = ride) do
    ride
    |> add_ride_effect()
    |> Effect.run(%{table: :schedule})
  end


  def add_unschedule(%Ride{} = ride) do
    ride
    |> add_ride_effect()
    |> Effect.run(%{table: :unschedule})
  end

  def add_lockout(%Ride{} = ride) do
    ride
    |> add_ride_effect()
    |> Effect.run(%{table: :lockout})
  end

  def add_compliance(%Ride{} = ride) do
    ride
    |> add_ride_effect()
    |> Effect.run(%{table: :compliance})
  end


  def remove_schedule(%Ride{} = ride) do
    ride
    |> remove_ride_effect()
    |> Effect.run(%{table: :schedule})
  end

  def remove_unschedule(%Ride{} = ride) do
    ride
    |> remove_ride_effect()
    |> Effect.run(%{table: :unschedule})
  end

  def remove_lockout(%Ride{} = ride) do
    ride
    |> remove_ride_effect()
    |> Effect.run(%{table: :lockout})
  end

  def remove_compliance(%Ride{} = ride) do
    ride
    |> remove_ride_effect()
    |> Effect.run(%{table: :compliance})
  end


  def in_schedule(%Ride{} = ride), do: has_ride_effect(ride, :schedule)
  def in_unschedule(%Ride{} = ride), do: has_ride_effect(ride, :unschedule)
  def in_lockout(%Ride{} = ride), do: has_ride_effect(ride, :lockout)
  def in_compliance(%Ride{} = ride), do: has_ride_effect(ride, :compliance)


  def not_in_schedule(%Ride{} = ride) do
    assert_absent_effect(
      ride,
      &in_schedule/1,
      "#{ride.name} is in scheduled maintenance"
    )
  end

  def not_in_unschedule(%Ride{} = ride) do
    assert_absent_effect(
      ride,
      &in_unschedule/1,
      "#{ride.name} is in unscheduled maintenance"
    )
  end

  def not_in_lockout(%Ride{} = ride) do
    assert_absent_effect(
      ride,
      &in_lockout/1,
      "#{ride.name} is locked out"
    )
  end

  def not_in_compliance(%Ride{} = ride) do
    assert_absent_effect(
      ride,
      &in_compliance/1,
      "#{ride.name} is out of compliance"
    )
  end



  defp validate_ride_effect(ride) do
    Effect.lift_either(fn -> Ride.validate(ride) end)
  end


  defp add_to_store_effect(valid_ride) do
    Effect.asks(fn env -> env[:table] end)
    |> bind(fn table -> Store.add(valid_ride, table) end)
  end


  def add_ride_effect(%Ride{} = ride) do
    validate_ride_effect(ride)
    |> bind(&add_to_store_effect/1)
  end


  defp remove_from_store_effect(valid_ride) do
    Effect.asks(fn env -> env[:table] end)
    |> bind(fn table -> Store.remove(valid_ride, table) end)
  end


  def remove_ride_effect(%Ride{} = ride) do
    validate_ride_effect(ride)
    |> bind(&remove_from_store_effect/1)
    |> map(fn _ -> ride end)
  end


  def has_ride_effect(%Ride{} = ride, table) do
    Effect.asks(fn env -> env[:store] end)
    |> bind(fn store -> store.get(ride, table) end)
    |> map(fn _ -> ride end)
  end


  def assert_absent_effect(%Ride{} = ride, kleisli_fn, reason_msg) do
    ride
    |> kleisli_fn.()
    |> Effect.flip_either()
    |> bind(right_if_absent(ride))
    |> Effect.map_left(replace_ride_with_reason(reason_msg))
  end

  defp right_if_absent(ride) do
    fn
      :not_found -> Effect.right(ride)
      other -> Effect.left(other)
    end
  end

  defp replace_ride_with_reason(reason_msg) do
    fn
      %Ride{} -> reason_msg
      other -> other
    end
  end

end

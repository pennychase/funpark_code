#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Maintenance do
  import FunPark.Monad, only: [bind: 2, map: 2]
  alias FunPark.Errors.ValidationError
  alias FunPark.Monad.Effect
  alias FunPark.Monad.Either
  alias FunPark.Maintenance.Repo
  alias FunPark.Ride
  alias FunPark.Maintenance.Store

  def add_to_all(%Ride{} = ride) do
    ride
    |> Repo.add_schedule()
    |> bind(&Repo.add_unschedule/1)
    |> bind(&Repo.add_lockout/1)
    |> bind(&Repo.add_compliance/1)
  end


  def remove_from_all(%Ride{} = ride) do
    Either.sequence_a([
      Repo.remove_schedule(ride),
      Repo.remove_unschedule(ride),
      Repo.remove_lockout(ride),
      Repo.remove_compliance(ride)
    ])
    |> map(fn _ -> ride end)
  end


  def check_in_all(%Ride{} = ride) do
    ride
    |> Repo.in_schedule()
    |> bind(&Repo.in_unschedule/1)
    |> bind(&Repo.in_lockout/1)
    |> bind(&Repo.in_compliance/1)
    |> Effect.run(%{store: Store})
  end


  def check_online_bind(%Ride{} = ride) do
    ride
    |> Repo.not_in_schedule()
    |> bind(&Repo.not_in_unschedule/1)
    |> bind(&Repo.not_in_lockout/1)
    |> bind(&Repo.not_in_compliance/1)
    |> Effect.run(%{store: Store})
  end


  def check_online(%Ride{} = ride) do
    Effect.validate(ride, [
      &Repo.not_in_schedule/1,
      &Repo.not_in_unschedule/1,
      &Repo.not_in_lockout/1,
      &Repo.not_in_compliance/1
    ])
    |> Effect.run(%{store: Store})
  end


  def online?(%Ride{} = ride) do
    ride
    |> check_online()
    |> Either.right?()
  end


  def ensure_online(%Ride{} = ride) do
    ride
    |> check_online()
    |> Either.map_left(&ValidationError.new/1)
  end

end

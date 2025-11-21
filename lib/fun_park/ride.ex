#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Ride do
  import FunPark.Filterable
  import FunPark.Monad
  import FunPark.Monoid.Utils, only: [m_concat: 2]
  import FunPark.Predicate
  import FunPark.Utils

  alias FunPark.Monad.Either
  alias FunPark.FastPass
  alias FunPark.Math
  alias FunPark.Monad.Maybe
  alias FunPark.Ord
  alias FunPark.Patron
  alias FunPark.Errors.ValidationError

  defstruct id: nil,
            name: "Unknown Ride",
            min_age: 0,
            min_height: 0,
            wait_time: 0,
            online: true,
            tags: []

  def make(name, opts \\ []) when is_binary(name) do
    %__MODULE__{
      id: :erlang.unique_integer([:positive]),
      name: name,
      min_age: Keyword.get(opts, :min_age, 0),
      min_height: Keyword.get(opts, :min_height, 0),
      wait_time: Keyword.get(opts, :wait_time, 0),
      online: Keyword.get(opts, :online, true),
      tags: Keyword.get(opts, :tags, [])
    }
  end


  def change(%__MODULE__{} = ride, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id)

    struct(ride, attrs)
  end


  def make_from_env(name) do
    FunPark.Reader.asks(fn config ->
      make(name)
      |> change(%{
        min_age: Map.get(config, :min_age, 0),
        min_height: Map.get(config, :min_height, 0)
      })
    end)
  end


  def ensure_min_age(%__MODULE__{name: name, min_age: min_age}) do
    Either.lift_predicate(
      min_age,
      p_not(&Math.negative?/1),
      fn _ -> "#{name}: min age must be non negative" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_min_height(%__MODULE__{name: name, min_height: min_height}) do
    Either.lift_predicate(
      min_height,
      p_not(&Math.negative?/1),
      fn _ -> "#{name}: min height must be non negative" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_wait_time(%__MODULE__{name: name, wait_time: wait_time}) do
    Either.lift_predicate(
      wait_time,
      p_not(&Math.negative?/1),
      fn _ -> "#{name}: wait time must be non negative" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_name(%__MODULE__{name: name}) do
    Either.lift_predicate(
      name |> String.trim() |> String.length(),
      &Math.positive?/1,
      fn _ -> "Name must be not be empty" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def validate(%__MODULE__{} = ride) do
    Either.validate(
      ride,
      [
        &ensure_min_age/1,
        &ensure_min_height/1,
        &ensure_wait_time/1,
        &ensure_name/1
      ]
    )
  end


  def get_tags(%__MODULE__{tags: tags}) when is_list(tags), do: tags

  def has_tag?(%__MODULE__{} = ride, tag) do
    Enum.any?(get_tags(ride), &(&1 == tag))
  end

  def has_all_tags?(%__MODULE__{} = ride, tags) when is_list(tags) do
    Enum.all?(tags, &has_tag?(ride, &1))
  end

  def has_any_tag?(%__MODULE__{} = ride, tags) when is_list(tags) do
    Enum.any?(tags, &has_tag?(ride, &1))
  end

  def is_family_friendly?(%__MODULE__{} = ride) do
    has_tag?(ride, :family_friendly)
  end

  def get_wait_time(%__MODULE__{wait_time: wait_time}), do: wait_time

  def ord_by_wait_time do
    Ord.Utils.contramap(&get_wait_time/1)
  end


  def tall_enough?(%Patron{} = patron, %__MODULE__{min_height: min_height}),
    do: Patron.get_height(patron) >= min_height


  def old_enough?(%Patron{} = patron, %__MODULE__{min_age: min_age}),
    do: Patron.get_age(patron) >= min_age


  def eligible?(%Patron{} = patron, %__MODULE__{} = ride),
    do:
      p_all([
        curry(&tall_enough?/2).(patron),
        curry(&old_enough?/2).(patron)
      ]).(ride)


  def online?(%__MODULE__{online: online}), do: online

  def long_wait?(%__MODULE__{wait_time: wait_time}), do: wait_time > 30

  def suggested?(%__MODULE__{} = ride),
    do: p_all([&online?/1, p_not(&long_wait?/1)]).(ride)


  def suggested?(%Patron{} = patron, %__MODULE__{} = ride),
    do:
      p_all([
        &suggested?/1,
        curry(&eligible?/2).(patron)
      ]).(ride)


  def suggested_rides(%Patron{} = patron, rides) when is_list(rides) do
    Enum.filter(rides, &suggested?(patron, &1))
  end


  def fast_pass?(%Patron{} = patron, %__MODULE__{} = ride) do
    patron
    |> Patron.get_fast_passes()
    |> Enum.any?(&FastPass.valid?(&1, ride))
  end



  def get_fast_pass(%Patron{} = patron, %__MODULE__{} = ride) do
    Enum.find(
      Patron.get_fast_passes(patron),
      &FastPass.valid?(&1, ride)
    )
    |> Maybe.from_nil()
  end



  def fast_pass_lane?(%Patron{} = patron, %__MODULE__{} = ride) do
    has_fast_pass = curry_r(&fast_pass?/2).(ride)
    is_eligible = curry_r(&eligible?/2).(ride)
    is_vip = &Patron.vip?/1

    p_all([is_eligible, p_any([is_vip, has_fast_pass])]).(patron)
  end


  def check_ride_eligibility(%Patron{} = patron, %__MODULE__{} = ride) do
    is_eligible = curry_r(&eligible?/2)
    Maybe.lift_predicate(patron, is_eligible.(ride))
  end


  def check_fast_pass(%Patron{} = patron, %__MODULE__{} = ride) do
    has_fast_pass = curry_r(&fast_pass?/2)
    Maybe.lift_predicate(patron, has_fast_pass.(ride))
  end


  def check_vip_or_fast_pass(patron, ride) do
    is_vip = &Patron.vip?/1

    patron
    |> Maybe.lift_predicate(is_vip)
    |> Maybe.or_else(fn -> check_fast_pass(patron, ride) end)
  end


  def fast_pass_lane(%Patron{} = patron, %__MODULE__{} = ride) do
    check_vip_or_pass = curry_r(&check_vip_or_fast_pass/2)

    patron
    |> check_ride_eligibility(ride)
    |> bind(check_vip_or_pass.(ride))
  end


  def priority_fast_lane(patrons, %__MODULE__{} = ride)
      when is_list(patrons) do
    m_concat(
      Patron.max_priority_maybe_monoid(),
      patrons |> Enum.map(&fast_pass_lane(&1, ride))
    )
  end


  def group_fast_pass_lane(patrons, %__MODULE__{} = ride)
      when is_list(patrons) do
    Maybe.traverse(patrons, &fast_pass_lane(&1, ride))
  end


  def only_fast_pass_lane_concat(patrons, %__MODULE__{} = ride)
      when is_list(patrons) do
    patrons
    |> Enum.map(&fast_pass_lane(&1, ride))
    |> Maybe.concat()
  end


  def only_fast_pass_lane(patrons, %__MODULE__{} = ride)
      when is_list(patrons) do
    patrons
    |> Maybe.concat_map(&fast_pass_lane(&1, ride))
  end


  def ensure_online(%__MODULE__{} = ride) do
    Either.lift_predicate(
      ride,
      &online?/1,
      fn r -> "#{r.name} is offline" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end


  def update_wait_time(%__MODULE__{} = ride, wait_time)
      when is_number(wait_time) do
    change(ride, %{wait_time: wait_time})
  end


  def update_wait_time_maybe(%__MODULE__{} = ride, wait_time)
      when is_number(wait_time) do
    ride
    |> Maybe.lift_predicate(&online?/1)
    |> guard(wait_time >= 0)
    |> map(&update_wait_time(&1, wait_time))
  end


  def add_wait_time(
        %__MODULE__{wait_time: wait_time} = ride,
        minutes
      )
      when is_number(minutes) and minutes > 0 do
    change(ride, %{wait_time: Math.sum(wait_time, minutes)})
  end

end

defimpl FunPark.Eq, for: FunPark.Ride do
  alias FunPark.Eq
  alias FunPark.Ride
  def eq?(%Ride{id: v1}, %Ride{id: v2}), do: Eq.eq?(v1, v2)
  def not_eq?(%Ride{id: v1}, %Ride{id: v2}), do: Eq.not_eq?(v1, v2)
end


defimpl FunPark.Ord, for: FunPark.Ride do
  alias FunPark.Ord
  alias FunPark.Ride

  def lt?(%Ride{name: v1}, %Ride{name: v2}), do: Ord.lt?(v1, v2)
  def le?(%Ride{name: v1}, %Ride{name: v2}), do: Ord.le?(v1, v2)
  def gt?(%Ride{name: v1}, %Ride{name: v2}), do: Ord.gt?(v1, v2)
  def ge?(%Ride{name: v1}, %Ride{name: v2}), do: Ord.ge?(v1, v2)
end


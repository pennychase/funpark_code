#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Patron do
  import FunPark.Filterable, only: [filter: 2]
  import FunPark.Macros, only: [ord_for: 2]
  import FunPark.Monad, only: [bind: 2, map: 2]
  import FunPark.Monoid.Utils, only: [m_concat: 2]

  import FunPark.Predicate
  import FunPark.Utils

  alias FunPark.Monad.Either
  alias FunPark.Eq
  alias FunPark.FastPass
  alias FunPark.List
  alias FunPark.Math
  alias FunPark.Monad.Maybe
  alias FunPark.Monoid
  alias FunPark.Ord
  alias FunPark.Ride
  alias FunPark.Utils


  defstruct id: nil,
            name: nil,
            age: 0,
            height: 0,
            ticket_tier: :basic,
            fast_passes: [],
            reward_points: 0,
            likes: [],
            dislikes: []

  def make(name, age, height, opts \\ [])
      when is_bitstring(name) and
             is_integer(age) and
             is_integer(height) and
             age > 0 and
             height > 0 do
    %__MODULE__{
      id: :erlang.unique_integer([:positive]),
      name: name,
      age: age,
      height: height,
      ticket_tier: Keyword.get(opts, :ticket_tier, :basic),
      fast_passes: Keyword.get(opts, :fast_passes, []),
      reward_points: Keyword.get(opts, :reward_points, 0),
      likes: Keyword.get(opts, :likes, []),
      dislikes: Keyword.get(opts, :dislikes, [])
    }
  end


  ord_for(FunPark.Patron, :name)



  def change(%__MODULE__{} = patron, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id)

    struct(patron, attrs)
  end


  def get_name(%__MODULE__{name: name}), do: name

  def get_height(%__MODULE__{height: height}), do: height
  def get_age(%__MODULE__{age: age}), do: age

  def get_reward_points(%__MODULE__{reward_points: reward_points}),
    do: reward_points

  def ord_by_reward_points do
    Ord.Utils.contramap(&get_reward_points/1)
  end


  def promotion(%__MODULE__{} = patron, points) do
    new_points = Math.sum(get_reward_points(patron), points)

    change(patron, %{reward_points: new_points})
  end


  defp tier_priority(:vip), do: 3
  defp tier_priority(:premium), do: 2
  defp tier_priority(:basic), do: 1
  defp tier_priority(_), do: 0

  defp get_ticket_tier_priority(%__MODULE__{ticket_tier: ticket_tier}),
    do: tier_priority(ticket_tier)

  def ord_by_ticket_tier do
    Ord.Utils.contramap(&get_ticket_tier_priority/1)
  end


  def ord_by_priority do
    Ord.Utils.concat([
      ord_by_ticket_tier(),
      ord_by_reward_points(),
      Ord
    ])
  end


  def priority_empty do
    %__MODULE__{reward_points: Float.min_finite(), ticket_tier: nil}
  end


  defp max_priority_monoid do
    %Monoid.Max{
      value: priority_empty(),
      ord: ord_by_priority()
    }
  end


  def highest_priority(patrons) when is_list(patrons) do
    m_concat(max_priority_monoid(), patrons)
  end


  def max_priority_maybe_monoid do
    %Monoid.Max{
      value: Maybe.nothing(),
      ord: Maybe.lift_ord(ord_by_priority())
    }
  end


  def highest_priority_maybe(patrons) when is_list(patrons) do
    m_concat(
      max_priority_maybe_monoid(),
      patrons |> Enum.map(&Maybe.pure/1)
    )
  end


  def get_fast_passes(%__MODULE__{fast_passes: fast_passes}),
    do: fast_passes

  def add_fast_pass(%__MODULE__{} = patron, fast_pass) do
    fast_passes = List.union([fast_pass], get_fast_passes(patron))

    change(patron, %{fast_passes: fast_passes})
  end


  def remove_fast_pass(%__MODULE__{} = patron, fast_pass) do
    fast_passes =
      List.difference(get_fast_passes(patron), [fast_pass])

    change(patron, %{fast_passes: fast_passes})
  end


  def add_fast_pass_maybe(%__MODULE__{} = patron, fast_pass) do
    ride = FastPass.get_ride(fast_pass)
    new_passes = List.union([fast_pass], get_fast_passes(patron))
    update_fast_pass = Utils.curry_r(&change/2)
    eligible = Utils.curry_r(&Ride.eligible?/2)

    patron
    |> Maybe.pure()
    |> filter(eligible.(ride))
    |> map(update_fast_pass.(%{fast_passes: new_passes}))
  end


  def add_fast_pass_either(%__MODULE__{} = patron, fast_pass) do
    ride = FastPass.get_ride(fast_pass)
    new_passes = List.union([fast_pass], get_fast_passes(patron))
    update_fast_pass = Utils.curry_r(&change/2)
    eligible = Utils.curry_r(&Ride.FastLane.validate_eligibility/2)

    patron
    |> Either.pure()
    |> bind(eligible.(ride))
    |> map(update_fast_pass.(%{fast_passes: new_passes}))
  end


  def add_fast_pass_bad(
        %__MODULE__{fast_passes: fast_passes} = patron,
        fast_pass
      ) do
    %{patron | fast_passes: fast_passes ++ [fast_pass]}
  end

  def vip?(%__MODULE__{ticket_tier: :vip}), do: true
  def vip?(%__MODULE__{}), do: false



  def get_likes(%__MODULE__{likes: likes}), do: likes
  def get_dislikes(%__MODULE__{dislikes: dislikes}), do: dislikes

  def add_likes(%__MODULE__{} = patron, likes)
      when is_list(likes) do
    updated_likes = List.union(likes, get_likes(patron))
    updated_dislikes = List.difference(get_dislikes(patron), updated_likes)

    change(patron, %{
      likes: updated_likes,
      dislikes: updated_dislikes
    })
  end

  def remove_likes(%__MODULE__{} = patron, likes)
      when is_list(likes) do
    updated_likes = List.difference(get_likes(patron), likes)
    change(patron, %{likes: updated_likes})
  end

  def add_dislikes(
        %__MODULE__{} = patron,
        dislikes
      )
      when is_list(dislikes) do
    updated_dislikes = List.union(dislikes, get_dislikes(patron))
    updated_likes = List.difference(get_likes(patron), updated_dislikes)

    change(patron, %{
      dislikes: updated_dislikes,
      likes: updated_likes
    })
  end

  def remove_dislikes(
        %__MODULE__{} = patron,
        dislikes
      )
      when is_list(dislikes) do
    updated_dislikes = List.difference(get_dislikes(patron), dislikes)
    change(patron, %{dislikes: updated_dislikes})
  end


  def likes_ride?(%__MODULE__{likes: likes}, %Ride{} = ride) do
    Ride.has_any_tag?(ride, likes)
  end

  def dislikes_ride?(%__MODULE__{dislikes: dislikes}, %Ride{} = ride) do
    Ride.has_any_tag?(ride, dislikes)
  end


  def recommended?(
        %__MODULE__{} = patron,
        %Ride{} = ride
      ) do
    p_all([
      curry(&likes_ride?/2).(patron),
      p_not(curry(&dislikes_ride?/2).(patron)),
      curry(&Ride.suggested?/2).(patron)
    ]).(ride)
  end

end

defimpl FunPark.Eq, for: FunPark.Patron do
  alias FunPark.Eq
  alias FunPark.Patron
  def eq?(%Patron{id: v1}, %Patron{id: v2}), do: Eq.eq?(v1, v2)
  def not_eq?(%Patron{id: v1}, %Patron{id: v2}), do: Eq.not_eq?(v1, v2)
end


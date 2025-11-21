#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.FastPass do
  alias FunPark.Eq
  alias FunPark.Ride

  defstruct id: nil,
            ride: nil,
            time: nil

  def make(%Ride{} = ride, %DateTime{} = time) do
    %__MODULE__{
      id: :erlang.unique_integer([:positive]),
      ride: ride,
      time: time
    }
  end


  def change(%__MODULE__{} = fast_pass, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id)

    struct(fast_pass, attrs)
  end


  def get_time(%__MODULE__{time: time}), do: time

  def eq_time do
    Eq.Utils.contramap(&get_time/1)
  end


  def get_ride(%__MODULE__{ride: ride}), do: ride


  def eq_ride do
    Eq.Utils.contramap(&get_ride/1)
  end


  def eq_ride_and_time do
    Eq.Utils.concat_all([eq_ride(), eq_time()])
  end


  def duplicate_pass do
    Eq.Utils.concat_any([Eq, eq_ride_and_time()])
  end


  def valid?(%__MODULE__{} = fast_pass, %Ride{} = ride) do
    Eq.Utils.eq?(get_ride(fast_pass), ride)
  end

end

defimpl FunPark.Eq, for: FunPark.FastPass do
  alias FunPark.Eq
  alias FunPark.FastPass
  def eq?(%FastPass{id: v1}, %FastPass{id: v2}), do: Eq.eq?(v1, v2)
  def not_eq?(%FastPass{id: v1}, %FastPass{id: v2}), do: Eq.not_eq?(v1, v2)
end


defimpl FunPark.Ord, for: FunPark.FastPass do
  alias FunPark.Ord
  alias FunPark.FastPass

  def lt?(%FastPass{time: v1}, %FastPass{time: v2}), do: Ord.lt?(v1, v2)
  def le?(%FastPass{time: v1}, %FastPass{time: v2}), do: Ord.le?(v1, v2)
  def gt?(%FastPass{time: v1}, %FastPass{time: v2}), do: Ord.gt?(v1, v2)
  def ge?(%FastPass{time: v1}, %FastPass{time: v2}), do: Ord.ge?(v1, v2)
end


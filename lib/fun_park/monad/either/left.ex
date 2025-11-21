#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monad.Either.Left do
  @enforce_keys [:left]
  defstruct [:left]

  def pure(value), do: %__MODULE__{left: value}
end


defimpl String.Chars, for: FunPark.Monad.Either.Left do
  alias FunPark.Monad.Either.Left

  def to_string(%Left{left: left}), do: "Left(#{left})"
end


defimpl FunPark.Monad, for: FunPark.Monad.Either.Left do
  alias FunPark.Monad.Either.{Left, Right}
  def map(%Left{} = left, _func), do: left

  def ap(%Left{} = left, %Left{}), do: left
  def ap(%Left{} = left, %Right{}), do: left

  def bind(%Left{} = left, _func), do: left
end


defimpl FunPark.Foldable, for: FunPark.Monad.Either.Left do
  alias FunPark.Monad.Either.Left

  def fold_l(%Left{left: left}, _right_func, left_func) do
    left_func.(left)
  end

  def fold_r(%Left{} = left, right_func, left_func) do
    fold_l(left, right_func, left_func)
  end
end


defimpl FunPark.Eq, for: FunPark.Monad.Either.Left do
  alias FunPark.Monad.Either.{Left, Right}
  alias FunPark.Eq

  def eq?(%Left{left: v1}, %Left{left: v2}), do: Eq.eq?(v1, v2)
  def eq?(%Left{}, %Right{}), do: false

  def not_eq?(%Left{left: v1}, %Left{left: v2}), do: Eq.not_eq?(v1, v2)
  def not_eq?(%Left{}, %Right{}), do: true
end


defimpl FunPark.Ord, for: FunPark.Monad.Either.Left do
  alias FunPark.Monad.Either.{Left, Right}
  alias FunPark.Ord

  def lt?(%Left{left: v1}, %Left{left: v2}), do: Ord.lt?(v1, v2)
  def lt?(%Left{}, %Right{}), do: true

  def le?(%Left{left: v1}, %Left{left: v2}), do: Ord.le?(v1, v2)
  def le?(%Left{}, %Right{}), do: true

  def gt?(%Left{left: v1}, %Left{left: v2}), do: Ord.gt?(v1, v2)
  def gt?(%Left{}, %Right{}), do: false

  def ge?(%Left{left: v1}, %Left{left: v2}), do: Ord.ge?(v1, v2)
  def ge?(%Left{}, %Right{}), do: false
end


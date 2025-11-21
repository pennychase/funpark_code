#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monad.Maybe.Just do
  @enforce_keys [:value]
  defstruct [:value]

  def pure(nil), do: raise(ArgumentError, "Cannot wrap nil in a Just")
  def pure(value), do: %__MODULE__{value: value}
end


defimpl FunPark.Monad, for: FunPark.Monad.Maybe.Just do
  alias FunPark.Monad.Maybe.{Just, Nothing}

  def map(%Just{value: value}, func), do: Just.pure(func.(value))

  def ap(%Just{value: func}, %Just{value: value}),
    do: Just.pure(func.(value))

  def ap(%Just{}, %Nothing{}), do: %Nothing{}

  def bind(%Just{value: value}, func), do: func.(value)
end


defimpl String.Chars, for: FunPark.Monad.Maybe.Just do
  alias FunPark.Monad.Maybe.Just

  def to_string(%Just{value: value}), do: "Just(#{value})"
end


defimpl FunPark.Foldable, for: FunPark.Monad.Maybe.Just do
  alias FunPark.Monad.Maybe.Just

  def fold_l(%Just{value: value}, just_func, _nothing_func) do
    just_func.(value)
  end

  def fold_r(%Just{} = just, just_func, nothing_func) do
    fold_l(just, just_func, nothing_func)
  end
end


defimpl FunPark.Filterable, for: FunPark.Monad.Maybe.Just do
  alias FunPark.Monad.Maybe
  alias FunPark.Monad.Maybe.Just
  alias FunPark.Monad

  def guard(%Just{} = maybe, true), do: maybe
  def guard(%Just{}, false), do: Maybe.nothing()

  def filter(%Just{} = maybe, predicate) do
    Monad.bind(maybe, fn value ->
      if predicate.(value) do
        Maybe.pure(value)
      else
        Maybe.nothing()
      end
    end)
  end

  def filter_map(%Just{value: value}, func) do
    case func.(value) do
      %Just{} = just -> just
      _ -> Maybe.nothing()
    end
  end
end


defimpl FunPark.Eq, for: FunPark.Monad.Maybe.Just do
  alias FunPark.Monad.Maybe.{Just, Nothing}
  alias FunPark.Eq

  def eq?(%Just{value: v1}, %Just{value: v2}), do: Eq.eq?(v1, v2)
  def eq?(%Just{}, %Nothing{}), do: false

  def not_eq?(%Just{value: v1}, %Just{value: v2}), do: not Eq.eq?(v1, v2)
  def not_eq?(%Just{}, %Nothing{}), do: true
end


defimpl FunPark.Ord, for: FunPark.Monad.Maybe.Just do
  alias FunPark.Monad.Maybe.{Just, Nothing}
  alias FunPark.Ord

  def lt?(%Just{value: v1}, %Just{value: v2}), do: Ord.lt?(v1, v2)
  def lt?(%Just{}, %Nothing{}), do: false

  def le?(%Just{value: v1}, %Just{value: v2}), do: Ord.le?(v1, v2)
  def le?(%Just{}, %Nothing{}), do: false

  def gt?(%Just{value: v1}, %Just{value: v2}), do: Ord.gt?(v1, v2)
  def gt?(%Just{}, %Nothing{}), do: true

  def ge?(%Just{value: v1}, %Just{value: v2}), do: Ord.ge?(v1, v2)
  def ge?(%Just{}, %Nothing{}), do: true
end


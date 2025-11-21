#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monad.Maybe.Nothing do
  defstruct []

  def pure, do: %__MODULE__{}
end


defimpl FunPark.Monad, for: FunPark.Monad.Maybe.Nothing do
  alias FunPark.Monad.Maybe.Nothing

  def map(%Nothing{}, _func), do: %Nothing{}
  def ap(%Nothing{}, _val), do: %Nothing{}
  def bind(%Nothing{}, _func), do: %Nothing{}
end


defimpl String.Chars, for: FunPark.Monad.Maybe.Nothing do
  alias FunPark.Monad.Maybe.Nothing

  def to_string(%Nothing{}), do: "Nothing"
end


defimpl FunPark.Foldable, for: FunPark.Monad.Maybe.Nothing do
  alias FunPark.Monad.Maybe.Nothing

  def fold_l(%Nothing{}, _just_func, nothing_func) do
    nothing_func.()
  end

  def fold_r(%Nothing{} = nothing, just_func, nothing_func) do
    fold_l(nothing, just_func, nothing_func)
  end
end


defimpl FunPark.Filterable, for: FunPark.Monad.Maybe.Nothing do
  alias FunPark.Monad.Maybe.Nothing

  def guard(%Nothing{}, _boolean), do: %Nothing{}
  def filter(%Nothing{}, _predicate), do: %Nothing{}
  def filter_map(%Nothing{}, _func), do: %Nothing{}
end


defimpl FunPark.Eq, for: FunPark.Monad.Maybe.Nothing do
  alias FunPark.Monad.Maybe.{Nothing, Just}

  def eq?(%Nothing{}, %Nothing{}), do: true
  def eq?(%Nothing{}, %Just{}), do: false

  def not_eq?(%Nothing{}, %Nothing{}), do: false
  def not_eq?(%Nothing{}, %Just{}), do: true
end


defimpl FunPark.Ord, for: FunPark.Monad.Maybe.Nothing do
  alias FunPark.Monad.Maybe.{Nothing, Just}

  def lt?(%Nothing{}, %Just{}), do: true
  def lt?(%Nothing{}, %Nothing{}), do: false

  def le?(%Nothing{}, %Just{}), do: true
  def le?(%Nothing{}, %Nothing{}), do: true

  def gt?(%Nothing{}, %Just{}), do: false
  def gt?(%Nothing{}, %Nothing{}), do: false

  def ge?(%Nothing{}, %Just{}), do: false
  def ge?(%Nothing{}, %Nothing{}), do: true
end


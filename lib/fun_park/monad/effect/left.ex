#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monad.Effect.Left do
  alias FunPark.Monad.Either

  defstruct [:effect]

  def pure(value) do
    %__MODULE__{
      effect: fn _env ->
        Task.async(fn -> Either.left(value) end)
      end
    }
  end



  def asks(f) do
    %__MODULE__{
      effect: fn env ->
        Task.async(fn -> Either.left(f.(env)) end)
      end
    }
  end
end

defimpl FunPark.Monad, for: FunPark.Monad.Effect.Left do
  alias FunPark.Monad.Effect.Left

  def map(%Left{} = left, _transform), do: left


  def bind(%Left{} = left, _func), do: left


  def ap(%Left{} = left, _func), do: left
end

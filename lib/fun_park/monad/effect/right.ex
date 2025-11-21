#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monad.Effect.Right do
  alias FunPark.Monad.Either

  defstruct [:effect]

  def pure(value) do
    %__MODULE__{
      effect: fn _env ->
        Task.async(fn -> Either.pure(value) end)
      end
    }
  end


  def asks(f) do
    %__MODULE__{
      effect: fn env ->
        Task.async(fn -> Either.pure(f.(env)) end)
      end
    }
  end
end

defimpl FunPark.Monad, for: FunPark.Monad.Effect.Right do
  alias FunPark.Errors.EffectError
  alias FunPark.Monad.{Effect, Either}
  alias Effect.{Left, Right}


  def map(%Right{effect: effect}, transform) do
    %Right{
      effect: fn env ->
        Task.async(fn ->
          case Effect.run(%Right{effect: effect}, env) do
            %Either.Right{right: value} ->
              try do
                Either.pure(transform.(value))
              rescue
                e -> Either.left(EffectError.new(:map, e))
              end

            %Either.Left{} = left ->
              left
          end
        end)
      end
    }
  end


  def bind(%Right{effect: effect}, kleisli_fn) do
    %Right{
      effect: fn env ->
        Task.async(fn ->
          case Effect.run(%Right{effect: effect}, env) do
            %Either.Right{right: value} ->
              try do
                kleisli_fn.(value) |> Effect.run(env)
              rescue
                e -> Either.left(EffectError.new(:bind, e))
              end

            %Either.Left{} = left ->
              left
          end
        end)
      end
    }
  end


  def ap(%Right{effect: effect_func}, %Right{effect: effect_value}) do
    %Right{
      effect: fn env ->
        Task.async(fn ->
          with %Either.Right{right: func} <- Effect.run(%Right{effect: effect_func}, env),
               %Either.Right{right: value} <- Effect.run(%Right{effect: effect_value}, env) do
            try do
              Either.pure(right: func.(value))
            rescue
              e -> Either.left(EffectError.new(:ap, e))
            end
          else
            %Either.Left{} = left -> left
          end
        end)
      end
    }
  end

  def ap(%Right{}, %Left{} = left), do: left
end

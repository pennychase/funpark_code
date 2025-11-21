#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monad.Effect do
  import FunPark.Appendable, only: [append: 2, coerce: 1]
  import FunPark.Monad, only: [map: 2]

  alias FunPark.Errors.EffectError
  alias FunPark.Monad.{Effect, Either, Maybe}
  alias Effect.{Left, Right}
  alias Maybe.{Just, Nothing}

  def right(value), do: Right.pure(value)
  def pure(value), do: right(value)
  def left(value), do: Left.pure(value)

  def asks(f), do: Right.asks(f)
  def fails(f), do: Left.asks(f)

  def run(%_{effect: thunk}, env \\ %{}), do: execute_effect(thunk.(env))

  defp execute_effect(task) do
    start_time = System.monotonic_time(:millisecond)

    result =
      try do
        case Task.yield(task, 5000) || Task.shutdown(task) do
          {:ok, %Either.Right{} = right} ->
            right

          {:ok, %Either.Left{} = left} ->
            left

          {:ok, other} ->
            Either.left(
              EffectError.new(
                :run,
                {:invalid_result, other}
              )
            )

          nil ->
            Either.left(EffectError.new(:run, :timeout))
        end
      rescue
        error -> Either.left(EffectError.new(:run, error))
      end

    elapsed = System.monotonic_time(:millisecond) - start_time
    IO.puts("Task completed in #{elapsed}ms")

    result
  end


  def lift_func(thunk) when is_function(thunk, 0) do
    %Right{
      effect: fn _env ->
        Task.async(fn ->
          try do
            Either.pure(thunk.())
          rescue
            error -> Either.left(EffectError.new(:lift_func, error))
          end
        end)
      end
    }
  end


  def lift_predicate(value, predicate, on_false) do
    if predicate.(value), do: right(value), else: left(on_false.(value))
  end



  def lift_either(thunk) when is_function(thunk, 0) do
    %Right{
      effect: fn _env ->
        Task.async(fn ->
          try do
            case thunk.() do
              %Either.Right{} = right -> right
              %Either.Left{} = left -> left
            end
          rescue
            error ->
              Either.left(EffectError.new(:lift_either, error))
          end
        end)
      end
    }
  end


  def lift_maybe(%Just{value: value}, _on_none), do: right(value)
  def lift_maybe(%Nothing{}, on_none), do: left(on_none.())

  # def map_left(%Right{} = r, _func), do: r

  def map_left(%Right{effect: eff}, func) do
    %Right{
      effect: fn env ->
        Task.async(fn ->
          case Task.await(eff.(env)) do
            %Either.Right{right: r} -> Either.pure(r)
            %Either.Left{left: l} -> Either.left(func.(l))
          end
        end)
      end
    }
  end

  def map_left(%Left{effect: eff}, func) do
    %Left{
      effect: fn env ->
        Task.async(fn ->
          case run(%Left{effect: eff}, env) do
            %Either.Left{left: err} -> Either.left(func.(err))
            other -> other
          end
        end)
      end
    }
  end


  def flip_either(%Right{effect: eff}) do
    %Right{
      effect: fn env ->
        Task.async(fn ->
          run(%Right{effect: eff}, env)
          |> Either.flip()
        end)
      end
    }
  end

  def flip_either(%Left{effect: eff}) do
    %Left{
      effect: fn env ->
        Task.async(fn ->
          run(%Left{effect: eff}, env)
          |> Either.flip()
        end)
      end
    }
  end


  def sequence(list), do: traverse(list, & &1)


  def traverse([], _), do: pure([])

  def traverse([h | t], f) do
    case f.(h) do
      %Left{} = l ->
        l

      %Right{effect: e1} ->
        case traverse(t, f) do
          %Left{} = l ->
            l

          %Right{effect: e2} ->
            %Right{
              effect: fn env ->
                Task.async(fn ->
                  with %Either.Right{right: x} <- run(%Right{effect: e1}, env),
                       %Either.Right{right: xs} <- run(%Right{effect: e2}, env) do
                    %Either.Right{right: [x | xs]}
                  else
                    %Either.Left{} = left -> left
                  end
                end)
              end
            }
        end
    end
  end


  def sequence_a(list), do: traverse_a(list, & &1)

  def traverse_a([], _func), do: right([])

  def traverse_a(list, func) when is_list(list) and is_function(func, 1) do
    %Right{
      effect: fn env ->
        Task.async(fn ->
          tasks =
            Enum.map(list, fn item ->
              func.(item)
              |> spawn_effect(env)
            end)

          results = Enum.map(tasks, &collect_result/1)

          {oks, errs} =
            Enum.split_with(results, fn
              {:ok, _} -> true
              {:error, _} -> false
            end)

          case errs do
            [] ->
              values = Enum.map(oks, fn {:ok, val} -> val end)
              %Either.Right{right: values}

            _ ->
              errors =
                errs
                |> Enum.map(fn {:error, val} -> coerce(val) end)
                |> Enum.reduce(&append(&1, &2))

              %Either.Left{left: errors}
          end
        end)
      end
    }
  end


  defp spawn_effect(%Right{effect: eff}, env),
    do: Task.async(fn -> run(%Right{effect: eff}, env) end)

  defp spawn_effect(%Left{effect: eff}, env),
    do: Task.async(fn -> run(%Left{effect: eff}, env) end)

  defp collect_result(task) do
    case execute_effect(task) do
      %Either.Right{right: val} -> {:ok, val}
      %Either.Left{left: err} -> {:error, err}
    end
  end

  def validate(value, validators) when is_list(validators) do
    traverse_a(validators, fn v -> v.(value) end)
    |> map(fn _ -> value end)
  end


  # def validate(value, validator, opts) when is_function(validator, 1) do
  #   validate(value, [validator], opts)
  # end

  def from_result({:ok, v}), do: right(v)
  def from_result({:error, e}), do: left(e)

  def to_result(effect) do
    case run(effect) do
      %Either.Right{right: v} -> {:ok, v}
      %Either.Left{left: e} -> {:error, e}
    end
  end

  def from_try(func) when is_function(func, 1) do
    fn value ->
      %Right{
        effect: fn _env ->
          Task.async(fn ->
            Either.from_try(fn -> func.(value) end)
          end)
        end
      }
    end
  end

  def to_try!(effect) do
    effect
    |> run()
    |> Either.to_try!()
  end
end

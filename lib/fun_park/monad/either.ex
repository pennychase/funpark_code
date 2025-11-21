#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Monad.Either do
  import FunPark.Appendable, only: [append: 2, coerce: 1]
  import FunPark.Monad, only: [map: 2]
  import FunPark.Foldable, only: [fold_l: 3]

  alias FunPark.Monad.Either.{Left, Right}
  alias FunPark.Eq
  alias FunPark.Ord

  def right(value), do: Right.pure(value)
  def left(value), do: Left.pure(value)
  def pure(value), do: right(value)

  def right?(%Right{}), do: true
  def right?(_), do: false

  def left?(%Left{}), do: true
  def left?(_), do: false


  def filter_or_else(either, predicate, left_func) do
    fold_l(
      either,
      fn value ->
        if predicate.(value) do
          either
        else
          left(left_func.())
        end
      end,
      fn _left_value -> either end
    )
  end


  def get_or_else(either, default) do
    fold_l(
      either,
      fn value -> value end,
      fn _ -> default end
    )
  end


  def or_else(%Left{}, fallback_fun) when is_function(fallback_fun, 0), do: fallback_fun.()
  def or_else(%Right{} = right, _), do: right

  def lift_eq(custom_eq) do
    custom_eq = Eq.Utils.to_eq_map(custom_eq)

    %{
      eq?: fn
        %Right{right: v1}, %Right{right: v2} -> custom_eq.eq?.(v1, v2)
        %Left{left: v1}, %Left{left: v2} -> custom_eq.eq?.(v1, v2)
        _, _ -> false
      end,
      not_eq?: fn
        %Right{right: v1}, %Right{right: v2} -> custom_eq.not_eq?.(v1, v2)
        %Left{left: v1}, %Left{left: v2} -> custom_eq.not_eq?.(v1, v2)
        _, _ -> true
      end
    }
  end


  def lift_ord(custom_ord) do
    custom_ord = Ord.Utils.to_ord_map(custom_ord)

    %{
      lt?: fn
        %Right{right: v1}, %Right{right: v2} -> custom_ord.lt?.(v1, v2)
        %Left{left: v1}, %Left{left: v2} -> custom_ord.lt?.(v1, v2)
        %Left{}, %Right{} -> true
        %Right{}, %Left{} -> false
      end,
      le?: fn
        %Right{right: v1}, %Right{right: v2} -> custom_ord.le?.(v1, v2)
        %Left{left: v1}, %Left{left: v2} -> custom_ord.le?.(v1, v2)
        %Left{}, %Right{} -> true
        %Right{}, %Left{} -> false
      end,
      gt?: fn
        %Right{right: v1}, %Right{right: v2} -> custom_ord.gt?.(v1, v2)
        %Left{left: v1}, %Left{left: v2} -> custom_ord.gt?.(v1, v2)
        %Right{}, %Left{} -> true
        %Left{}, %Right{} -> false
      end,
      ge?: fn
        %Right{right: v1}, %Right{right: v2} -> custom_ord.ge?.(v1, v2)
        %Left{left: v1}, %Left{left: v2} -> custom_ord.ge?.(v1, v2)
        %Right{}, %Left{} -> true
        %Left{}, %Right{} -> false
      end
    }
  end


  def map_left(%Left{left: error}, func), do: left(func.(error))
  def map_left(%Right{} = right, _), do: right

  def flip(%Left{left: l}), do: %Right{right: l}
  def flip(%Right{right: r}), do: %Left{left: r}

  def concat(list) do
    list
    |> fold_l([], fn
      %Right{right: value}, acc -> [value | acc]
      %Left{}, acc -> acc
    end)
    |> :lists.reverse()
  end


  def concat_map(list, func) do
    list
    |> fold_l([], fn item, acc ->
      case func.(item) do
        %Right{right: value} -> [value | acc]
        %Left{} -> acc
      end
    end)
    |> :lists.reverse()
  end


  def sequence(list), do: traverse(list, & &1)

  def traverse([], _func), do: pure([])

  def traverse(list, func) do
    Enum.reduce_while(list, pure([]), fn item, %Right{right: acc} ->
      case func.(item) do
        %Right{right: value} -> {:cont, pure([value | acc])}
        %Left{} = left -> {:halt, left}
      end
    end)
    |> map(&:lists.reverse/1)
  end


  def sequence_a(list), do: traverse_a(list, & &1)

  def traverse_a([], _func), do: right([])

  def traverse_a(list, func) when is_list(list) and is_function(func, 1) do
    fold_l(list, right([]), fn item, acc_result ->
      case {func.(item), acc_result} do
        {%Right{right: value}, %Right{right: acc}} ->
          right([value | acc])

        {%Left{left: new}, %Left{left: existing}} ->
          left(append(existing, coerce(new)))

        {%Right{}, %Left{left: existing}} ->
          left(existing)

        {%Left{left: err}, %Right{}} ->
          left(coerce(err))
      end
    end)
    |> map(&:lists.reverse/1)
  end


  def validate(value, validators) when is_list(validators) do
    traverse_a(validators, fn validator -> validator.(value) end)
    |> map(fn _ -> value end)
  end


  def validate(value, validator) when is_function(validator, 1) do
    validate(value, [validator])
  end


  def lift_maybe(maybe, on_none)
      when is_struct(maybe, Just) or
             is_struct(maybe, Nothing) do
    maybe
    |> fold_l(
      fn value -> right(value) end,
      fn -> left(on_none.()) end
    )
  end


  def lift_predicate(value, predicate, on_false)
      when is_function(predicate, 1) and is_function(on_false, 1) do
    fold_l(
      fn -> predicate.(value) end,
      fn -> right(value) end,
      fn -> left(on_false.(value)) end
    )
  end


  def from_result({:ok, value}), do: right(value)
  def from_result({:error, reason}), do: left(reason)

  def to_result(either)
      when is_struct(either, Right) or
             is_struct(either, Left) do
    case either do
      %Right{right: value} -> {:ok, value}
      %Left{left: reason} -> {:error, reason}
    end
  end


  def from_try(func) do
    try do
      result = func.()
      right(result)
    rescue
      exception ->
        left(exception)
    end
  end


  def to_try!(%Right{right: value}), do: value

  def to_try!(%Left{left: reason}) do
    raise normalize_reason(reason)
  end

  defp normalize_reason(%_{} = exception), do: exception

  defp normalize_reason(reason) when is_list(reason),
    do: Enum.map_join(reason, ", ", &to_string/1)

  defp normalize_reason(reason) when is_binary(reason), do: reason

  defp normalize_reason(reason), do: "Unexpected error: #{inspect(reason)}"
end

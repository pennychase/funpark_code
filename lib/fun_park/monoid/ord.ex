#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
# credo:disable-for-this-file
defmodule FunPark.Monoid.Ord do
  defstruct lt?: &FunPark.Monoid.Ord.default?/2,
            le?: &FunPark.Monoid.Ord.default?/2,
            gt?: &FunPark.Monoid.Ord.default?/2,
            ge?: &FunPark.Monoid.Ord.default?/2

  def default?(_, _), do: false
end


defimpl FunPark.Monoid, for: FunPark.Monoid.Ord do
  alias FunPark.Monoid.Ord
  alias FunPark.Ord.Utils

  def empty(_) do
    %Ord{}
  end


  def append(%Ord{} = ord1, %Ord{} = ord2) do
    %Ord{
      lt?: fn a, b ->
        cond do
          ord1.lt?.(a, b) -> true
          ord1.gt?.(a, b) -> false
          true -> ord2.lt?.(a, b)
        end
      end,
      le?: fn a, b ->
        cond do
          ord1.lt?.(a, b) -> true
          ord1.gt?.(a, b) -> false
          true -> ord2.le?.(a, b)
        end
      end,
      gt?: fn a, b ->
        cond do
          ord1.gt?.(a, b) -> true
          ord1.lt?.(a, b) -> false
          true -> ord2.gt?.(a, b)
        end
      end,
      ge?: fn a, b ->
        cond do
          ord1.gt?.(a, b) -> true
          ord1.lt?.(a, b) -> false
          true -> ord2.ge?.(a, b)
        end
      end
    }
  end


  def wrap(%Ord{}, ord) do
    ord = Utils.to_ord_map(ord)

    %Ord{
      lt?: ord.lt?,
      le?: ord.le?,
      gt?: ord.gt?,
      ge?: ord.ge?
    }
  end

  def unwrap(%Ord{lt?: lt?, le?: le?, gt?: gt?, ge?: ge?}) do
    %{
      lt?: lt?,
      le?: le?,
      gt?: gt?,
      ge?: ge?
    }
  end

end


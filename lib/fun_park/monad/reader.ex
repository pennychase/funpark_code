#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Reader do
  @enforce_keys [:run]
  defstruct [:run]

  def pure(value), do: %__MODULE__{run: fn _env -> value end}

  def run(%__MODULE__{run: f}, env), do: f.(env)

  def ask, do: %__MODULE__{run: fn env -> env end}

  def asks(func), do: %__MODULE__{run: func}
end

defimpl FunPark.Monad, for: FunPark.Reader do
  alias FunPark.Reader

  def map(%Reader{run: f}, func),
    do: %Reader{run: fn env -> func.(f.(env)) end}

  def bind(%Reader{run: f}, func),
    do: %Reader{run: fn env -> func.(f.(env)).run.(env) end}

  def ap(%Reader{run: f_func}, %Reader{run: f_value}),
    do: %Reader{run: fn env -> f_func.(env).(f_value.(env)) end}
end


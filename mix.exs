#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.MixProject do
  use Mix.Project

  def project do
    [
      app: :fun_park,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: [],
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :observer, :wx, :runtime_tools]
    ]
  end

  defp aliases do
    [
      restart: ["clean", "compile"]
    ]
  end
end

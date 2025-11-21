#---
# Excerpted from "Advanced Functional Programming with Monads in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/jkelixir for more book information.
#---
defmodule FunPark.Predicate do
  import FunPark.Monoid.Utils, only: [m_append: 3, m_concat: 2]
  alias FunPark.Monoid.Predicate.{All, Any}

  def p_and(pred1, pred2) when is_function(pred1) and is_function(pred2) do
    m_append(%All{}, pred1, pred2)
  end


  def p_or(pred1, pred2) when is_function(pred1) and is_function(pred2) do
    m_append(%Any{}, pred1, pred2)
  end


  def p_not(pred) when is_function(pred) do
    fn value -> not pred.(value) end
  end


  def p_all(p_list) when is_list(p_list) do
    m_concat(%All{}, p_list)
  end


  def p_any(p_list) when is_list(p_list) do
    m_concat(%Any{}, p_list)
  end


  def p_none(p_list) when is_list(p_list) do
    p_not(p_any(p_list))
  end

end


defimpl FunPark.Foldable, for: Function do
  def fold_l(predicate, true_func, false_func) do
    case predicate.() do
      true -> true_func.()
      false -> false_func.()
    end
  end

  def fold_r(predicate, true_func, false_func) do
    fold_l(predicate, true_func, false_func)
  end
end


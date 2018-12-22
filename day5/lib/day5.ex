defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """

  @doc """
  Parse

  ## Examples

      iex> Day5.react("Aa")
      ""

      iex> Day5.react("abBA")
      ""

      iex> Day5.react("aabAAB")
      "aabAAB"

      iex> Day5.react("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"
  """
  def react(cad) when is_binary(cad) do
    cad
    |> String.trim()
    |> String.codepoints()
    |> react([])
    |> Enum.reverse()
    |> Enum.join("")
  end

  defp react([], acc), do: acc

  defp react([first | []], [first_acc | rest] = acc) do
    if do_react?(first, first_acc) do
      rest
    else
      [first | acc]
    end
  end

  defp react([first| [second | rest]], [first_acc | rest_acc] = acc) do
    if do_react?(first, first_acc) do
      react([second | rest], rest_acc)
    else
      if do_react?(first, second) do
        react(rest, acc)
      else
        react([second | rest], [first |  acc])
      end
    end
  end

  defp react([first| [second | rest]], acc) do
    if do_react?(first, second) do
      react(rest, acc)
    else
      react([second | rest], [first |  acc])
    end
  end

  defp do_react?(first, second) when first == second, do: false
  defp do_react?(first, second) do
    String.upcase(first) == second or String.upcase(second) == first
  end

  @doc """
  Remove products and check minimun reaction

  ## Examples

      iex> Day5.shortest_polymer("dabAcCaCBAcCcaDA")
      4
  """
  def shortest_polymer(data) do
    shortest = react(data)
               |> String.length()
    Enum.reduce(97..122, shortest, fn(x, acc) ->
      to_replace = <<x>> <> "|" <> String.upcase(<<x>>)
      new_length = String.replace(data, ~r/#{to_replace}/, "")
                   |> react()
                   |> String.length()
      if new_length < acc do
        new_length
      else
        acc
      end
    end)
  end

end

map_times = fn(string) ->
  string
  |> String.split("", trim: true)
  |> Enum.reduce(%{}, fn(letter, map) ->
    case Map.get(map, letter) do
      nil ->
        Map.put(map, letter, 1)
      rep ->
        Map.put(map, letter, rep + 1)
    end
  end)
  |> Enum.reduce(%{2 => 0, 3 => 0}, fn(duple, acc) ->
    case duple do
      {_letter, 2} ->
        Map.put(acc, 2, 1)
      {_letter, 3} ->
        Map.put(acc, 3, 1)
      _ -> acc
    end
  end)
end

check_sum = fn(%{ 2 => twice, 3 => three}) ->
  twice * three
end

"list.txt"
|> File.stream!
|> Enum.reduce(%{ 2 => 0, 3 => 0}, fn(line, acc) ->
  res = map_times.(line)
  %{2 => acc[2]+res[2], 3 => acc[3]+res[3]}
end)
|> check_sum.()
|> IO.inspect

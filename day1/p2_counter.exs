"./input_d1.txt"
|> File.stream!
|> Stream.cycle()
|> Enum.reduce({%{0 => 0}, 0}, fn(val, {map, acc}) ->
  num = val
        |> String.trim_trailing()
        |> String.to_integer()
  case Map.get(map, num+acc) do
    nil -> { Map.put(map, num+acc, num+acc) ,num+acc}
    res ->
      IO.puts "Found in #{res}"
      System.halt(0)
  end
end
)

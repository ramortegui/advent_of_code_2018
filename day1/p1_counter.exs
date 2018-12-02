File.stream!("./input_d1.txt")
|> Enum.reduce(0, fn(val, acc) ->
  num = val
  |> String.trim_trailing()
  |> String.to_integer()
  num + acc
    end
  )
|> IO.puts


check_letters = fn(list) ->
  for word1 <-list, word2 <- list do
  case String.myers_difference(word1, word2) do
    [eq: eqinit, del: del, ins: ins, eq: eqend] ->
      if(String.length(del) == 1 and String.length(ins)) do
        IO.puts "#{eqinit}#{eqend}"
      end
    _ ->
      true
  end
  end
end

{:ok, list} = "list.txt"
              |> File.read
list
|> String.split("\n", trim: true)
|> check_letters.()


defmodule Claims do
  def fill(acc, label, row, col, _width, _height, width_count, height_count) when height_count == 0 and width_count == 0  do
    case Map.get(acc, {row+height_count, col+width_count}) do
      nil ->
        Map.put(acc, {row+height_count, col+width_count}, label)
      _ ->
        Map.put(acc, {row+height_count, col+width_count}, "#")
    end
  end
  def fill(acc, label, row, col, width, height, width_count, height_count) when width_count > 0 do
    acc = case Map.get(acc, {row+height_count, col+width_count}) do
      nil ->
        Map.put(acc, {row+height_count, col+width_count}, label)
      _ ->
        Map.put(acc, {row+height_count, col+width_count}, "#")
    end
    fill(acc, label, row, col, width, height , width_count-1, height_count)
  end
  def fill(acc, label, row, col, width, height, width_count, height_count) do
    acc = case Map.get(acc, {row+height_count, col+width_count}) do
      nil ->
        Map.put(acc, {row+height_count, col+width_count}, label)
      _ ->
        Map.put(acc, {row+height_count, col+width_count}, "#")
    end
    fill(acc, label, row, col, width, height , width-1, height_count-1)
  end
end


{:ok, data} = File.read('plan.txt')

# 0,1,2,3,4.... 999
# 1000,6,7,8,9...1999.
#

data
|> String.trim_trailing()
|> String.split("\n")
|> Enum.reduce(%{}, fn(line, acc) ->
  raw_line = line
             |> String.split(" ")
  label = Enum.at(raw_line, 0)
  [col, row] = Enum.at(raw_line, 2)
               |> String.split(",")
  row  = String.replace(row, ":", "")
         |> String.to_integer
  col = col
        |> String.to_integer
  [width, height] =  Enum.at(raw_line, 3)
                     |> String.split("x")

  width  = String.to_integer(width)
  height = String.to_integer(height)
  Claims.fill(acc, label, row, col, width, height, width-1, height-1)
end)
|> Enum.filter(fn {_k,v} -> v == "#" end)
|> Enum.count()
|> IO.inspect



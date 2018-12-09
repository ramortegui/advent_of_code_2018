defmodule Day4 do
  import NimbleParsec

  def input do
    ~S"""
    [1518-11-01 00:05] falls asleep
    [1518-11-01 00:00] Guard #10 begins shift
    [1518-11-01 00:25] wakes up
    [1518-11-01 00:30] falls asleep
    [1518-11-01 00:55] wakes up
    [1518-11-01 23:58] Guard #99 begins shift
    [1518-11-02 00:40] falls asleep
    [1518-11-02 00:50] wakes up
    [1518-11-03 00:05] Guard #10 begins shift
    [1518-11-03 00:24] falls asleep
    [1518-11-03 00:29] wakes up
    [1518-11-04 00:02] Guard #99 begins shift
    [1518-11-04 00:36] falls asleep
    [1518-11-04 00:46] wakes up
    [1518-11-05 00:03] Guard #99 begins shift
    [1518-11-05 00:45] falls asleep
    [1518-11-05 00:55] wakes up
    """
  end

  def parse_line(line) when is_binary(line) do
    line
    |> get_data()
  end

  @doc ~S"""
  Returns structure

  ## Examples

    iex> Day4.get_data("[1518-11-01 00:00] wakes up")
    {"1518-11-01 00:00:00", nil, :up}
    iex> Day4.get_data("[1518-11-01 00:00] falls asleep")
    {"1518-11-01 00:00:00", nil, :down}
    iex> Day4.get_data("[1518-11-01 00:00] Guard #100 begins shift")
    {"1518-11-01 00:00:00", 100, :start}
  """
  def get_data(line) when is_binary(line) do
    case record(line) do
      {:ok, [year, month, day, hour, minute, "wakes up"], _, _, _, _} ->
        date = format_date(year,month,day,hour,minute)
        {date, nil, :up}
      {:ok, [year, month, day, hour, minute, "falls asleep"], _, _, _, _} ->
        date = format_date(year,month,day,hour,minute)
        {date, nil, :down}
      {:ok, [year, month, day, hour, minute, guard, "begins shift"], _, _, _, _} ->
        date = format_date(year,month,day,hour,minute)
        {date, guard, :start}
      x -> IO.inspect x; :error
    end
  end

  defp format_date(year, month, day, hour, minute) do
    "#{year}-#{complete_data(month)}-#{complete_data(day)} #{complete_data(hour)}:#{complete_data(minute)}:00"
  end

  defp complete_data(data) do
    String.slice("00#{data}",-2..-1)
  end

  def record_structure(structure) when is_binary(structure) do
    structure
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce([],fn(data, acc) -> [Day4.get_data(data) | acc] end)
    |> Enum.sort(fn(data1, data2) ->
      {:ok, date1} = NaiveDateTime.from_iso8601(elem(data1,0))
      {:ok, date2} = NaiveDateTime.from_iso8601(elem(data2,0))
      NaiveDateTime.diff(date1, date2) < 0
    end)
    |> Enum.reduce({[],0}, fn({date, guard, action}, {list, new_guard} ) ->
      if(guard == nil || guard == 0) do
        guard = new_guard
        {[{date, guard, action} | list], guard}
      else
        {[{date, guard, action} | list], guard}
      end
    end)
    |> remove_guard()
    |> Enum.reject(&(elem(&1, 2) == :start))
    |> group_by_id_ranges(%{})
    |> Enum.max_by(fn(x) -> elem(x,1)|>Map.get(:count)  end)
    |> get_best_minute()

  end

  defp get_best_minute({guard, structure}) do
    {minute, _qty} = Enum.max_by(structure.range, fn(x) -> elem(x,1) end)
    guard * minute
  end

  defp group_by_id_ranges([], acc) do
    acc
  end

  defp group_by_id_ranges([{init, guard, :down}, {init2, guard, :up}| tail], acc) do
      {:ok, init} = NaiveDateTime.from_iso8601(init)
      {:ok, init2} = NaiveDateTime.from_iso8601(init2)
    case Map.get(acc, guard) do
      nil ->
        group_by_id_ranges(tail, Map.put(acc, guard,%{
          range: Enum.reduce(init.minute..init2.minute, %{}, fn(x,acc) ->
            Map.put(acc, x, 1)
          end),
          count: (Enum.count(init.minute..init2.minute)-1)}))
      exists ->
        range = Enum.reduce(init.minute..init2.minute, exists.range, fn x, racc ->
          Map.update(racc,x, 1, fn(x) -> x+1 end)
        end)
        count = exists.count+(Enum.count(init.minute..init2.minute)-1)

        group_by_id_ranges(tail, Map.update(acc, guard, exists,
          fn(_x) ->
          %{
            range: range,
            count:  count
          } end))
    end
  end

  defp remove_guard({list, _guard}), do: list |> Enum.reverse()

  integer1 =
    integer(1)

  integer2 =
    integer(2)

  integer3 =
    integer(3)

  integer4 =
    integer(4)

  begins =
    ignore(string("Guard #"))
    |> choice([integer4, integer3, integer2, integer1])
    |> ignore(string(" "))
    |> string("begins shift")

  asleep =
    string("falls asleep")

  wakes =
    string("wakes up")

  record =
    ignore(string("["))
    |> integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string(" "))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string("] "))
    |> choice([begins, asleep, wakes])


  defparsec :record, record
end

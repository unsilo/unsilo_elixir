defmodule Unsilo.Places.Series.NestHeat do
  use Instream.Series

  alias Unsilo.Places.Series.NestHeat

  @data_fields ~w(
    date
    time
    avg_temp
    avg_humidity
    max_pir
    max_nearPir
    min_ch1
    max_ch1
    min_ch2
    max_ch2
    min_als
    max_als
    min_tp0
    max_tp0
    min_tp1
    max_tp1
    min_tp2
    max_tp2
    min_tp3
    max_tp3
  )a

  series do
    database("unsilo_influx_database")
    measurement("nest_thermostat")

    tag(:uuid)

    field :avg_temp, default: 0
    field :avg_humidity, default: 0
  end

  def import(path) do
    path
    |> File.ls!()
    |> Enum.filter(&File.dir?(Path.join(path, &1)))
    |> Enum.each(&import_uid(&1, path))
  end

  def import_single(path) do
    path
    |> File.ls!()
    |> Enum.filter(&File.dir?(Path.join(path, &1)))
    |> Enum.each(&import_uid(&1, path))
  end

  def query(qry) do
    Unsilo.InfluxConnection.query(qry, database: "unsilo_influx_database")
  end

  def clear do
    %{results: [%{series: [%{values: dates}]}]} = 
      Unsilo.InfluxConnection.query("", database: "unsilo_influx_database")
  end

  def get_earliest do
    %{results: [%{series: [%{values: [[date, _temp]]}]}]} = 
      query("SELECT FIRST(\"avg_temp\") FROM \"nest_thermostat\"")

    Timex.parse!(date, "{RFC3339}")
  end

  def get_latest do
    %{results: [%{series: [%{values: [[date, _temp]]}]}]} = 
      query("SELECT LAST(\"avg_temp\") FROM \"nest_thermostat\"")

    Timex.parse!(date, "{RFC3339}")
  end

  def get_uuids do
    %{results: [%{series: uuid_data}]} = 
      query("SELECT COUNT(\"avg_temp\") FROM \"nest_thermostat\" GROUP BY \"uuid\"")
      |> IO.inspect

    Enum.reduce( uuid_data, %{}, fn %{tags: %{uuid: uuid}, values: [[_, count]]}, acc -> Map.put(acc, uuid, count) end)
  end

  defp import_uid(uid, path) do
    path = Path.join(path, uid)

    path
    |> File.ls!()
    |> Enum.filter(&File.dir?(Path.join(path, &1)))
    |> Enum.each(&import_year(&1, uid, path))
  end

  defp import_year(year, uid, path) do
    path = Path.join(path, year)

    path
    |> File.ls!()
    |> Enum.filter(&File.dir?(Path.join(path, &1)))
    |> Enum.flat_map(&import_month(&1, year, uid, path))
    |> do_write()
  end

  defp import_month(month, year, uid, path) do
    name = "#{year}-#{month}-sensors.csv"
    path = Path.join(path, month)
    path = Path.join(path, name)

    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.map(&import_line(&1, uid))
    |> Enum.reject(&is_nil(&1))
  end

  defp do_write([]) do
    IO.puts("writing an empty array")
  end

  defp do_write(nil) do
    IO.puts("writing a nil array")
  end

  defp do_write(list) do
    Unsilo.InfluxConnection.write(list)
  end

  defp import_line("Date,Time,avg(temp)" <> _rest, uid) do
    nil
  end

  defp import_line(line, uid) do
    line
    |> String.split(",")
    |> Enum.zip(@data_fields)
    |> Enum.reduce(%{}, fn {v, k}, a -> Map.put(a, k, v) end)
    |> make_struct(uid)
  end

  defp make_struct(%{date: date, time: time} = data, uuid) do
    timestamp =
      "#{date} #{time} -0400"
      |> Timex.parse!("%Y-%m-%d %H:%M %Z", :strftime)
      |> Timex.format!("{s-epoch}")
      |> String.to_integer()

    heat_data =
      data
      |> Map.take([:avg_humidity, :avg_temp])
      |> Map.put(:timestamp, timestamp * 1000000000)
      |> Map.put(:time, timestamp * 1000000000)
      |> convert_to_struct(uuid, data)
  end

  defp convert_to_struct(heat_data, uuid, %{avg_temp: avg_temp, avg_humidity: avg_humidity}) when (avg_temp != "" and avg_humidity != "")  do
    heat_data = heat_data
    |> Map.put(:avg_humidity, String.to_float(avg_humidity))
    |> Map.put(:avg_temp, String.to_float(avg_temp))
    |> NestHeat.from_map()

    %{heat_data | tags: %{heat_data.tags | uuid: uuid}}
  end

  defp convert_to_struct(_heat_data, _uuid, _data) do
    nil
  end

end

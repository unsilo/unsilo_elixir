defmodule Unsilo.Places.Device.NestHeat do
  use Instream.Series

  alias Unsilo.Places.Device.NestHeat

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
    measurement("avg_temp")
    measurement("avg_humidity")

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
    |> Enum.each(&import_month(&1, year, uid, path))
  end

  defp import_month(month, year, uid, path) do
    name = "#{year}-#{month}-sensors.csv"
    path = Path.join(path, month)
    path = Path.join(path, name)

    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&import_line(&1, uid))
    |> Stream.run()
  end

  defp import_line("Date,Time,avg(temp)" <> _rest, uid) do
  end

  defp import_line(line, uid) do
    line
    |> String.split(",")
    |> Enum.zip(@data_fields)
    |> Enum.reduce(%{}, fn {v, k}, a -> Map.put(a, k, v) end)
    |> make_struct(uid)
  end

  defp make_struct(%{date: date, time: time} = data, uuid) do
    time =
      "#{date} #{time} -0400"
      |> Timex.parse!("%Y-%m-%d %H:%M %Z", :strftime)

    heat_data =
      data
      |> Map.take([:avg_humidity, :avg_temp])
      |> Map.put(:timestamp, time)
      |> NestHeat.from_map()

    heat_data =
      %{heat_data | tags: %{heat_data.tags | uuid: uuid}}
      |> Unsilo.InfluxConnection.write()
  end
end

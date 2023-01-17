defmodule Apps do
  @moduledoc """
  Documentation for `Apps`.
  """

  @doc """
  Hello world.

  ## Examples shaurya

      iex> Apps.hello() {:ok, xmldoc} = File.read(Path.expand("D:/Cognizant/files/records.xml"))
      :world

  """

  def read_file(path, format) do
    File.stream!("D:/Cognizant/files/records.csv",  [{:binaries, :as_strings}])
      |> Stream.map(&String.trim(&1))
      |> Stream.map(&String.split(&1, ","))
      |> Enum.map( fn val -> IO.inspect(val) end )
  end
  def hello do
    :world
  end
end

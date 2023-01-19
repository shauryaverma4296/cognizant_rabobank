defmodule Apps.Server do

  use GenServer
  @moduledoc """
  Heart of the application, which gets start when the server is up.
  """
  @formatted_name "final"
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    IO.puts("Starting Rabobank Customer Statement Processor")
    start_background_jobs()
    {:ok, state}
  end

  def handle_info(:fetch, state) do
    files_found = Path.wildcard("./files/*")
    files = Enum.filter(files_found, fn file -> !String.contains?(file, @formatted_name) end)

    if !Enum.empty?(files) do
      if Enum.count(files) != Enum.count(state) do
        GenServer.cast(self(), {:new_files_found, files})

        # Enum.map(files, &validate_file_data?(&1))
      end
    else
      Logger.info("No files found.")
    end
    start_background_jobs()

    # record_list = Apps.generate_report()

    # GenServer.cast(self(), {:new_files_found, files})
    # fetch_after_interval()
    {:noreply, state}
  end

  def handle_cast({:new_files_found, files}, state) do
    Apps.generate_report(files)
    {:noreply, files}
  end

  defp start_background_jobs() do
    # Application.get_env(:cbs_eng, :interval)
    Process.send_after(self(), :fetch, 5000)
  end

end

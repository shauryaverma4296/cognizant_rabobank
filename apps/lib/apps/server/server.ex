defmodule Apps.Server do

  use GenServer
  require Logger
  @moduledoc """
  Heart of the application, which gets start when the server is up.
  """
  @formatted_name "final"
  @invocation_interval 5000
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    Logger.info("Starting Rabobank Customer Statement Processor")
    Logger.info("Genserver is spinning up")
    Logger.info("Background job is staring")
    start_background_jobs()
    Logger.info("Background job is started")
    {:ok, state}
  end

  def handle_info(:fetch, state) do
    files_found = Path.wildcard("./files/*")
    files = Enum.filter(files_found, fn file -> !String.contains?(file, @formatted_name) end)

    if !Enum.empty?(files) do
      if Enum.count(files) != Enum.count(state) do
        Logger.info("New files found")
        GenServer.cast(self(), {:new_files_found, files})
        Logger.info("Sending files to generate the reports")
      else
        Logger.info("No new files are found.")
      end
    else
      Logger.info("No files found.")
    end

    start_background_jobs()
    {:noreply, state}
  end

  def handle_cast({:new_files_found, files}, state) do

    Logger.info("Files received :ok")
    Apps.generate_report(files)
    {:noreply, files}
  end

  defp start_background_jobs() do
    # Application.get_env(:cbs_eng, :interval)
    Process.send_after(self(), :fetch, @invocation_interval)
    Logger.info("Server is listening to the directory: './files/' for every #{@invocation_interval}ms")
  end

end

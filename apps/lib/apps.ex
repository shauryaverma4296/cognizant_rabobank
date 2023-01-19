defmodule Apps do
  # use CSV
  require Logger

  @moduledoc """
  Documentation for `Apps`.
  """
  @extension_whitelist ~w(.csv .xml)
  @header ~w(accountNumber description endBalance mutation reason reference startBalance)
  @formatted_name "final"

  defp get_ext(file) do
    file
    |> Path.extname()
    |> String.downcase()
  end

  def get_file_name(file) do
    file
    |> Path.basename()
    |> String.split(".")
    |> List.first()
  end

  @spec validate_files?(
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | char,
              binary | []
            )
        ) :: boolean
  def validate_files?(file) do
    file_extension = get_ext(file)

    @extension_whitelist
    |> Enum.member?(file_extension)
  end

  @spec validate_file_data?(
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | char,
              binary | []
            )
        ) :: nil | :ok | list
  def validate_file_data?(file) do
    #  for every file this fn will execute
    if validate_files?(file) do
      file_extension = file |> get_ext()

      # get file data
      raw_data =
        file
        |> get_raw_data(file_extension)

      # create a generic data to apply bussiness logic

      duplicate_reference_ids =
        Enum.map(
          Enum.filter(raw_data, fn x ->
            Enum.count(raw_data, &(&1.reference == x.reference)) > 1
          end),
          & &1.reference
        )

      # apply bussiness logic

      data_with_error =
        raw_data
        |> validate_end_balance()
        |> validate_unique_refernce(duplicate_reference_ids)
        |> get_error_data_set()

      # create new file with error data

      file_path = "./files/" <> get_file_name(file) <> @formatted_name <> file_extension

      case file_extension do
        ".csv" ->
          Logger.info("Writing #{file_extension} data")

          data_to_render =
            data_with_error
            |> conver_keys_to_string()
            |> convert_binary_string_in_list()

          file_to_write = File.open!(file_path, [:write, :utf8])

          data_to_render |> CSV.encode() |> Enum.each(&IO.write(file_to_write, &1))

          File.close(file_to_write)

          Logger.info("#{file_path} is ready with the data")

        ".xml" ->
          Logger.info("Writing #{file_extension} data")

          xml_data_impure =
            Enum.map(data_with_error, fn xml_data -> MapToXml.from_map(xml_data) end)

          second_element = xml_data_impure |> Enum.at(1)

          new_second_element =
            String.replace(second_element, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "")

          pure_xml = List.replace_at(xml_data_impure, 1, new_second_element)

          pure_xml_string = pure_xml |> Enum.join(",")

          File.write(file_path, pure_xml_string)

          Logger.info("Finished writing #{file_extension} data")
          Logger.info("#{file_path} is ready with the data")

        _ ->
          Logger.info("The extension is not supported")
      end
    else
      Logger.info("File Extension not supported")
    end
  end

  def conver_keys_to_string(list) do
    Enum.reduce(
      list,
      [[Atom.to_string(:reference), Atom.to_string(:description), Atom.to_string(:reason)]],
      fn x, acc -> acc ++ [[x[:reference], x[:description], x[:reason]]] end
    )
  end

  @spec validate_end_balance(any) :: list
  def validate_end_balance(list) do
    # check duplicate reference &&     Enum.member?(target_ids, x.id)
    reason = "The end balance is not correct"

    filtered_maps =
      Enum.map(list, fn data_set ->
        {start_balance, ""} = Float.parse(Map.get(data_set, :startBalance))
        {mutation, ""} = Float.parse(Map.get(data_set, :mutation))
        {end_balance, ""} = Float.parse(Map.get(data_set, :endBalance))

        sum = Float.round(Float.round(start_balance, 2) + Float.round(mutation, 2), 2)

        if sum != end_balance do
          Map.put(data_set, :reason, reason)
        else
          data_set
        end
      end)

    filtered_maps
  end

  @spec validate_unique_refernce(any, any) :: list
  def validate_unique_refernce(list, duplicate_reference_ids) do
    Enum.map(list, fn data_set ->
      if Enum.member?(duplicate_reference_ids, data_set.reference) do
        reason = "Reference number is not unique"

        if Map.has_key?(data_set, :reason) do
          modified_reason = "#{Map.get(data_set, :reason)} and #{reason}"
          Map.put(data_set, :reason, modified_reason)
        else
          Map.put(data_set, :reason, reason)
        end
      else
        data_set
      end
    end)
  end

  @spec get_error_data_set(any) :: list
  def get_error_data_set(data_set) do
    Enum.filter(data_set, fn map -> Map.has_key?(map, :reason) end)
  end

  @spec get_raw_data(any, any) :: :ok | list | {:error, Saxy.ParseError.t()} | {:ok, map}
  def get_raw_data(file, ".csv") do
    stream_data = CSV.decode(File.stream!(file), headers: true) |> Enum.to_list()

    stream_data
    |> generic_data_csv()
  end

  def get_raw_data(file, ".xml") do
    {:ok, xmldoc} = File.read(Path.expand(file))
    stream_data = SAXMap.from_string(xmldoc, ignore_attribute: false)

    stream_data
    |> generic_data_xml()
  end

  def get_raw_data(_, ext) do
    Logger.info("#{ext} is not supported. Please provide the csv or xml files.")
  end

  # @spec get_generic_data(map, ext) :: map
  @spec get_generic_data(map, any) :: map
  def get_generic_data(val, ext) do
    keys = Map.keys(val)

    alter_key =
      case ext do
        ".csv" -> keys |> Enum.map(&first_letter_small/1)
        _ -> keys
      end

    bind_key = alter_key |> Enum.map(&String.to_atom/1)

    values = Map.values(val)
    converted_map = Enum.zip(bind_key, values) |> Map.new()
    converted_map
  end

  @spec generic_data_csv(any) :: list
  def generic_data_csv(raw_data) do
    Enum.map(raw_data, fn {:ok, val} -> get_generic_data(val, ".csv") end)
  end

  @spec generic_data_xml({:ok, map}) :: list
  def generic_data_xml({:ok, records}) do
    %{"records" => %{"content" => record}} = records
    %{"record" => raw_data} = record

    xml_data =
      Enum.map(raw_data, fn val -> val |> transform_data() |> get_generic_data(".xml") end)

    xml_data
  end

  @spec transform_data(any) :: any
  def transform_data(xml_data) do
    Enum.reduce(xml_data, %{}, fn {key, value}, acc ->
      case key do
        "content" ->
          Enum.reduce(value, acc, fn {key, %{"content" => content}}, acc ->
            Map.put(acc, key, content)
          end)

        _ ->
          Map.put(acc, key, value)
      end
    end)
  end

  @spec first_letter_small(binary) :: binary
  def first_letter_small(string) do
    first_letter = String.first(string)

    rest_of_string = String.slice(string, 1..String.length(string))
    downcased_first_letter = String.downcase(first_letter)
    rest_of_string_without_space = Regex.replace(~r/\s+/, rest_of_string, "")
    downcased_first_letter <> rest_of_string_without_space
  end

  def raw_binary_to_string(raw) do
    codepoints = String.codepoints(raw)

    val =
      Enum.reduce(
        codepoints,
        fn w, result ->
          cond do
            String.valid?(w) ->
              result <> w

            true ->
              <<parsed::8>> = w
              result <> <<parsed::utf8>>
          end
        end
      )

    val
  end

  def convert_binary_string_in_list(list) do
    list =
      Enum.map(list, fn row ->
        Enum.map(row, fn item ->
          case item do
            binary when is_binary(binary) -> raw_binary_to_string(binary)
            _ -> item
          end
        end)
      end)
    list
  end

  @spec generate_report :: :ok | list
  def generate_report() do
    #  get all files within a dir

    files_found = Path.wildcard("./files/*")
    files = Enum.filter(files_found, fn file -> !String.contains?(file, @formatted_name) end)

    if Enum.empty?(files) do
      Logger.info("No files found.")
    else
      Enum.map(files, &validate_file_data?(&1))
    end
  end
end

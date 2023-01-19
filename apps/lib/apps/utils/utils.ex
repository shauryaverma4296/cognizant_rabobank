defmodule Apps.Utils do
  @moduledoc """
  A Utility module to ease your life during development
  """

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

  def get_ext(file) do
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

  @spec first_letter_small(binary) :: binary
  def first_letter_small(string) do
    first_letter = String.first(string)

    rest_of_string = String.slice(string, 1..String.length(string))
    downcased_first_letter = String.downcase(first_letter)
    rest_of_string_without_space = Regex.replace(~r/\s+/, rest_of_string, "")
    downcased_first_letter <> rest_of_string_without_space
  end

end

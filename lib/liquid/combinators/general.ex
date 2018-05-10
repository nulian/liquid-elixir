defmodule Liquid.Combinators.General do
  @moduledoc """
  General purpose combinators used by almost every other combinator
  """
  import NimbleParsec

  # Codepoints
  @horizontal_tab 0x0009
  @space 0x0020
  @colon 0x003A
  @point 0x002E
  @comma 0x002C
  @apostrophe 0x0027
  @quote 0x0022
  @question_mark 0x003F
  @underscore 0x005F
  @dash 0x002D
  @start_tag "{%"
  @end_tag "%}"
  @start_variable "{{"
  @end_variable "}}"
  @digit ?0..?9
  @uppercase_letter ?A..?Z
  @lowercase_letter ?a..?z

  def codepoints do
    %{
      horizontal_tab: @horizontal_tab,
      space: @space,
      colon: @colon,
      point: @point,
      comma: @comma,
      quote: @quote,
      apostrophe: @apostrophe,
      question_mark: @question_mark,
      underscore: @underscore,
      start_tag: @start_tag,
      end_tag: @end_tag,
      start_variable: @start_variable,
      end_variable: @end_variable,
      digit: @digit,
      uppercase_letter: @uppercase_letter,
      lowercase_letter: @lowercase_letter
    }
  end

  @doc """
  Horizontal Tab (U+0009) + Space (U+0020)
  """
  def whitespace do
    ascii_char([
      @horizontal_tab,
      @space
    ])
  end

  @doc """
  Remove all :whitespace
  """
  def ignore_whitespaces do
    whitespace()
    |> repeat()
    |> ignore()
  end

  @doc """
  Comma without spaces
  """
  def cleaned_comma do
    ignore_whitespaces()
    |> concat(ascii_char([@comma]))
    |> concat(ignore_whitespaces())
    |> ignore()
  end

  @doc """
  Start of liquid Tag
  """
  def start_tag do
    concat(
      string(@start_tag),
      ignore_whitespaces()
    )
    |> ignore()
  end

  @doc """
  End of liquid Tag
  """
  def end_tag do
    ignore_whitespaces()
    |> concat(string(@end_tag))
    |> ignore()
  end

  @doc """
  Start of liquid Variable
  """
  def start_variable do
    concat(
      string(@start_variable),
      ignore_whitespaces()
    )
    |> ignore()
  end

  @doc """
  End of liquid Variable
  """
  def end_variable do
    ignore_whitespaces()
    |> string(@end_variable)
    |> ignore()
  end

  @doc """
  All utf8 valid characters or empty limited by start/end of tag/variable
  """
  def literal do
    empty()
    |> repeat_until(utf8_char([]), [
      string(@start_variable),
      string(@end_variable),
      string(@start_tag),
      string(@end_tag)
    ])
    |> reduce({List, :to_string, []})
  end

  defp restricted_chars do
    [
      @digit,
      @uppercase_letter,
      @lowercase_letter,
      @underscore,
      @dash
    ]
  end

  @doc """
  Valid variable name represented by:
  optional utf8 valid character, except point or whitespace plus
  [A..Z, a..z, 0..9, _, -] (mandatory)
  """
  def variable_definition do
    empty()
    |> concat(ignore_whitespaces())
    |> optional(
      repeat_until(utf8_char([]), [
        utf8_char(restricted_chars()),
        utf8_char([@point]),
        utf8_char([@space])
      ])
    )
    |> concat(times(utf8_char(restricted_chars()), min: 1))
    |> concat(ignore_whitespaces())
    |> reduce({List, :to_string, []})
  end

  def variable_name do
    parsec(:variable_definition)
    |> unwrap_and_tag(:variable_name)
  end

  def liquid_variable do
    start_variable()
    |> concat(variable_name())
    |> concat(end_variable())
    |> tag(:variable)
    |> optional(parsec(:__parse__))
  end

  def single_quoted_token do
    parsec(:ignore_whitespaces)
    |> concat(utf8_char([@apostrophe]) |> ignore())
    |> concat(repeat(utf8_char(not: @comma, not: @apostrophe)))
    |> concat(parsec(:ignore_whitespaces))
    |> concat(utf8_char([@apostrophe]) |> ignore())
    |> concat(parsec(:ignore_whitespaces))
  end

  def double_quoted_token do
    parsec(:ignore_whitespaces)
    |> concat(ascii_char([?"]))
    |> concat(repeat(utf8_char(not: @comma, not: @quote)))
    |> concat(ascii_char([?"]))
    |> reduce({List, :to_string, []})
    |> concat(parsec(:ignore_whitespaces))
  end

  def token do
    choice([double_quoted_token(), single_quoted_token()])
  end
end
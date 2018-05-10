defmodule Liquid.NimbleParser do
  @moduledoc """
  Transform a valid liquid markup in an AST to be executed by `render`
  """
  import NimbleParsec

  alias Liquid.Combinators.{General, LexicalTokens}

  alias Liquid.Combinators.Tags.{
    Assign,
    Comment,
    Decrement,
    Increment,
    Include,
    Raw,
    Cycle
  }

  defparsec(:liquid_variable, General.liquid_variable())
  defparsec(:variable_definition, General.variable_definition())
  defparsec(:variable_name, General.variable_name())
  defparsec(:start_tag, General.start_tag())
  defparsec(:end_tag, General.end_tag())
  defparsec(:single_quoted_token, General.single_quoted_token())
  defparsec(:double_quoted_token, General.double_quoted_token())
  defparsec(:token, General.token())
  defparsec(:ignore_whitespaces, General.ignore_whitespaces())

  defparsec(:number, LexicalTokens.number())
  defparsec(:value_definition, LexicalTokens.value_definition())
  defparsec(:value, LexicalTokens.value())
  defparsec(:list_value, LexicalTokens.list_value())

  defparsec(
    :__parse__,
    General.literal()
    |> optional(choice([parsec(:liquid_tag), parsec(:liquid_variable)]))
  )

  defparsec(:assign, Assign.tag())

  defparsec(:decrement, Decrement.tag())

  defparsec(:increment, Increment.tag())

  defparsecp(:open_tag_comment, Comment.open_tag())
  defparsecp(:close_tag_comment, Comment.close_tag())
  defparsecp(:not_close_tag_comment, Comment.not_close_tag_comment())
  defparsecp(:comment_content, Comment.comment_content())
  defparsec(:comment, Comment.tag())

  defparsec(:cycle_group, Cycle.cycle_group())
  defparsec(:last_cycle_value, Cycle.last_cycle_value())
  defparsec(:cycle_values, Cycle.cycle_values())
  defparsec(:cycle, Cycle.tag())

  defparsec(:open_tag_raw, Raw.open_tag())
  defparsec(:close_tag_raw, Raw.close_tag())
  defparsecp(:not_close_tag_raw, Raw.not_close_tag_raw())
  defparsec(:raw_content, Raw.raw_content())
  defparsec(:raw, Raw.tag())

  defparsecp(:snippet_var, Include.snippet_var())
  defparsec(:variable_atom, Include.variable_atom())
  defparsecp(:var_assignation, Include.var_assignation())
  defparsecp(:with_param, Include.with_param())
  defparsecp(:for_param, Include.for_param())
  defparsec(:include, Include.tag())

  defparsec(
    :liquid_tag,
    choice([
      parsec(:assign),
      parsec(:increment),
      parsec(:decrement),
      parsec(:include),
      parsec(:cycle),
      parsec(:raw),
      parsec(:comment)
    ])
  )

  @doc """
  Valid and parse liquid markup.
  """
  @spec parse(String.t()) :: {:ok | :error, any()}
  def parse(""), do: {:ok, ""}

  def parse(markup) do
    case __parse__(markup) do
      {:ok, template, "", _, _, _} ->
        {:ok, template}

      {:ok, _, rest, _, _, _} ->
        {:error, "Error parsing: #{rest}"}
    end
  end
end
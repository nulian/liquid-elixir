defmodule Liquescent.Render do
  alias Liquescent.Variables, as: Variables
  alias Liquescent.Templates, as: Templates
  alias Liquescent.Registers, as: Registers
  alias Liquescent.Context, as: Context
  alias Liquescent.Blocks, as: Blocks
  alias Liquescent.Tags, as: Tags

  def render(%Templates{root: root}, %Context{}=context) do
    { output, context } = render([], root, context)
    { :ok, Enum.join(output), context }
  end

  def render(output, [], %Context{}=context) do
    { output, context }
  end
  def render(output, [h|t], %Context{}=context) do
    { output, context } = render(output, h, context)
    case context do
      %Context{extended: false, break: false, continue: false} -> render(output, t, context)
      _ -> render(output, [], context)
    end
  end

  def render(output, <<text::binary>>, %Context{}=context) do
    { output ++ [text], context }
  end

  def render(output, %Variables{}=v, %Context{}=context) do
    { rendered, context } = Variables.lookup(v, context)
    { output ++ [rendered], context }
  end

  def render(output, %Tags{name: name}=tag, %Context{}=context) do
    { mod, Tags } = Registers.lookup(name)
    mod.render(output, tag, context)
  end

  def render(output, %Blocks{name: name}=block, %Context{}=context) do
    case Registers.lookup(name) do
      { mod, Blocks } -> mod.render(output, block, context)
      nil -> render(output, block.nodelist, context)
    end
  end

end
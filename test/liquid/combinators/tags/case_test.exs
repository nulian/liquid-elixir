defmodule Liquid.Combinators.Tags.CaseTest do
  use ExUnit.Case

  import Liquid.Helpers
  alias Liquid.NimbleParser, as: Parser

  test "case using multiples when" do
    test_combinator(
      "{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}",
      &Parser.case/1,
      case: [
        variable: [parts: [part: "condition"]],
        clauses: [
          when: [statements: [1], value_if_true: [" its 1 "]],
          when: [statements: [2], value_if_true: [" its 2 "]]
        ]
      ]
    )
  end

  test "case using a single when" do
    test_combinator(
      "{% case condition %}{% when \"string here\" %} hit {% endcase %}",
      &Parser.case/1,
      case: [
        variable: [parts: [part: "condition"]],
        clauses: [
          when: [statements: ["string here"], value_if_true: [" hit "]]
        ]
      ]
    )
  end

  test "evaluate variables and expressions" do
    test_combinator(
      "{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}",
      &Parser.case/1,
      case: [
        variable: [parts: [part: "a", part: "size"]],
        clauses: [
          when: [statements: [1], value_if_true: ["1"]],
          when: [statements: [2], value_if_true: ["2"]]
        ]
      ]
    )
  end

  test "case with a else tag" do
    test_combinator(
      "{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}",
      &Parser.case/1,
      case: [
        variable: [parts: [part: "condition"]],
        clauses: [when: [statements: [5], value_if_true: [" hit "]]],
        else: [" else "]
      ]
    )
  end

  test "when tag with an or condition" do
    test_combinator(
      "{% case condition %}{% when 1 or 2 or 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}",
      &Parser.case/1,
      case: [
        variable: [parts: [part: "condition"]],
        clauses: [
          when: [
            statements: [1, {:logical, [:or, 2]}, {:logical, [:or, 3]}],
            value_if_true: [" its 1 or 2 or 3 "]
          ],
          when: [statements: [4], value_if_true: [" its 4 "]]
        ]
      ]
    )
  end

  test "when with comma's" do
    test_combinator(
      "{% case condition %}{% when 1, 2, 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}",
      &Parser.case/1,
      case: [
        variable: [parts: [part: "condition"]],
        clauses: [
          when: [
            statements: [1, {:logical, [:or, 2]}, {:logical, [:or, 3]}],
            value_if_true: [" its 1 or 2 or 3 "]
          ],
          when: [statements: [4], value_if_true: [" its 4 "]]
        ]
      ]
    )
  end

  test "when tag separated by commas and with different values" do
    test_combinator(
      "{% case condition %}{% when 1, \"string\", null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}",
      &Parser.case/1,
      case: [
        variable: [parts: [part: "condition"]],
        clauses: [
          when: [
            statements: [
              1,
              {:logical, [:or, "string"]},
              {:logical, [:or, nil]}
            ],
            value_if_true: [" its 1 or 2 or 3 "]
          ],
          when: [statements: [4], value_if_true: [" its 4 "]]
        ]
      ]
    )
  end

  test "when tag with assign tag" do
    test_combinator(
      "{% case collection.handle %}{% when 'menswear-jackets' %}{% assign ptitle = 'menswear' %}{% when 'menswear-t-shirts' %}{% assign ptitle = 'menswear' %}{% else %}{% assign ptitle = 'womenswear' %}{% endcase %}",
      &Parser.case/1,
      case: [
        variable: [parts: [part: "collection", part: "handle"]],
        clauses: [
          when: [
            statements: ["menswear-jackets"],
            value_if_true: [
              assign: [
                variable_name: "ptitle",
               
                value: "menswear"
              ]
            ]
          ],
          when: [
            statements: ["menswear-t-shirts"],
            value_if_true: [
              assign: [
                variable_name: "ptitle",
               
                value: "menswear"
              ]
            ]
          ]
        ],
        else: [
          assign: [
            variable_name: "ptitle",
           
            value: "womenswear"
          ]
        ]
      ]
    )
  end

  test "bad formed cases" do
    test_combinator_error(
      "{% case condition %}{% when 5 %} hit {% else %} else endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{% case condition %}{% when 5 %} hit {% else %} else {% endcas %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{ case condition %}{% when 5 %} hit {% else %} else {% endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "case condition %}{% when 5 %} hit {% else %} else {% endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{% casa condition %}{% when 5 %} hit {% else %} else {% endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{% case condition %}{% when 5 5 %} hit {% else %} else {% endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{% case condition %}{% when 5  %} hit {% els %} else {% endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{% case condition %}{% whene 5 %} hit {% else %} else {% endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{% case condition %}{% when 5 or %} hit {% else %} else {% endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{% case condition %}{% when 5  hit {% else %} else {% endcase %}",
      &Parser.case/1
    )

    test_combinator_error(
      "{% case condition condition condition2 %}{% when 5 %} hit {% else %} else {% endcase %}",
      &Parser.case/1
    )
  end
end

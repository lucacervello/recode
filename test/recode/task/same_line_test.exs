defmodule Recode.Task.SameLineTest do
  use RecodeCase

  alias Recode.Task.SameLine

  defp run(code, opts \\ []) do
    code |> source() |> run_task({SameLine, opts})
  end

  test "formats maps" do
    code = """
    %{
      foo: 42
    }
    """

    expected = """
    %{foo: 42}
    """

    %{
      foo: 42
    }

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "keeps format for single line map" do
    code = """
    %{foo: 42}
    """

    source = run(code)

    assert source.code == code
  end

  test "keeps format for a big map" do
    code = """
    %{
      foo: 42,
      foobar: 42,
      foobarbaz: 42,
      foobarbazbang: 42,
      foobarbazbangbuz: 42,
      foobarbazbangbuzwurz: 42,
      foobarbazbangbuzwurzumsel: 42
    }
    """

    source = run(code)

    assert formated?(code)
    assert source.code == code
  end

  test "formats list" do
    code = """
    [
      :a,
      :b,
      :c
    ]
    """

    expected = """
    [:a, :b, :c]
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "formats multiline and" do
    code = """
    true and
      false and
      x
    """

    expected = """
    true and false and x
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "formats multiline operators" do
    code = """
    1 +
      2 -
      3 /
        4 *
        5 +
      6
    """

    expected = """
    1 + 2 - 3 / 4 * 5 + 6
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "formats def" do
    code = """
    def foo(
          x,
          y
        ) do
      {
        x,
        y
      }
    end
    """

    expected = """
    def foo(x, y) do
      {x, y}
    end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "formats defp with when" do
    code = """
    defp foo(x, y)
         when is_integer(x) do
      {x, y}
    end
    """

    expected = """
    defp foo(x, y) when is_integer(x) do
      {x, y}
    end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "formats def in module" do
    code = """
    defmodule MyCode.SameLine do
      def foo(x)
          when is_integer(x) do
        {
          :foo,
          x
        }
      end
    end
    """

    expected = """
    defmodule MyCode.SameLine do
      def foo(x) when is_integer(x) do
        {:foo, x}
      end
    end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "keeps with" do
    code = """
    with {:ok, a} <- foo(x),
         {:ok, b} <- bar(x) do
      {a, b}
    end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == code
  end

  test "formats with clauses" do
    code = """
    with {:ok, a} <-
           foo(x),
         {:ok, b} <-
           bar(x) do
      {a, b}
    end
    """

    expected = """
    with {:ok, a} <- foo(x),
         {:ok, b} <- bar(x) do
      {a, b}
    end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "keeps case" do
    code = """
    case x do
      :foo -> {:foo, x}
      :bar -> {:bar, x}
    end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == code
  end

  test "formats case clauses" do
    code = """
    case x do
      :foo ->
        {:foo, x}

      :bar ->
        {:bar, x}
    end
    """

    expected = """
    case x do
      :foo -> {:foo, x}
      :bar -> {:bar, x}
    end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "formats anonymous functions" do
    code = """
    fn x ->
      {:ok, x}
    end
    """

    expected = """
    fn x -> {:ok, x} end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "keeps fn with pattern matching" do
    code = ~S"""
    fn
      {:x, x} -> inspect("x = #{x}")
      {:y, y} -> inspect("y = #{y}")
    end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == code
  end

  test "formats fn without skip and ignore" do
    code = """
    fn
      x ->
        {
          :ok,
          x
        }
    end
    """

    expected = """
    fn x -> {:ok, x} end
    """

    source = run(code)

    assert formated?(code)
    assert source.code == expected
  end

  test "keeps fn with skip" do
    code = """
    fn
      x ->
        {
          :ok,
          x
        }
    end
    """

    source = run(code, skip: [:fn])

    assert formated?(code)
    assert source.code == code
  end

  test "keeps fn with ignore" do
    code = """
    fn
      x ->
        {
          :ok,
          x
        }
    end
    """

    expected = """
    fn
      x -> {:ok, x}
    end
    """

    source = run(code, ignore: [:fn])

    assert formated?(code)
    assert source.code == expected
  end
end

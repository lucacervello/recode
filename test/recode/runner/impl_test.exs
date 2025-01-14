defmodule Recode.Runner.ImplTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Mox

  alias Recode.Project
  alias Recode.Runner.Impl, as: Runner
  alias Recode.Task.SinglePipe
  alias Recode.TaskMock

  setup :verify_on_exit!

  setup_all context do
    cwd = File.cwd!()
    File.cd!("test/fixtures/runner")

    config = "config.exs" |> Code.eval_file() |> elem(0)

    on_exit(fn -> File.cd(cwd) end)

    Map.put(context, :config, config)
  end

  describe "run/1" do
    test "runs tasks from config", %{config: config} do
      config = Keyword.merge(config, dry: true, verbose: true, tasks: [{SinglePipe, []}])

      capture_io(fn ->
        assert %Project{} = Runner.run(config)
      end)
    end

    test "runs tasks from config (autocorrect: false)", %{config: config} do
      config = Keyword.merge(config, dry: true, autocorrect: false, tasks: [{SinglePipe, []}])

      capture_io(fn ->
        assert %Project{} = Runner.run(config)
      end)
    end

    test "runs task with the right config", %{config: config} do
      TaskMock
      |> expect(:run, fn source, config ->
        assert config == [autocorrect: true]
        source
      end)
      |> expect(:config, fn :correct -> true end)

      config = Keyword.put(config, :tasks, [{TaskMock, []}])

      capture_io(fn ->
        assert Runner.run(config)
      end)
    end

    test "runs task with the right aditional config", %{config: config} do
      TaskMock
      |> expect(:run, fn source, config ->
        assert config == [autocorrect: true, foo: :bar]
        source
      end)
      |> expect(:config, fn :correct -> true end)

      config = Keyword.put(config, :tasks, [{TaskMock, config: [foo: :bar]}])

      capture_io(fn ->
        assert Runner.run(config)
      end)
    end

    test "does not run task with active: false", %{config: config} do
      TaskMock
      |> expect(:run, fn source, config ->
        assert config == [autocorrect: true, foo: :bar]
        source
      end)
      |> expect(:config, 2, fn :correct -> true end)

      config =
        Keyword.put(config, :tasks, [
          {TaskMock, config: [foo: :bar]},
          {TaskMock, active: false, config: [foo: :none]}
        ])

      capture_io(fn ->
        assert Runner.run(config)
      end)
    end
  end

  describe "run/2" do
    test "runs one task", %{config: config} do
      capture_io(fn ->
        assert %Project{} = Runner.run({SinglePipe, []}, config)
      end)
    end

    test "runs two tasks", %{config: config} do
      capture_io(fn ->
        assert %Project{} = Runner.run([{SinglePipe, []}, {SinglePipe, []}], config)
      end)
    end
  end
end

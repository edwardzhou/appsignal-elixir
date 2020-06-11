defmodule InstrumentedModule do
  use Appsignal.Instrumentation.Decorators

  @decorate instrument()
  def instrument do
    :ok
  end

  @decorate instrument("background_job")
  def background_job do
    :ok
  end
end

defmodule Appsignal.InstrumentationTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  setup do
    Test.Nif.start_link()
    Test.Tracer.start_link()
    Test.Span.start_link()
    :ok
  end

  describe "instrument/2" do
    setup do
      %{return: InstrumentedModule.instrument()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"http_request", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.instrument/0"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/3, with a custom namespace" do
    setup do
      %{return: InstrumentedModule.background_job()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"http_request", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.background_job/0"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's namespace" do
      assert {:ok, [{%Span{}, "background_job"}]} = Test.Span.get(:set_namespace)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end
end

defmodule AppsTest do
  use ExUnit.Case
  doctest Apps

  test "greets the world" do
    assert Apps.hello() == :world
  end
end

defmodule MarbleRaceMakerTest do
  use ExUnit.Case
  doctest MarbleRaceMaker

  test "empty detection frames dont cause error" do
    MarbleRaceMaker.VidProcess.get_leaders("outputs/frames/opium trio.mp4_out/out.json", ["Ken", "Carti", "Lone"])
    |> tap(&IO.inspect/1)
    |> MarbleRaceMaker.VidProcess.get_leaders_times(5)
    |> IO.inspect()
  end
end

defmodule MarbleRaceMaker.AudioManage do
  require Logger
  @rvc_path "D:\\Mangio-RVC-v23.7.0"

  def separate_audio(audio_path) do
    Logger.info("Separating #{audio_path} via uvr..")
    System.shell("runtime\\python infer_uvr5.py \"#{audio_path}\"", [cd: @rvc_path])
    out_path = @rvc_path <> "/opt/" <> Path.basename(audio_path)
    {:ok, files} = File.ls(out_path)
    files
    |> Enum.map(&(Path.basename(audio_path) <> "/" <> &1))
  end


  def concat_vocals(all_vocals, timeline) do

  end

  @rvc_out_path ~S"D:\\Mangio-RVC-v23.7.0\\audio-outputs\\"
  defp serialize_timeline(timeline) do
    timeline
    |> Enum.map_reduce(0, fn {character, time}, acc ->
      line1 = "file '#{@rvc_out_path}#{character}.mp3'"
      line2 = "inpoint #{acc}"
    end)
  end

end

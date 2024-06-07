defmodule MarbleRaceMaker.AudioManage do
  require Logger
  @rvc_path "D:\\Mangio-RVC-v23.7.0"

  def separate_audio(audio_path) do
    Logger.info("Separating #{audio_path} via uvr..")
    System.shell("runtime\\python infer_uvr5.py \"#{audio_path}\"", [cd: @rvc_path])
    out_path = @rvc_path <> "/opt/" <> Path.basename(audio_path)
    {:ok, files} = File.ls(out_path)
    files
    |> Enum.map(&(@rvc_path <> "/opt/" <> Path.basename(audio_path) <> "/" <> &1))
  end

  @final_audio_out_path "outputs/audio_out.mp3"
  def merge_vocals_instrumental(vocals_path, instrumental_path) do
    Logger.info("Merging #{vocals_path} and #{instrumental_path}..")
    System.shell("ffmpeg -i #{vocals_path} -i #{instrumental_path} -y -filter_complex \"[0:a]adrc=transfer='if(gt(p,-50),-50+(p-(-50))/5,p)':attack=50:release=100:attack=50:release=100[a1];[a1]speechnorm=e=50:r=0.0001:l=1[norma];[norma]amix=normalize=1:dropout_transition=0:weights='1 0.8' [outa]\" -map \"[outa]\" #{@final_audio_out_path}")
    @final_audio_out_path
  end

  @timeline_out_path "outputs/timeline.txt"
  @vocals_out_path "outputs/vocals.mp3"
  def concat_vocals(timeline) do
    tl_serialized = serialize_timeline(timeline)
    File.write(@timeline_out_path, tl_serialized)
    Logger.info("Concatenating vocals..")
    System.shell("ffmpeg -y -f concat -async 0 -safe 0 -i #{@timeline_out_path} -c:a libshine -b:a 128k #{@vocals_out_path}")
    @vocals_out_path
  end

  @rvc_out_path ~S"D:\\Mangio-RVC-v23.7.0\\audio-outputs\\"
  defp serialize_timeline(timeline) do
    timeline
    |> Enum.map_reduce(0, fn {character, time}, acc ->
      time = Float.floor(time, 3)
      str = "file '#{@rvc_out_path}#{character}.mp3'\ninpoint #{acc}\noutpoint #{time}\n"
      {str, time}
    end)
    |> elem(0)
    |> Enum.reduce(&(&2 <> &1))
  end

end

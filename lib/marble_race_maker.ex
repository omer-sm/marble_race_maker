defmodule MarbleRaceMaker do
  require Logger
  import MarbleRaceMaker.VidProcess
  import MarbleRaceMaker.AudioManage
  import MarbleRaceMaker.RvcManage

  @doc """
  video path can be relative to this dir
  charcters is list of strings of character names
  audio path needs to be relative in rvc dir, for ex audios/2024.mp3
  opts is [fps: fps]
  example:
  MarbleRaceMaker.process_video("resources/test.mp4", ["Ken", "Carti", "Yeat", "Lone"], "audios/2024.mp3", [fps: 2])
  """
  @default_opts %{fps: 1}
  def process_video(video_path, characters, audio_path, opts \\ []) do
    %{fps: fps} = Enum.into(opts, @default_opts)
    # clear rvc out directory
    #clear_out_dir(characters)
    # split into frames and get timeline
    {timeline, _total} = split_video(video_path, fps)
    |> process_frames()
    |> get_leaders(characters)
    |> get_leaders_times(fps)
    # process audios in uvr and rvc
    [instrumental, vocal] = separate_audio(audio_path)
    run_rvc(vocal, characters)
    concat_vocals(timeline)
    |> merge_vocals_instrumental(instrumental)
    |> merge_audio_video(video_path)
    Logger.info("Done!")
  end

end

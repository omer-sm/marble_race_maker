defmodule MarbleRaceMaker do
  require Logger
  import MarbleRaceMaker.VidProcess
  import MarbleRaceMaker.AudioManage
  import MarbleRaceMaker.RvcManage

  @default_opts %{fps: 1}
  def process_video(video_path, characters, audio_path, opts \\ []) do
    %{fps: fps} = Enum.into(opts, @default_opts)
    # split into frames and get timeline
    {timeline, total} = split_video(video_path, fps)
    |> process_frames()
    |> get_leaders(characters)
    |> get_leaders_times(fps)
    # process audios in uvr and rvc
    [instrumental, vocal] = separate_audio(audio_path)
    all_vocals = run_rvc(vocal, characters)
  end

end

defmodule MarbleRaceMaker do
  require Logger
  @out_folder "outputs"

  def split_video(path, fps \\ 2) do
    Logger.info("Splitting video with #{fps} fps from #{path}..")
    name = Path.basename(path)
    out_dir = @out_folder <> "/frames/" <> name <> "_out"
    File.mkdir(out_dir)
    System.shell("ffmpeg -i #{path} -vf fps=#{fps} \"#{out_dir}/f%d.png\"")
    out_dir
  end

  @ocr_path "py/run_ocr.py"
  def process_frames(frames_path) do
    Logger.info("Running OCR on frames in #{frames_path}..")
    System.shell("python #{@ocr_path} #{frames_path}")
    frames_path <> "/out.json"
  end

  def get_leaders(ocr_out_path, names) do
    with {:ok, body} <- File.read(ocr_out_path),
         {:ok, json} <- Jason.decode(body), do: json
    |> Enum.map(fn detections ->
      winner = Enum.reject(detections, &(is_bb_too_big?(Map.get(&1, "bb"))))
      |> Enum.max_by(fn x ->
        Map.get(x, "bb")
        |> Enum.reduce(0, fn coords, acc ->
          hd(tl(coords))/4 + acc end)
      end)
      Enum.max_by(names, fn name ->
        String.jaro_distance(name, Map.get(winner, "text"))
      end)

    end)
  end

  defp is_bb_too_big?([a, b, c, d]) do
    area_partial = fn [x1, y1], [x2, y2] ->
      x1 * y2 - y1 * x2
    end
    area =
      area_partial.(a, b) +
      area_partial.(b, c) +
      area_partial.(c, d) +
      area_partial.(d, a)
    (abs(area) / 2) > 15000
  end

end

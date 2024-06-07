defmodule MarbleRaceMaker.RvcManage do
  require Logger
  @models %{
    "Ken" => "KenCarsonV3",
    "Carti" => "NewCarti",
    "Yeat" => "Yeat6000",
    "Lone" => "destroylonely"
  }
  @rvc_path "D:\\Mangio-RVC-v23.7.0"

  @rvc_script_path "py/run_rvc.py"
  def run_rvc(vocal_path, characters) do
    model_names = Enum.reduce(characters, fn x, acc -> x <> " " <> acc end)
    Logger.info("Running RVC on #{vocal_path} for #{model_names}..")
    System.shell("python #{@rvc_script_path} \"#{vocal_path}\" #{model_names}")
    characters
    |> Enum.map(&(&1 <> ".mp3"))
  end


  @models_file_path "models.json"
  def update_models_file(path \\ @models_file_path) do
    Logger.info("Upadting #{@models_file_path}..")
    {:ok, encoded} = Jason.encode(get_full_models())
    File.write(path, encoded)
  end

  @rvc_out_dir "D:\\Mangio-RVC-v23.7.0/audio-outputs"
  def clear_out_dir(characters) do
    Enum.each(characters, fn x ->
      File.rm(@rvc_out_dir <> "/" <> x <> ".mp3")
    end)
  end

  defp get_full_models() do
    @models
    |> Enum.map(fn {name, model} ->
      index_file = File.ls(@rvc_path <> "/logs/" <> model) |> elem(1) |> hd()
      {name, %{
        model: model,
        index_file: index_file
      }}
    end)
    |> Enum.into(%{})
  end
end

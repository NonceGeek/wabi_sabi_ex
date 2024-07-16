defmodule WabiSabiEx.MarkdownRender do
  @moduledoc """
      read the `.md` and render it as the html.
      see the examples in example websites.
  """

  require Logger

  def render(:file, file_path) do
    tree = file_path |> File.read!() |> Earmark.as_ast!()

    tree
    # split markdown with page and anno.
    |> split_page_and_anno()
    # parse page and anno to standard format.
    |> parse()
    # render standard format to html.
    |> render_to_html()
  end

  def render(:raw, raw) do
    tree = Earmark.as_ast!(raw)

    tree
    # split markdown with page and anno.
    |> split_page_and_anno()
    # parse page and anno to standard format.
    |> parse()
    # render standard format to html.
    |> render_to_html()
  end

  def split_page_and_anno(tree) do
    {[{"pre", _, [{"code", _, [raw_page], _}], _}], others} = Enum.split(tree, 1)
    {"```\n#{raw_page}\n```", others}
  end

  def parse({page, anno}) do
    tree_formatted = format_with_level(anno, "h2")

    # Extract links if the "Links" section exists, otherwise return an empty list
    links =
      case get_part_by_head(tree_formatted, "Links") do
        nil -> []
        part -> parse_links(part)
      end

    # Extract bolds if the "Bolds" section exists, otherwise return an empty list
    bolds =
      case get_part_by_head(tree_formatted, "Bolds") do
        nil -> []
        part -> parse_bolds(part)
      end

    # Extract colors if the "Colors" section exists, otherwise return an empty list
    colors =
      case get_part_by_head(tree_formatted, "Colors") do
        nil -> []
        part -> parse_colors(part)
      end

    # Extract colors if the "Vars" section exists, otherwise return an empty list
    vars =
      case get_part_by_head(tree_formatted, "Vars") do
        nil -> []
        part -> parse_vars(part)
      end
    
    # Extract bolds if the "Bolds" section exists, otherwise return an empty list
    spec_fields =
    case get_part_by_head(tree_formatted, "Spec Fields") do
      nil -> []
      # TODO: need update.
      part -> parse_bolds(part)
    end

      # Extract bolds if the "Bolds" section exists, otherwise return an empty list
      music =
        case get_part_by_head(tree_formatted, "Music") do
          nil -> nil
          part -> parse_music(part)
        end

    {page, %{links: links, bolds: bolds, colors: colors, vars: vars, spec_fields: spec_fields, music: music}}
  end

  def fetch_vars(vars) do
    Enum.map(vars, fn %{key: key, var: var} ->
      if String.starts_with?(var, "get://") do
        fetch_var(key, var)
      else
        %{key: key, var: var}
      end
    end)
  end

  def fetch_var(key, "get://" <> url) do
    try do
      {:ok, resp} =ExHttp.http_get(url)
      %{key: key, var: resp}
    rescue
      e ->
        Logger.error("Failed to fetch URL #{url}: #{e}")
        %{key: key, var: ""}
    end
  end

  def render_to_html({page, %{links: links, bolds: bolds, music: music_link, colors: colors, vars: vars, spec_fields: spec_fields} = anno}) do
    html_unhandled = Earmark.as_html!(page)

    # Fetch data for variables that start with "get://"
    fetched_vars = fetch_vars(vars)

    html_handled_by_vars =
      Enum.reduce(fetched_vars, html_unhandled, fn %{key: key, var: var}, acc ->
        result = String.replace(acc, "{#{key}}", var)
        result
      end)

    html_handled_by_links =
      Enum.reduce(links, html_handled_by_vars, fn %{key: key, link: link}, acc ->
        String.replace(acc, key, "<a href=\"#{link}\">#{key}</a>")
      end)

    html_handled_by_bolds =
      Enum.reduce(bolds, html_handled_by_links, fn key, acc ->
        String.replace(acc, key, "<b>#{key}</b>")
      end)

    html_handled_by_colors =
      Enum.reduce(colors, html_handled_by_bolds, fn %{key: key, color: color}, acc ->
        result = String.replace(acc, key, "<span style=\"color: #{color};\">#{key}</span>")
        result
      end)

    # todo: work in the future
  html_handle_by_spec_fields = 
    Enum.reduce(spec_fields, html_handled_by_colors, fn key, acc ->
      result = String.replace(acc, "{#{key}}", "")
      result
    end)
    # Embed audio link if it exists
    html_handled_by_music =
    if not is_nil(music_link) do
      music_tag = """
      <center>
        <style>
          .custom-audio {
            display: none;
          }
        </style>
        <audio controls autoplay loop class="custom-audio" id="player">
          <source src="#{music_link}" type="audio/mpeg">
        </audio>
        <br>
        ---------♪---------
        <br>
        <button onclick="document.getElementById('player').play()">|&nbsp;&nbsp;<b>▶︎ Play </b></button>
        | 
        <button onclick="document.getElementById('player').pause()"><b> || Pause</b>&nbsp;&nbsp;|</button>
        <br>
        -------------------
        
      </center>
      """
      html_handle_by_spec_fields <> music_tag
    else
      html_handle_by_spec_fields
    end



    {html_handled_by_music, anno}
  end

  # TODO: replace now for every fields that including in the para which head is "Spec Fields"

  # +-------------+
  # | Basic Funcs |
  # +-------------+


  def parse_music(raw_music) do
    [{"ul", [], [{"li", [], [{"a", [{"href", _}], [link], %{}}], %{}}], %{}}] = raw_music
    link
  end

  def parse_bolds(raw_bolds) do
    [{"ul", [], bolds, %{}}] = raw_bolds

    bolds
    |> Enum.map(fn {"li", [], [raw_key_word], %{}} ->
      if is_binary(raw_key_word) do
        raw_key_word
      else
        {"p", [], [raw_key_word_inner], %{}} = raw_key_word
        raw_key_word_inner
      end
    end)
  end

  def parse_vars(raw_vars) do
    [{"ul", [], vars, %{}}] = raw_vars
  
    vars
    |> Enum.map(&parse_var/1)
  end
  
  defp parse_var({"li", [], raw_var, %{}}) do
    {key, var} =
      case raw_var do
        [single] ->
          parse_single(single)
  
        [pre, {"a", [{"href", href}], [_], %{}}] ->
          # Generalize handling for any variable that starts with "get://"
          if String.trim(pre) |> String.ends_with?("get://") do
            [var_prefix | _] = String.split(pre, ":", parts: 2)
            {String.trim(var_prefix), "get://#{href}"}
          else
            {String.replace(pre, ":", ""), href}
          end
      end
  
    %{
      key: String.trim(key),
      var: String.trim(var)
    }
  end
  
  defp parse_single(raw_var) when is_binary(raw_var) do
    [key, var] = String.split(raw_var, ":", parts: 2)
    {key, var}
  end
  
  defp parse_single([{"p", [], [raw_var_inner], %{}}]) do
    parse_single(raw_var_inner)
  end

  def parse_colors(raw_colors) do
    [{"ul", [], colors, %{}}] = raw_colors

    colors
    |> Enum.map(fn
      {"li", [], [raw_color], %{}} ->
        [key, color] = String.split(raw_color, ":")

        %{
          key: String.trim(key),
          color: String.trim(color)
        }
    end)
  end

  def parse_links(raw_links) do
    [{"ul", [], links, %{}}] = raw_links

    links
    |> Enum.map(fn {"li", [],
                    [
                      raw_key,
                      {"a", [{"href", _}], [raw_link], %{}}
                    ], %{}} ->
      [key, _] = String.split(raw_key, ":")

      %{
        key: String.trim(key),
        link: String.trim(raw_link)
      }
    end)
  end

  def get_part_by_head(tree, head_content) do
    tree
    |> Enum.find(fn
      %{head: {"h2", _, [content], _}} -> content == head_content
    end)
    |> case do
      nil -> nil
      part -> Map.get(part, :body)
    end
  end

  def format_with_level(tree, level) do
    # Find all indices of elements matching the given level
    indices =
      Enum.with_index(tree)
      |> Enum.filter(fn {elem, _} -> elem |> Tuple.to_list() |> Enum.at(0) == level end)
      |> Enum.map(fn {_, index} -> index end)

    # Add the end of the tree as the last boundary to capture the last section
    indices = indices ++ [length(tree)]

    # Map over the indices to format each section between two headings
    Enum.map(0..(length(indices) - 2), fn idx ->
      # Start of current section
      start_idx = Enum.at(indices, idx)
      # End of current section (start of the next section)
      end_idx = Enum.at(indices, idx + 1)

      # Slice the tree from the start index of the current section to the start index of the next section
      section = Enum.slice(tree, start_idx, end_idx - start_idx)

      # Format the section
      format_section(section)
    end)
  end

  defp format_section(section) do
    head = List.first(section)
    body = section |> Enum.drop(1)

    %{
      head: head,
      body: body
    }
  end

  def get_content(tree, h2, h2_after) do
    h2_index = Enum.find_index(tree, &(&1 == h2))
    h2_after_index = Enum.find_index(tree, &(&1 == h2_after))
    {_part_1, part_2} = Enum.split(tree, h2_index)

    {content, _part_3} = Enum.split(part_2, h2_after_index)
    content
  end

  def get_content(tree, h2) do
    h2_index = Enum.find_index(tree, &(&1 == h2))
    {_part_1, part_2} = Enum.split(tree, h2_index)
    part_2
  end

  def format_content(content) do
    {[h2_part], others} = Enum.split(content, 1)
    %{head: h2_part, body: others}
  end
end

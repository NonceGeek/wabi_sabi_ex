defmodule WabiSabiEx.MarkdownRender do
    @moduledoc """
        read the `.md` and render it as the html.
        see the examples in example websites.
    """

    def render(:file, file_path) do
        tree =  file_path |> File.read!() |> Earmark.as_ast!()
        tree
        |> split_page_and_anno() # split markdown with page and anno.
        |> parse() # parse page and anno to standard format.
        |> render_to_html() # render standard format to html.
    end

    def render(:raw, raw) do
        tree =  Earmark.as_ast!(raw)
        tree
        |> split_page_and_anno() # split markdown with page and anno.
        |> parse() # parse page and anno to standard format.
        |> render_to_html() # render standard format to html.
    end

    def split_page_and_anno(tree) do
        {[{"pre", _, [{"code",  [{"class", lang}], [raw_page], _}], _}], others} = 
            Enum.split(tree, 1)
        {"```#{lang}\n#{raw_page}\n```", others}
    end

    def parse({page, anno}) do
        
        tree_formatted = format_with_level(anno, "h2")
        links = 
            tree_formatted
            |> get_part_by_head("Links")
            |> parse_links()
        {page, %{links: links}}
    end

    def render_to_html({page, %{links: links} = anno}) do
        html_unhandled = Earmark.as_html!(page)
        html_handled = 
            Enum.reduce(links, html_unhandled, fn %{key: key, link: link}, acc ->
                String.replace(acc, key, "<a href=\"#{link}\">#{key}</a>")
            end)
        {html_handled, anno}
    end

    # +-------------+
    # | Basic Funcs |
    # +-------------+

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
                key: key,
                link: raw_link
            }
        end)
    end

    def get_part_by_head(tree, head_content) do
        tree
        |> Enum.find(fn %{head:  {"h2", [], [content], %{}}} -> content == head_content end)
        |> Map.get(:body)
    end

    def format_with_level(tree, level) do
        all_h2 = tree |> Enum.filter(fn elem -> elem |> Tuple.to_list |> Enum.fetch!(0) == level end)

        Enum.map(all_h2, fn h2 -> 
            idx = Enum.find_index(all_h2, &(&1 == h2))
            h2_after = Enum.fetch(all_h2, idx + 1)
            if h2_after == :error do # it means it is the last one
                tree
                |> get_content(h2) 
                |> format_content()
            else
                {:ok, content} = h2_after
                tree
                |> get_content(h2, content) 
                |> format_content()
            end
        end)
    end

    def get_content(tree, h2, h2_after) do
        h2_index = Enum.find_index(tree, &(&1==h2))
        h2_after_index = Enum.find_index(tree, &(&1==h2_after))
        {_part_1, part_2} = Enum.split(tree, h2_index)
       
        {content, _part_3} = Enum.split(part_2, h2_after_index)
        content
    end


    def get_content(tree, h2) do
        h2_index = Enum.find_index(tree, &(&1==h2))
        {_part_1, part_2} = Enum.split(tree, h2_index)
        part_2
    end

    def format_content(content) do
        {[h2_part], others} = Enum.split(content, 1)
        %{head: h2_part, body: others}
    end
end

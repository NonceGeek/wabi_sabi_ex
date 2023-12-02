defmodule WabiSabiEx.MarkdownRender do
    @moduledoc """
        read the `.md` and render it as the html.
        see the examples in example websites.
    """

    def render(file_path) do
        tree =  file_path |> File.read!() |> Earmark.as_ast!()

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
        {page, anno}
    end

    def render_to_html({page, anno}) do
        {Earmark.as_html!(page), anno}
    end
end

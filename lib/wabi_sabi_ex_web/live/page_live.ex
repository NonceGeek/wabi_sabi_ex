defmodule WabiSabiExWeb.PageLive do
  alias WabiSabiEx.MarkdownRender

  use WabiSabiExWeb, :live_view

  def mount(%{"gist" => gist_id}, _session, socket) do
    # get both the template and data from gist, which use the first file is fine.
    url = "https://gitfluid.deno.dev/gist?id=#{gist_id}"
    {:ok, %{files: files}} = ExHttp.http_get(url)
    content = files |> hd() |> Map.get(:content)
    IO.puts inspect content
    {html, _} = MarkdownRender.render(:raw, content)
    {:ok,
     assign(socket,
      html: html,
      #  modal: false,
      #  slide_over: false,
      #  pagination_page: 1,
       active_tab: :live
     )}
  end


  def get_content_by_id(id) do
    if is_bodhi_asset_id(id) do
      get_bodhi_asset_content(id)
    else
      get_gist_content(id)
    end
  end

  def is_bodhi_asset_id(id) do
    String.match?(id, ~r/^\d+$/)
  end

  def get_bodhi_asset_content(asset_id) do
    url = "https://bodhi-data.deno.dev/assets?asset_begin=#{asset_id}&asset_end=#{asset_id}"
    {:ok, %{assets: [%{content: content}]}} = ExHttp.http_get(url)
    content
  end

  def get_gist_content(gist_id) do
    url = "https://gitfluid.deno.dev/gist?id=#{gist_id}"
    {:ok, %{files: files}} = ExHttp.http_get(url)
    files |> hd() |> Map.get(:content)
  end

  def mount(%{"template" => template_id, "data" => data_id} = params, _session, socket) when map_size(params) > 0 do
    # TODO: the template_id and the data_id is the bodhi asset id which is the num or the gist id which is hex, to juddge the type of the id automatically and get the content by the type.
    content_template = get_content_by_id(template_id)
    content_data = get_content_by_id(data_id)
    
    # # get template from bodhi
    # url = "https://bodhi-data.deno.dev/assets?asset_begin=#{template_id}&asset_end=#{template_id}"
    # {:ok, %{assets: [%{content: content_template}]}} = ExHttp.http_get(url)

    # # get data from bodhi
    # url = "https://bodhi-data.deno.dev/assets?asset_begin=#{data_id}&asset_end=#{data_id}"
    # {:ok, %{assets: [%{content: content_data}]}} = ExHttp.http_get(url)
    
    content = "#{content_template}\n\n#{content_data}"
    {html, _} = MarkdownRender.render(:raw, content)
    {:ok,
     assign(socket,
      html: html,
      #  modal: false,
      #  slide_over: false,
      #  pagination_page: 1,
       active_tab: :live
     )}
  end

  @impl true
  def mount(%{}, _session, socket) do
    {html, _} = MarkdownRender.render(:file, "example_websites/wabi_sabi_index.md")
    # {html, _} = MarkdownRender.render(:file, "example_websites/aptoscraft_homepage.md")
    {:ok,
     assign(socket,
      html: html,
      #  modal: false,
      #  slide_over: false,
      #  pagination_page: 1,
       active_tab: :live
     )}
  end

  # @impl true
  # def handle_params(params, _uri, socket) do
  #   case socket.assigns.live_action do
  #     :index ->
  #       {:noreply, assign(socket, modal: false, slide_over: false)}

  #     :modal ->
  #       {:noreply, assign(socket, modal: params["size"])}

  #     :slide_over ->
  #       {:noreply, assign(socket, slide_over: params["origin"])}

  #     :pagination ->
  #       {:noreply, assign(socket, pagination_page: String.to_integer(params["page"]))}
  #   end
  # end

  @impl true
  def render(assigns) do
    ~H"""
      <nav class="sticky top-0 flex items-center justify-between w-full h-16 bg-white dark:bg-gray-900">
        <div class="flex flex-wrap ml-3 sm:flex-nowrap sm:ml-10">
          <a class="inline-flex hover:opacity-90" href="/">
            <%= raw(Earmark.as_html!("`ʕっ•ᴥ•ʔっ Wabi Sabi Ex Web Framework`"))%>
          </a>
        </div>

        <div class="flex justify-end gap-3 pr-4">
          <a
            target="_blank"
            class="inline-flex items-center gap-2 p-2 text-gray-500 rounded dark:text-gray-400 dark:hover:text-gray-500 hover:text-gray-400 group"
            href="https://github.com/NonceGeek/wabi_sabi_ex"
          >
            ⭐️
            <span class="hidden font-semibold sm:block">
              Star on Github
            </span>
          </a>
          <a
            target="_blank"
            class="inline-flex items-center gap-2 p-2 text-gray-500 rounded dark:text-gray-400 dark:hover:text-gray-500 hover:text-gray-400 group"
            href="https://twitter.com/0xleeduckgo"
          >
            🐦
            <span class="hidden font-semibold sm:block">
              Follow us
            </span>
          </a>
        </div>
      </nav>

      <!--<.container class="mt-10">
        <.h1>Doge House</.h1>
      </.container>-->

      <.container class="mt-10 mb-32">
        <%= raw @html %>
      </.container>
    """
  end

  # @impl true
  # def handle_event("close_modal", _, socket) do
  #   {:noreply, push_patch(socket, to: "/live")}
  # end

  # def handle_event("close_slide_over", _, socket) do
  #   {:noreply, push_patch(socket, to: "/live")}
  # end
end

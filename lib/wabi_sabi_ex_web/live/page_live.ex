defmodule WabiSabiExWeb.PageLive do
  alias WabiSabiEx.MarkdownRender

  use WabiSabiExWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {html, _} = MarkdownRender.render("example_websites/doge_house.md")
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
            href="https://github.com/petalframework/petal_components"
          >
            ⭐️
            <span class="hidden font-semibold sm:block">
              Star on Github
            </span>
          </a>
          <a
            target="_blank"
            class="inline-flex items-center gap-2 p-2 text-gray-500 rounded dark:text-gray-400 dark:hover:text-gray-500 hover:text-gray-400 group"
            href="https://twitter.com/PetalFramework"
          >
            🐦
            <span class="hidden font-semibold sm:block">
              Follow us
            </span>
          </a>
        </div>
      </nav>

      <.container class="mt-10">
        <.h1>Doge House</.h1>
      </.container>

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

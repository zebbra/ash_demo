defmodule AshDemoWeb.AdminComponents do
  @moduledoc false

  use AshDemoWeb, :html

  slot :inner_block

  def admin_drawer(assigns) do
    ~H"""
    <.drawer class="drawer-open">
      <div class="bg-base-100 h-full">
        <%= render_slot(@inner_block) %>
      </div>

      <:side>
        <div class="transition-[width] h-full flex flex-col p-8 gap-8 w-24 lg:w-72 max-lg:items-center border-r border-base-300 bg-primary text-primary-content">
          <.admin_logo />
          <.admin_menu />
        </div>
      </:side>
    </.drawer>
    """
  end

  def admin_logo(assigns) do
    ~H"""
    <.link navigate={~p"/admin/posts"} class="flex items-center gap-3">
      <div class="bg-secondary text-secondary-content p-3 mask mask-hexagon grid">
        <.icon name="tabler-rocket" class="w-6 h-6" />
      </div>

      <div class="flex-col hidden lg:flex">
        <span class="font-bold text-base-100 text-xl -mb-1">AshDemo</span>
        <span class="text-xs uppercase font-semibold opacity-50">Admin</span>
      </div>
    </.link>
    """
  end

  def admin_menu(assigns) do
    ~H"""
    <ul class="menu px-0">
      <.admin_menu_item path={~p"/admin/posts"} icon="tabler-file-text" text="Posts" />
      <.admin_menu_item path={~p"/admin/categories"} icon="tabler-folders" text="Categories" />
    </ul>
    """
  end

  attr :path, :string, required: true
  attr :icon, :string, required: true
  attr :text, :string, required: true

  def admin_menu_item(assigns) do
    ~H"""
    <li>
      <.link navigate={@path} class="lg:pl-2 gap-4">
        <.icon name={@icon} class="h-8 w-8 lg:w-8 lg:h-8 opacity-70" />
        <span class="max-lg:hidden text-lg"><%= @text %></span>
      </.link>
    </li>
    """
  end
end

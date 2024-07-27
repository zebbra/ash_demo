defmodule AshDemoWeb.Admin.PostLive.CommentForm do
  @moduledoc false
  use AshDemoWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="comment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input type="textarea" placeholder="Comment" field={@form[:comment]} />

        <:actions>
          <.button phx-disable-with="Saving...">Comment</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, post_params))}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        socket =
          socket
          |> put_flash(:info, "Post #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{post: post}} = socket) do
    form =
      AshPhoenix.Form.for_update(post, :add_comment,
        as: "post",
        actor: socket.assigns.current_user
      )

    assign(socket, :form, to_form(form))
  end
end

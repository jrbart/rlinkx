defmodule RlinkxWeb.BookmarkComponents do
  use Phoenix.Component

  import RlinkxWeb.CoreComponents

  attr :form, Phoenix.HTML.Form, required: true
  attr :target, :any, default: nil

  # TODO: impoert with embed_templates (https://hexdocs.pm/phoenix_live_view/1.0.10/Phoenix.Component.html#embed_templates/2)
  def bookmark_form(assigns) do
    ~H"""
    <.simple_form
      for={@form}
      id="bookmark-form"
      phx-change="validate-bookmark"
      phx-submit="save-bookmark"
      phx-target={@target}
    >
      <.input field={@form[:name]} type="text" label="Name" phx-debounce />
      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce />
      <.input field={@form[:url_link]} type="text" label="Link" phx-debounce />
      <:actions>
        <.button phx-disable-with="Saving...">Save</.button>
        <.button
          phx-click="delete-bookmark"
          phx-value-bookmark={@form.data.id}
          type="button"
          data-confirm="This will be permanent"
        >
          Delete
        </.button>
      </:actions>
    </.simple_form>
    """
  end
end

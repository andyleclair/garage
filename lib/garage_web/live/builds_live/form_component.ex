defmodule GarageWeb.BuildsLive.FormComponent do
  use GarageWeb, :live_component
  alias Garage.Builds
  alias Garage.Mopeds.Make
  alias Garage.Mopeds.Model
  alias AshPhoenix.Form

  attr :current_user_id, :string, required: true
  attr :build, :any, required: true, doc: "The Build struct"

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Tell the world about your moped!</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="build-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:year]} type="text" label="Year" />
        <.live_select
          field={@form[:make_id]}
          phx-focus="set-default"
          options={@make_options}
          label="Make"
          phx-target={@myself}
        />
        <%= if @model_options do %>
          <.live_select
            field={@form[:model_id]}
            phx-focus="set-default"
            options={@model_options}
            label="Model"
            phx-target={@myself}
            debounce="250"
          />
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Save Build</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{build: build} = assigns, socket) do
    form = Form.for_action(build, live_action_to_ash_action(assigns.action), api: Builds)
    make_options = make_options()

    # if we already have a make set, show the model dropdown
    model_options =
      if make_id = form_make_id(form) do
        model_options_by_id(make_id)
      else
        nil
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:make_options, make_options)
     |> assign(:model_options, model_options)
     |> assign_form(form)}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => "form_make" <> _ = id, "text" => text},
        socket
      ) do
    options = search_options(socket.assigns.make_options, text)
    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => "form_model" <> _ = id, "text" => text},
        socket
      ) do
    options = search_options(socket.assigns.model_options, text)
    send_update(LiveSelect.Component, options: options, id: id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "form_make" <> _ = id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.make_options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "form_model" <> _ = id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.model_options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)

    socket =
      if make_id = form_make_id(form) do
        assign(socket, :model_options, model_options_by_id(make_id))
      else
        socket
      end

    {:noreply, assign_form(socket, form)}
  end

  def handle_event("save", %{"form" => form}, socket) do
    save_build(socket, socket.assigns.action, form)
  end

  defp save_build(socket, :edit, params) do
    case Form.submit(socket.assigns.form, params: params) do
      {:ok, build} ->
        {:noreply,
         socket
         |> put_flash(:info, "Build updated successfully")
         |> push_navigate(to: ~p"/builds/#{build}")}

      {:error, form} ->
        {:noreply, assign_form(socket, form)}
    end
  end

  defp save_build(socket, :new, params) do
    # We only set this on the server side to be safe
    params = Map.put(params, "builder_id", socket.assigns.current_user.id)

    case Form.submit(socket.assigns.form, params: params) do
      {:ok, build} ->
        {:noreply,
         socket
         |> put_flash(:info, "Build created successfully")
         |> push_navigate(to: ~p"/builds/#{build}")}

      {:error, form} ->
        {:noreply, assign_form(socket, form)}
    end
  end

  def search_options(options, text) do
    if text == "" do
      options
    else
      options
      |> Enum.filter(fn {option, _id} ->
        String.downcase(option) |> String.contains?(String.downcase(text))
      end)
    end
  end

  def form_make_id(form) do
    case Form.value(form, :make_id) do
      "" ->
        nil

      nil ->
        nil

      make_id ->
        make_id
    end
  end

  defp make_options() do
    for make <- Make.read_all!(), into: [], do: {make.name, make.id}
  end

  defp model_options_by_id(make_id) do
    for model <- Model.by_make_id!(make_id), into: [], do: {model.name, model.id}
  end

  defp assign_form(socket, %Form{} = form) do
    assign(socket, :form, to_form(form))
  end

  defp assign_form(socket, %Phoenix.HTML.Form{} = form) do
    assign(socket, :form, form)
  end

  defp live_action_to_ash_action(:new), do: :create
  defp live_action_to_ash_action(:edit), do: :update
end

defmodule GarageWeb.BuildLive.FormComponent do
  use GarageWeb, :live_component
  # alias Garage.Builds.Build
  # alias Garage.Mopeds.Make
  # alias Garage.Mopeds.Model
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
    form = Form.for_action(Build, live_action_to_ash_action(socket.assigns.live_action))
    changeset = Builds.change_build(build)
    make_options = make_options()

    # if we already have a make set, show the model dropdown
    model_options =
      if make_id = Ecto.Changeset.get_change(changeset, :make_id) do
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
        %{"id" => "build_make" <> _ = id, "text" => text},
        socket
      ) do
    options = search_options(socket.assigns.make_options, text)
    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => "build_model" <> _ = id, "text" => text},
        socket
      ) do
    options = search_options(socket.assigns.model_options, text)
    send_update(LiveSelect.Component, options: options, id: id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "build_make" <> _ = id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.make_options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "build_model" <> _ = id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.model_options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"build" => build_params}, socket) do
    changeset =
      socket.assigns.build
      |> Builds.change_build(build_params)
      |> Map.put(:action, :validate)

    socket =
      if make_id = Ecto.Changeset.get_change(changeset, :make_id) do
        assign(socket, :model_options, model_options_by_id(make_id))
      else
        socket
      end

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"build" => build_params}, socket) do
    save_build(socket, socket.assigns.action, build_params)
  end

  defp save_build(socket, :edit, build_params) do
    case Builds.update_build(socket.assigns.build, build_params) do
      {:ok, build} ->
        {:noreply,
         socket
         |> put_flash(:info, "Build updated successfully")
         |> push_navigate(to: ~p"/builds/#{build}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_build(socket, :new, build_params) do
    # We only set this on the server side to be safe
    build_params = Map.put(build_params, "user_id", socket.assigns.current_user.id)

    case Builds.create_build(build_params) do
      {:ok, build} ->
        {:noreply,
         socket
         |> put_flash(:info, "Build created successfully")
         |> push_navigate(to: ~p"/builds/#{build}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
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

  defp make_options() do
    for make <- Make.read_all(), into: [], do: {make.name, make.id}
  end

  defp model_options_by_id(make_id) do
    for model <- Model.by_make_id(make_id), into: [], do: {model.name, model.id}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp live_action_to_ash_action(:new), do: :create
  defp live_action_to_ash_action(:edit), do: :update
end

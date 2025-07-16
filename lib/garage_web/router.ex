defmodule GarageWeb.Router do
  use GarageWeb, :router
  use AshAuthentication.Phoenix.Router

  import AshAdmin.Router
  import AshAuthentication.Plug.Helpers
  import Oban.Web.Router

  require Logger

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GarageWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :admin do
    plug :admin_required
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  scope "/" do
    pipe_through :browser
    pipe_through :admin

    oban_dashboard "/oban"
    ash_admin "/admin"
  end

  scope "/", GarageWeb do
    pipe_through :browser

    ash_authentication_live_session :authentication_required,
      on_mount: {GarageWeb.LiveUserAuth, :live_user_required} do
      live "/builds/new", BuildsLive.New, :new
      live "/builds/:build/edit", BuildsLive.Edit, :edit
      live "/carburetors", CarburetorLive.Index, :index
      live "/carburetors/new", CarburetorLive.Index, :new
      live "/carburetors/:id", CarburetorLive.Show, :show
      live "/carburetors/:id/edit", CarburetorLive.Index, :edit
      live "/carburetors/:id/show/edit", CarburetorLive.Show, :edit
      live "/clutches", ClutchLive.Index, :index
      live "/clutches/new", ClutchLive.Index, :new
      live "/clutches/:id", ClutchLive.Show, :show
      live "/clutches/:id/edit", ClutchLive.Index, :edit
      live "/clutches/:id/show/edit", ClutchLive.Show, :edit
      live "/cranks", CrankLive.Index, :index
      live "/cranks/new", CrankLive.Index, :new
      live "/cranks/:id", CrankLive.Show, :show
      live "/cranks/:id/edit", CrankLive.Index, :edit
      live "/cranks/:id/show/edit", CrankLive.Show, :edit
      live "/cylinders", CylinderLive.Index, :index
      live "/cylinders/new", CylinderLive.Index, :new
      live "/cylinders/:id", CylinderLive.Show, :show
      live "/cylinders/:id/edit", CylinderLive.Index, :edit
      live "/cylinders/:id/show/edit", CylinderLive.Show, :edit
      live "/engines", EngineLive.Index, :index
      live "/engines/new", EngineLive.Index, :new
      live "/engines/:id", EngineLive.Show, :show
      live "/engines/:id/edit", EngineLive.Show, :edit
      live "/engines/:id/show/edit", EngineLive.Show, :edit
      live "/exhausts", ExhaustLive.Index, :index
      live "/exhausts/new", ExhaustLive.Index, :new
      live "/exhausts/:id", ExhaustLive.Show, :show
      live "/exhausts/:id/edit", ExhaustLive.Index, :edit
      live "/exhausts/:id/show/edit", ExhaustLive.Show, :edit
      live "/ignitions", IgnitionLive.Index, :index
      live "/ignitions/new", IgnitionLive.Index, :new
      live "/ignitions/:id", IgnitionLive.Show, :show
      live "/ignitions/:id/edit", IgnitionLive.Index, :edit
      live "/ignitions/:id/show/edit", IgnitionLive.Show, :edit
      live "/manufacturers", ManufacturerLive.Index, :index
      live "/manufacturers/new", ManufacturerLive.Index, :new
      live "/manufacturers/:id", ManufacturerLive.Show, :show
      live "/manufacturers/:id/edit", ManufacturerLive.Index, :edit
      live "/manufacturers/:id/show/edit", ManufacturerLive.Show, :edit
      live "/models", ModelLive.Index, :index
      live "/models/new", ModelLive.Index, :new
      live "/models/:id", ModelLive.Show, :show
      live "/models/:id/edit", ModelLive.Index, :edit
      live "/models/:id/show/edit", ModelLive.Show, :edit
      live "/parts", PartsLive.Index, :index
      live "/pulleys", PulleyLive.Index, :index
      live "/pulleys/new", PulleyLive.Index, :new
      live "/pulleys/:id", PulleyLive.Show, :show
      live "/pulleys/:id/edit", PulleyLive.Index, :edit
      live "/pulleys/:id/show/edit", PulleyLive.Show, :edit
      live "/user/settings", UsersLive.Settings, :settings
      live "/variators", VariatorLive.Index, :index
      live "/variators/new", VariatorLive.Index, :new
      live "/variators/:id", VariatorLive.Show, :show
      live "/variators/:id/edit", VariatorLive.Index, :edit
      live "/variators/:id/show/edit", VariatorLive.Show, :edit
    end

    ash_authentication_live_session :no_user,
      on_mount: {GarageWeb.LiveUserAuth, :live_no_user} do
      live "/register", AuthLive.Index, :register
      live "/sign-in", AuthLive.Index, :sign_in
      live "/password-reset", AuthLive.Reset, :reset_request
      live "/password-reset/:token", AuthLive.Reset, :reset
    end

    sign_out_route AuthController
    auth_routes AuthController, Garage.Accounts.User, path: "/auth"

    ash_authentication_live_session :authentication_optional,
      on_mount: {GarageWeb.LiveUserAuth, :live_user_optional} do
      live "/", HomeLive.Index, :index

      live "/builds", BuildsLive.Index, :index
      live "/builds/:build", BuildsLive.Show, :show

      live "/about", HomeLive.About, :about
      live "/privacy", HomeLive.Privacy, :privacy
      live "/u/:username", UsersLive.Show, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", GarageWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:garage, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GarageWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  def admin_required(conn, _opts) do
    if conn.assigns[:current_user] &&
         Ash.CiString.compare(conn.assigns.current_user.email, "admin@moped.club") do
      conn
    else
      Logger.debug(
        "User is not an admin, tried to access the admin console #{inspect(conn.assigns.current_user)}"
      )

      conn
      |> put_flash(:error, "You must be an admin to access this page")
      |> redirect(to: "/")
      |> halt()
    end
  end
end

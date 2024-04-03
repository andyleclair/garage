defmodule GarageWeb.Router do
  use GarageWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GarageWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", GarageWeb do
    pipe_through :browser

    ash_authentication_live_session :authentication_required,
      on_mount: {GarageWeb.LiveUserAuth, :live_user_required} do
      live "/builds/:build/edit", BuildsLive.Edit, :edit
      live "/builds/new", BuildsLive.New, :new
      live "/carburetors/:id/edit", CarburetorLive.Index, :edit
      live "/carburetors/:id/show/edit", CarburetorLive.Show, :edit
      live "/carburetors/new", CarburetorLive.Index, :new
      live "/clutches/:id/edit", ClutchLive.Index, :edit
      live "/clutches/:id/show/edit", ClutchLive.Show, :edit
      live "/clutches/new", ClutchLive.Index, :new
      live "/cranks/:id/edit", CrankLive.Index, :edit
      live "/cranks/:id/show/edit", CrankLive.Show, :edit
      live "/cranks/new", CrankLive.Index, :new
      live "/engines/:id/edit", EngineLive.Show, :edit
      live "/engines/:id/show/edit", EngineLive.Show, :edit
      live "/engines/new", EngineLive.Index, :new
      live "/exhausts/:id/edit", ExhaustLive.Index, :edit
      live "/exhausts/:id/show/edit", ExhaustLive.Show, :edit
      live "/exhausts/new", ExhaustLive.Index, :new
      live "/manufacturers/:id/edit", ManufacturerLive.Index, :edit
      live "/manufacturers/:id/show/edit", ManufacturerLive.Show, :edit
      live "/manufacturers/new", ManufacturerLive.Index, :new
      live "/models/:id/edit", ModelLive.Index, :edit
      live "/models/:id/show/edit", ModelLive.Show, :edit
      live "/models/new", ModelLive.Index, :new
      live "/user/settings", UsersLive.Settings, :settings
    end

    ash_authentication_live_session :no_user,
      on_mount: {GarageWeb.LiveUserAuth, :live_no_user} do
      live "/register", AuthLive.Index, :register
      live "/sign-in", AuthLive.Index, :sign_in
      live "/password-reset", AuthLive.Reset, :reset_request
      live "/password-reset/:token", AuthLive.Reset, :reset
    end

    sign_out_route AuthController
    auth_routes_for Garage.Accounts.User, to: AuthController

    ash_authentication_live_session :authentication_optional,
      on_mount: {GarageWeb.LiveUserAuth, :live_user_optional} do
      live "/", HomeLive.Index, :index
      live "/builds", BuildsLive.Index, :index
      live "/builds/:build", BuildsLive.Show, :show

      live "/manufacturers", ManufacturerLive.Index, :index
      live "/manufacturers/:id", ManufacturerLive.Show, :show

      live "/carburetors", CarburetorLive.Index, :index
      live "/carburetors/:id", CarburetorLive.Show, :show

      live "/models", ModelLive.Index, :index

      live "/models/:id", ModelLive.Show, :show

      live "/engines", EngineLive.Index, :index
      live "/engines/:id", EngineLive.Show, :show

      live "/clutches", ClutchLive.Index, :index
      live "/clutches/:id", ClutchLive.Show, :show

      live "/cranks", CrankLive.Index, :index
      live "/cranks/:id", CrankLive.Show, :show

      live "/exhausts", ExhaustLive.Index, :index
      live "/exhausts/:id", ExhaustLive.Show, :show
      # This one _needs_ to be last
      live "/:username", UsersLive.Show, :show
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
end

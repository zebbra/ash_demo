defmodule AshDemoWeb.Router do
  use AshDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AshDemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AshDemoWeb do
    pipe_through :browser

    get "/", PageController, :home

    scope "/admin", Admin do
      live_session :admin, layout: {AshDemoWeb.Layouts, :admin}, on_mount: AshDemoWeb.AssignUser do
        # Posts
        live "/posts", PostLive.Index, :index
        live "/posts/new", PostLive.Index, :new
        live "/posts/:id/edit", PostLive.Index, :edit
        live "/posts/:id", PostLive.Show, :show
        live "/posts/:id/show/edit", PostLive.Show, :edit

        # Categories
        live "/categories", CategoryLive.Index, :index
        live "/categories/new", CategoryLive.Index, :new
        live "/categories/:id/edit", CategoryLive.Index, :edit
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AshDemoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ash_demo, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AshDemoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

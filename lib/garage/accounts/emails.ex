defmodule Garage.Accounts.Emails do
  @moduledoc """
  Delivers emails.
  """

  import Swoosh.Email

  def deliver_reset_password_instructions(user, url) do
    if !url do
      raise "Cannot deliver reset instructions without a url"
    end

    deliver(user.email, "Password Reset Email", %{"password_reset_url" => url})
  end

  defp deliver(to, template_name, params) do
    new()
    |> from({"Moped.Build Admin", "admin@moped.build"})
    |> to(to_string(to))
    |> put_provider_option(:track_links, "None")
    |> put_provider_option(:custom_vars, params)
    |> put_provider_option(:template_name, template_name)
    |> Garage.Mailer.deliver!()
  end
end

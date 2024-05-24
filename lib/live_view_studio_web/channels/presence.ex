defmodule LiveViewStudioWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :live_view_studio,
    pubsub_server: LiveViewStudio.PubSub

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, topic)
  end

  def track_user(user, topic, meta_map) do
    username = user.email |> String.split("@") |> hd()
    meta_map = Map.put_new(meta_map, :username, username)
    track(self(), topic, user.id, %{meta_map | username: username})
  end

  def update_user(user, topic, meta_update) do
    %{metas: [meta | _]} = get_by_key(topic, user.id)
    new_meta = Map.merge(meta, meta_update)
    update(self(), topic, user.id, new_meta)
  end

  @doc """
  Removes repeat instances of users from the presences map and flattens it
  """
  def list_unique_users(topic) do
    presences = list(topic)
    dedupe_presence_map(presences)
  end

  def dedupe_presence_map(presences) do
    Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} ->
      {user_id, meta}
    end)
  end

  def handle_diff(socket, diff) do
    socket
    |> remove_presences(diff.leaves)
    |> add_presences(diff.joins)
  end

  defp remove_presences(socket, leaves) do
    user_ids = Enum.map(leaves, fn {user_id, _meta} -> user_id end)
    presences = Map.drop(socket.assigns.presences, user_ids)
    Phoenix.Component.assign(socket, :presences, presences)
  end

  defp add_presences(socket, joins) do
    joins = dedupe_presence_map(joins)
    presences = Map.merge(socket.assigns.presences, joins)
    Phoenix.Component.assign(socket, :presences, presences)
  end
end

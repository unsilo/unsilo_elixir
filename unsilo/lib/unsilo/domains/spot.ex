defmodule Unsilo.Domains.Spot do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  use Arc.Ecto.Schema

  alias Unsilo.Repo
  alias Unsilo.Accounts.User
  alias Unsilo.Domains.Subscriber

  schema "spots" do
    field(:description, :string)
    field(:domains, {:array, :string})
    field(:name, :string)
    field(:tagline, :string)
    field(:theme, :string)
    field(:background_color, :string)
    field(:user_id, :integer)
    field(:count, :integer, default: 0)
    field(:logo, Unsilo.Logo.Type)
    field(:allow_subscriptions, :boolean)

    has_many(:subscribers, Subscriber)

    timestamps()
  end

  def for_user(%User{id: user_id}) do
    Unsilo.Domains.Spot
    |> where([s], s.user_id == ^user_id)
    |> order_by(desc: :updated_at)
    |> Repo.all()
    |> Repo.preload([:subscribers])
  end

  def for_domain(domain) do
    Unsilo.Repo.one(
      from(s in Unsilo.Domains.Spot,
        where: ^domain in s.domains,
        select: s
      )
    )
  end

  @doc false
  def no_image_changeset(spot, attrs) do
    spot
    |> cast(fix_domains(attrs), [
      :name,
      :background_color,
      :domains,
      :user_id,
      :description,
      :tagline
    ])
    |> validate_required([:domains, :user_id])
  end

  def image_only_changeset(spot, attrs) do
    spot
    |> cast_attachments(attrs, [:logo])
  end

  def changeset(spot, attrs) do
    spot
    |> cast(fix_domains(attrs), [
      :name,
      :domains,
      :background_color,
      :allow_subscriptions,
      :user_id,
      :description,
      :tagline
    ])
    |> cast_attachments(attrs, [:logo])
    |> validate_required([:domains, :user_id])
  end

  defp fix_domains(%{"domains" => domains} = prms) when is_binary(domains) do
    Map.put(prms, "domains", String.split(domains, "\r\n"))
  end

  defp fix_domains(%{domains: domains} = prms) when is_binary(domains) do
    Map.put(prms, :domains, String.split(domains, "\r\n"))
  end

  defp fix_domains(%{domains: domains} = prms) when is_list(domains) do
    prms
  end

  defp fix_domains(prms) do
    prms
  end
end

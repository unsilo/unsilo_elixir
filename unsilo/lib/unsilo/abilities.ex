defimpl Canada.Can, for: Unsilo.Accounts.User do
  alias Unsilo.Accounts.User
  alias Unsilo.Domains.Spot
  alias Unsilo.Feeds.River
  alias Unsilo.Feeds.Feed
  alias Unsilo.Feeds.Story

  def can?(%User{id: nil}, action, User)
      when action in [:new, :create],
      do: true

  def can?(%User{role: :admin}, _action, %Spot{}), do: true
  def can?(%User{role: :admin}, _action, %User{}), do: true

  def can?(%User{id: user_id}, action, %Story{user_id: user_id})
      when action in [:show, :edit, :delete, :update],
      do: true

  def can?(%User{id: user_id}, action, %Feed{user_id: user_id})
      when action in [:show, :edit, :delete, :update],
      do: true

  def can?(%User{id: user_id}, action, %River{user_id: user_id})
      when action in [:show, :edit, :delete, :update],
      do: true

  def can?(%User{id: nil}, action, %River{access: :public})
      when action in [:show],
      do: true

  def can?(%User{id: user_id}, action, %Spot{user_id: user_id})
      when action in [:show, :edit, :delete, :update],
      do: true

  def can?(%User{id: user_id}, action, %User{id: user_id})
      when action in [:show, :edit, :delete, :update],
      do: true

  def can?(%User{id: _user_id}, _, _), do: false
end

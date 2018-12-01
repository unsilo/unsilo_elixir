defimpl Canada.Can, for: Unsilo.Accounts.User do
  alias Unsilo.Accounts.User
  alias Unsilo.Domains.Spot

  def can?(%User{id: nil}, action, User)
      when action in [:new, :create],
      do: true

  def can?(%User{role: :admin}, _action, %Spot{}), do: true
  def can?(%User{role: :admin}, _action, %User{}), do: true

  def can?(%User{id: user_id}, action, %Spot{user_id: user_id})
      when action in [:show, :edit, :delete, :update],
      do: true

  def can?(%User{id: user_id}, action, %User{id: user_id})
      when action in [:show, :edit, :delete, :update],
      do: true

  def can?(%User{id: _user_id}, _, _), do: false
end

class AddInvitationFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :invitation_token, :string
    add_index :users, :invitation_token, unique: true
    add_column :users, :invitation_sent_at, :datetime
    add_column :users, :invitation_accepted_at, :datetime

    # Allow password_digest to be null for invited users who haven't set password yet
    change_column_null :users, :password_digest, true
  end
end

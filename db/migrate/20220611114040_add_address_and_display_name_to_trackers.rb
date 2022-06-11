class AddAddressAndDisplayNameToTrackers < ActiveRecord::Migration[6.1]
  def change
    add_column :trackers, :address, :json
    add_column :trackers, :display_name, :string
  end
end

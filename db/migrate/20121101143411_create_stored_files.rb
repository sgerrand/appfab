class CreateStoredFiles < ActiveRecord::Migration
  def self.up
    create_table :stored_files do |t|
      t.binary   :blob, :limit => (16.megabytes - 1)
      t.text     :metadata
      t.datetime :accessed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :stored_files
  end
end

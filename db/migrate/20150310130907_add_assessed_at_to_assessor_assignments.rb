class AddAssessedAtToAssessorAssignments < ActiveRecord::Migration
  def change
    add_column :assessor_assignments, :assessed_at, :datetime
  end
end

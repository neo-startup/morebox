class AddReportDateToReports < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :report_date, :string
  end
end

Fabricator(:date_range) do
  user
  start_date  { Date.today }
  end_date    2.days.from_now
  created_by  'alpha'
end

# Clear existing data (keep departments, teams, and call_scripts)
puts "Clearing user data..."
RefreshToken.destroy_all
Evaluation.destroy_all
CallRecording.destroy_all

# Remove supervisors from teams before deleting users
Team.update_all(supervisor_id: nil)

User.destroy_all

# Get existing teams for assignment
sales_team = Team.find_by(name: "Sales Team Alpha")
bank_team = Team.find_by(name: "Bank Support Team")

# Create Admin
puts "Creating admin..."
admin = User.create!(
  email: "admin@example.com",
  name: "Admin User",
  password: "test2025",
  password_confirmation: "test2025",
  role: :admin,
  admin: true
)

# Create Manager
puts "Creating manager..."
manager = User.create!(
  email: "manager@example.com",
  name: "Manager User",
  password: "test2025",
  password_confirmation: "test2025",
  role: :manager,
  admin: false
)

# Create Supervisors
puts "Creating supervisors..."
supervisor1 = User.create!(
  email: "supervisor1@example.com",
  name: "Supervisor One",
  password: "test2025",
  password_confirmation: "test2025",
  role: :supervisor,
  team: sales_team,
  admin: false
)

supervisor2 = User.create!(
  email: "supervisor2@example.com",
  name: "Supervisor Two",
  password: "test2025",
  password_confirmation: "test2025",
  role: :supervisor,
  team: bank_team,
  admin: false
)

# Update teams with supervisors
sales_team&.update(supervisor: supervisor1)
bank_team&.update(supervisor: supervisor2)

# Create Operators
puts "Creating operators..."
5.times do |i|
  team = i < 3 ? sales_team : bank_team
  User.create!(
    email: "user#{i + 1}@example.com",
    name: "Operator #{i + 1}",
    password: "test2025",
    password_confirmation: "test2025",
    role: :operator,
    team: team,
    admin: false
  )
end

puts "\n✅ Seed data created successfully!"
puts "\nLogin credentials (all passwords: test2025):"
puts "\n📌 Administrator:"
puts "  Email: admin@example.com"
puts "  Password: test2025"
puts "\n📌 Manager:"
puts "  Email: manager@example.com"
puts "  Password: test2025"
puts "\n📌 Supervisors:"
puts "  Email: supervisor1@example.com (Sales Team)"
puts "  Email: supervisor2@example.com (Bank Team)"
puts "  Password: test2025"
puts "\n📌 Operators:"
puts "  Email: user1@example.com - user5@example.com"
puts "  Password: test2025"
puts "\nTotal users created: #{User.count}"

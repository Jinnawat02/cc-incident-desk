seed_password = ENV["SEED_USER_PASSWORD"]

if seed_password.blank?
  puts "Skipping user seeds: set SEED_USER_PASSWORD to create demo users."
else
  { "customer@example.com" => :customer, "agent@example.com" => :agent }.each do |email_address, role|
    User.find_or_create_by!(email_address: email_address) do |user|
      user.password = seed_password
      user.role = role
    end
  end
end

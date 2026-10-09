namespace :users do
  desc "Create a user with a role (customer or agent). Password comes from USER_PASSWORD or a hidden prompt."
  task :create, %i[ email role ] => :environment do |_task, args|
    email, role = args[:email].to_s, args[:role].to_s
    abort %(Usage: bin/rails "users:create[email,role]") if email.blank? || role.blank?
    abort %(Unknown role "#{role}". Use #{Role::NAMES.join(" or ")}.) unless Role::NAMES.include?(role)
    abort "#{User.normalize_value_for(:email_address, email)} is already taken." if User.exists?(email_address: email)

    password = ENV["USER_PASSWORD"].presence || begin
      require "io/console"
      print "Password: "
      $stdin.noecho(&:gets).to_s.chomp.tap { puts }
    rescue Errno::ENOTTY
      abort "\nNo terminal to prompt for a password on. Set USER_PASSWORD instead."
    end

    user = User.new(email_address: email, password: password, role: role)
    abort user.errors.full_messages.to_sentence unless user.save

    puts "Created #{user.role} #{user.email_address}"
  end
end

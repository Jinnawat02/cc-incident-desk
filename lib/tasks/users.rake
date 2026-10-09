namespace :users do
  desc "Create a user, e.g. bin/rails \"users:create[agent@example.com,agent]\". " \
       "The password comes from the PASSWORD environment variable, or a hidden prompt when it's unset."
  task :create, [ :email, :role ] => :environment do |_task, args|
    email, role = args[:email], args[:role]

    abort %(Usage: bin/rails "users:create[EMAIL,ROLE]" (ROLE is #{User::ROLES.join(" or ")})) if email.blank? || role.blank?
    abort "Unknown role \"#{role}\". Use #{User::ROLES.join(" or ")}." unless User::ROLES.include?(role)
    abort "A user with the email #{email} already exists." if User.exists?(email_address: User.normalize_value_for(:email_address, email))

    password = ENV["PASSWORD"].presence || begin
      require "io/console"
      abort "Set the PASSWORD environment variable, or run this task in an interactive terminal." unless $stdin.tty?

      prompt = ->(label) { $stdin.getpass("#{label}: ") }
      prompt.("Password").tap do |entered|
        abort "Passwords don't match." unless prompt.("Confirm password") == entered
      end
    end

    user = User.new(email_address: email, password: password)
    user.add_role(role)

    if user.save
      puts "Created #{role} #{user.email_address}."
    else
      abort "Couldn't create user: #{user.errors.full_messages.to_sentence}."
    end
  end
end

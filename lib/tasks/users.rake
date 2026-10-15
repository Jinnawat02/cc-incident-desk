namespace :users do
  desc "Create a user with a role (customer or agent). Reads the password from PASSWORD, or prompts for it"
  task :create, %i[ email role ] => :environment do |_task, args|
    require "io/console"

    abort "Usage: bin/rails \"users:create[email,role]\"" if args[:email].blank? || args[:role].blank?

    password = ENV.fetch("PASSWORD") { $stdin.getpass("Password: ") }
    user = User.new(email_address: args[:email], role: args[:role], password: password)

    if user.save
      puts "Created #{user.role} #{user.email_address}"
    else
      abort user.errors.full_messages.to_sentence
    end
  end
end

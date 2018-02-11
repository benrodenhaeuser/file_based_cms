require 'bcrypt'

class PasswordDigester
  def self.encrypt(password)
    BCrypt::Password.create(password)
  end

  def self.check?(password, encrypted_password)
    BCrypt::Password.new(encrypted_password) == password
  end
end

puts encrypted = PasswordDigester.encrypt('secret')
puts encrypted2 = PasswordDigester.encrypt('password')


puts PasswordDigester.check?('secret', encrypted)

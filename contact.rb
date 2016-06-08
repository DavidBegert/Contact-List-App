require 'pg'
require 'colorize'
require 'active_record'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
puts 'Establishing connection to database ...'
ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'contacts',
  username: 'development',
  password: 'development',
  host: 'localhost',
  port: 5432,
  pool: 5,
  encoding: 'unicode',
  min_messages: 'error'
)
puts 'CONNECTED'

class Contact < ActiveRecord::Base

end

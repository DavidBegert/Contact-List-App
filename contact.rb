require 'pg'
require 'colorize'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  attr_accessor :name, :email
  attr_reader :id

  @@conn = PG.connect(
    host: 'localhost',
    dbname: 'contacts',
    user: 'development',
    password: 'development'
  )
  
  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(name, email, id = nil)
    @name = name
    @email = email
    @id = id
  end

  def save
    if id
      @@conn.exec_params('UPDATE contacts SET name = $1, email = $2 WHERE id = $3;', [name, email, id])
    else
      return_value = @@conn.exec_params('INSERT INTO contacts (name, email) VALUES ($1, $2) RETURNING id;', [name, email]) #id is updated automatically in database
      id = return_value[0]["id"].to_i
    end
  end

  def destroy
    @@conn.exec_params('DELETE FROM contacts WHERE id = $1::int', [id])
  end

  # Provides functionality for managing contacts in the csv file.
  class << self

    # Opens 'contacts.csv' and creates a Contact object for each line in the file (aka each contact).
    # @return [Array<Contact>] Array of Contact objects
    def all
      # TODO: Return an Array of Contact instances made from the data in 'contacts.csv'.
      arr = []
      @@conn.exec('SELECT * FROM contacts ORDER BY id;').each do |contact|
        arr << Contact.new(contact["name"], contact["email"], contact["id"].to_i)
      end
      arr
    end

    # Creates a new contact, adding it to the csv file, returning the new contact.
    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(name, email)
      # TODO: Instantiate a Contact, add its data to the 'contacts.csv' file, and return it.
      contact = Contact.new(name, email)
      contact.save
      contact
    end
    
    # Find the Contact in the 'contacts.csv' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      # TODO: Find the Contact in the 'contacts.csv' file with the matching id.
      #return contact with that id
      begin
        row_hash = @@conn.exec_params('SELECT * FROM contacts WHERE id = $1;', [id])[0]
        Contact.new(row_hash["name"], row_hash["email"], row_hash["id"].to_i)
      rescue IndexError
      end
    end
    
    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.
    def search(term)
      # TODO: Select the Contact instances from the 'contacts.csv' file whose name or email attributes contain the search term.
      arr_of_match_contacts = []
      array_of_hashes = @@conn.exec_params('SELECT * FROM contacts WHERE name LIKE $1::varchar OR email LIKE $1::varchar;', ["%#{term}%"])
      array_of_hashes.each do |contact|
        arr_of_match_contacts << Contact.new(contact["name"], contact["email"], contact["id"].to_i)
      end
      arr_of_match_contacts
    end

    def find_by_name(name)
      begin
        row_hash = @@conn.exec_params('SELECT * FROM contacts WHERE name = $1;', [name])[0]
        Contact.new(row_hash["name"], row_hash["email"], row_hash["id"].to_i)
      rescue IndexError
      end
    end

    def find_by_email(email)
      begin
        row_hash = @@conn.exec_params('SELECT * FROM contacts WHERE email = $1;', [email])[0]
        Contact.new(row_hash["name"], row_hash["email"], row_hash["id"].to_i)
      rescue IndexError
      end
    end

  end

end

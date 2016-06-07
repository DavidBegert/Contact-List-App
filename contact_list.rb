require_relative 'contact'

# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList
  def run(argv)
    if argv.size == 0
      puts menu
    else
      begin
        command = argv.shift
        self.send("do_#{command}", *argv)
      rescue NoMethodError
        puts "That is not a valid command."
        puts menu
      rescue ArgumentError
        puts "Wrong number of commands given."
        puts menu
      end
    end
  end
  
  private
  def do_list
      contact_array = Contact.all
      contact_array.each do |contact|
        puts "#{contact.id}: #{contact.name} (#{contact.email})"
      end
  end

  def do_new
    puts "Enter the name: "
    name = STDIN.gets.chomp
    puts "Enter the email: "
    email = STDIN.gets.chomp
    email_exists = Contact.all.detect do |contact|
      contact.email == email
    end
    if email_exists
      puts "That email address already exists.".red
    else
      Contact.create(name, email)
      puts "Contact Created Successfully".green
    end
  end

  def find_contact_to_use(*arguments)
    first_argument = arguments[0]
    if first_argument.to_i != 0
      id = first_argument.to_i
      Contact.find(id)
    elsif first_argument.include?('@')
      Contact.find_by_email(first_argument)
    elsif arguments.size >= 2
      Contact.find_by_name(first_argument + ' ' + arguments[1])
    else
      raise ArgumentError, 'Invalid User Input'
    end
  end

  def do_update(*arguments)
    contact_to_update = find_contact_to_use(*arguments)
    if contact_to_update
      puts "Enter #{contact_to_update.name}'s new name: "
      new_name = STDIN.gets.chomp
      contact_to_update.name = new_name
      puts "Enter #{contact_to_update.name}'s new email: "
      new_email = STDIN.gets.chomp
      contact_to_update.email = new_email
      contact_to_update.save
    else
      puts "That contact does not exist".red
    end
  end

  def do_delete(*arguments)
    contact_to_destroy = find_contact_to_use(*arguments)
    if contact_to_destroy
      contact_to_destroy.destroy
      puts "Contact deleted successfully".green
    else
      puts "That contact does not exist".red
    end
  end

  def do_show(*arguments)
    contact = find_contact_to_use(*arguments)
    if contact
      puts contact.name
      puts contact.email
    else
      puts "That contact does not exist".red
    end
  end

  def do_search(term)
    arr_of_contacts = Contact.search(term)
    arr_of_contacts.each do |contact|
      puts "#{contact.id}: #{contact.name} (#{contact.email})"
    end
    puts "------------------\n#{arr_of_contacts.size} record(s) total"
  end

  def menu
    "Here is a list of available commands:
      new                                - Create a new contact
      list                               - List all contacts
      show {<id>, <fullname>, <email>}   - Show a contact
      search <term>                      - Search contacts
      delete {<id>, <fullname>, <email>} - Delete a contact
      update {<id>, <fullname>, <email>} - Update an existing contact"
  end

end #end of class contactList

ContactList.new.run(ARGV)    

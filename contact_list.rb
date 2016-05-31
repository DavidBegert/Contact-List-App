require_relative 'contact'

# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  def initialize(argv)
    @argv = argv
  end

  def run 
    if @argv.size == 0
      puts menu
    else
      begin
        self.send("do_#{@argv[0]}")
      rescue NoMethodError
        puts "That is not a valid command."
      end
    end
  end

  def do_list
      contact_array = Contact.all
      contact_array.each_with_index do |contact, i|
        puts "#{i + 1}: #{contact.name} (#{contact.email})"
      end
  end

  def do_new
    puts "Enter the name: "
    namer = STDIN.gets.chomp
    puts "Enter the email: "
    email = STDIN.gets.chomp
    Contact.create(namer, email)
  end

  def do_show
    id = @argv[1].to_i
    contact = Contact.find(id)
    puts contact.name
    puts contact.email
  end

  def do_search
    term = @argv[1]
    arr_of_contacts = Contact.search(term)
    arr_of_contacts.each do |contact|
      puts "#{contact.id}: #{contact.name} (#{contact.email})"
    end
    puts "------------------
#{arr_of_contacts.size} record(s) total"
  end

  def menu
    return "Here is a list of available commands:
      new     - Create a new contact
      list    - List all contacts
      show    - Show a contact
      search  - Search contacts"
  end

end #end of class contactList

ContactList.new(ARGV).run    

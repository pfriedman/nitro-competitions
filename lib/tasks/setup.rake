namespace :setup do

  desc 'Creates an applicant, an admin, and a reviewer user, plus a sponsor and a competition'
  task :demo => [:create_users, :create_sponsor] do
    puts 'ran setup:demo'
  end


  desc 'Creates a user, an admin, and a reviewer' 
  task :create_users => :environment do 
    [
      %w(user Test User test-user@example.edu),
      %w(admin Admin User admin-user@example.edu),
      %w(reviewer Reviewer User reviewer-user@example.edu),
    ].each do |arr|
      find_or_create_user(arr)
    end
  end

  ##
  # Update this information for your sponsor and competition then run
  # $ rake sponsor:create
  desc 'Example of how to setup a new sponsor and competition' 
  task :create_sponsor => :environment do
    program = Program.create program_title:          'Sponsor Name',                          # the name of the people running the competition
                             program_name:           'SN',                                    # an abbreviation for the above
                             program_url:            'http://www.example.edu/sponsor/'        # URL to the website for the sponsor

    puts "=> created sponsor #{program.program_title}"
    project = Project.new project_title:             'Sponsor Pilot Program',                 # the name of the competition
                          project_url:               'http://www.example.edu/sponsor/pilot',  # URL to the website for the competition
                          project_name:              'sponsor_pilot_2015',                    # this is the SEO name - no spaces!
                          initiation_date:           '01-NOV-2014',                           # the date the competition shows on the website
                          submission_open_date:      '01-NOV-2014',                           # the date when submissions are accepted
                          submission_close_date:     '31-MAR-2015',                           # the date when submissions are no longer accepted
                          review_start_date:         '01-NOV-2014',                           # the date when reviews start
                          review_end_date:           '31-AUG-2015',                           # the date when reviews should be completed
                          project_period_start_date: '01-NOV-2014',                           # the date when the project starts (informational only)
                          project_period_end_date:   '31-DEC-2015',                           # the date when the project ends   (informational only)
                          program_id: program.id
    project.save!
    puts "=> created competition #{project.project_title}"
    
    admin = User.where(username: 'admin').first
    create_admin_role(admin, program) if admin && program
  end

  ##
  # Create a new RolesUser record for each user in the
  # given users array where the Role is Admin for the given program
  # The users array should be an array with 
  # username, first name, last name, and email
  # @see find_or_create_user
  # @param [Array<Array>] users
  # @param [Program]
  def create_admins_for_program(users, program)
    users.each do |arr|
      user = find_or_create_user(arr)
      create_admin_role(user, program) if user && program
    end
  end

  ##
  # Create an RolesUser record with an Admin Role for the 
  # given User and Program
  # @param[User]
  # @param[Program]
  def create_admin_role(user, program)
    if user.roles_users.for_program(program.id).blank?
      ru = RolesUser.new
      ru.user = user
      ru.role = admin_role
      ru.program = program
      ru.save!
      puts "=> created admin role for #{user.name}"
    end
  end

  ##
  # Get the Admin Role record
  # @return[Role]
  def admin_role
    @admin ||= Role.where(name: 'Admin').first
  end

  ##
  # @param[Array<String>] 
  # @return[User]
  def find_or_create_user(arr)
    user = User.where(username: arr[0]).first
    if user.blank?
      user = User.create username: arr[0],
                         first_name: arr[1],
                         last_name: arr[2],
                         email: arr[3]
      puts "=> created user #{user.name}"
    end
    user
  end

end
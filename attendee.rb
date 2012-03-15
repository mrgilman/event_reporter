class Attendee
  attr_accessor :regdate, :first_name, :last_name, :email_address, :homephone, :street, :city, :state, :zipcode

  def initialize(line)
    self.regdate = line[:regdate]
    self.first_name = line[:first_name]
    self.last_name = line[:last_name]
    self.email_address = line[:email_address]
    self.homephone = clean_homephone(line[:homephone])
    self.street = line[:street]
    self.city = line[:city].to_s
    self.state = line[:state].to_s
    self.zipcode = clean_zipcode(line[:zipcode])
  end

  def clean_homephone(homephone)
    homephone = homephone.scan(/\d/).join
  end

  def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')
  end

end


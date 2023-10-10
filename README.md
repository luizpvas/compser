# Comparser

```ruby
module MyApp::Email
  include Comparser

  Email = ::Data.define(:address, :domain)

  def parse(str)
    parse(str, email)
  end

  def email
    map(Email) + match(/[a-zA-Z0-9_-\.+]/) - token('@') + domain
  end

  def domain
  end
end

result = MyApp::Email.parse("user@example.org")

result.success? # => true
resutl.failure? # => false
result.value    # => Myapp::Email[address: "user", domain: "example.org"]
```
# coding: utf-8

User.create!(name: "Sample User",
  email: "sample@email.com",
  password: "password",
  password_confirmation: "password",
  admin: true,
  status: "approval")

# User.create!(name: "Sample User A",
#              email: "sampleA@email.com",
#              password: "password",
#              password_confirmation: "password")
             
# User.create!(name: "Sample User B",
#              email: "sampleB@email.com",
#              password: "password",
#              password_confirmation: "password")

5.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
      email: email,
      password: password,
      password_confirmation: password,
      status: "approval")
end
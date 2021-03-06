# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'
require 'open-uri'

puts 'Cleaning all USERS, SERVICE CATEGORIES, SERVICES, BOOKINGS, REVIEWS and CONDOMINIOS'
Booking.destroy_all
User.destroy_all
ServiceCategory.destroy_all
Condominio.destroy_all

puts '-----------------------------------------------------------------'
puts 'CLEANED: User, service categories, services, bookings, reviews and condominios'
puts '-----------------------------------------------------------------'
puts "Booking: #{Booking.count} Users: #{User.count} Reviews: #{Review.count} 
Services: #{Service.count} Service Categories: #{ServiceCategory.count}
Condominio: #{Condominio.count}"
puts '-----------------------------------------------------------------'

puts 'Creating condominios'

5.times do
    condominio = Condominio.new
    condominio.name = Faker::FunnyName.name
    condominio.save!
end

puts '-----------------------------------------------------------------'
puts "CREATED: #{Condominio.count} condominios"
puts '-----------------------------------------------------------------'

puts 'Creating test user'
puts 'Geocoding his address can take a few seconds... wait!'

test_user = User.new(first_name: "Gabriel", last_name: "Jarbas", address: "Rua Mourato Coelho 1404 Sao Paulo", zip_code: "05417-002
", email: "teste@antonini.co", password: "123456")
@condominios = Condominio.all
test_user.condominio = @condominios.sample
test_user.save!

puts '-----------------------------------------------------------------'
puts "CREATED: #{User.count} test user"
puts '-----------------------------------------------------------------'

user_addresses = ['Rua Doutor Luis Barreto 354 Sao Paulo', 'Rua Daniel Vieira 4508 Sao Paulo',
    'Rua Francisco Inacio Solano 48 Sao Paulo', 'Avenida Nossa Senhora do Sabara 3371 Sao Paulo',
    'Rua Sergio Cardoso 480 Sao Paulo', 'Rua Cantagalo 934 Sao Paulo',
    'Rua Galvao Bueno 412 Sao Paulo', 'Rua Gaspar Viegas 4917 Sao Paulo',
    'Rua Francisca Miquelina 89 Sao Paulo', 'Rua Wisard 370 Sao Paulo' ]

puts "creating users"
puts '-----------------------------------------------------------------'

i = 0
10.times do 
    # puts 'Opening photo for user'
    # Too slow to fetch images but it is working!
    # file = URI.open('https://giantbomb1.cbsistatic.com/uploads/original/9/99864/2419866-nes_console_set.png')
    user = User.new()
    user.first_name = Faker::Name.first_name  
    user.last_name =  Faker::Name.last_name
    puts 'Geocoding his address can take a few seconds... wait!'
    user.address = user_addresses[i]
    i >= user_addresses.count ? i = 0 : i += 1
    user.zip_code = "12345-678"
    user.email = Faker::Internet.email
    # puts 'Adding photo to user'
    # user.photo.attach(io: file, filename: 'user.png', content_type: 'image/png')
    user.password = "123456"
    user.condominio = @condominios.sample
    user.save ? (puts "user ID-#{user.id} SAVED") : (puts "invalid user: #{user.errors.full_messages}")
end

puts '-----------------------------------------------------------------'
puts 'CREATED: Users'
puts '-----------------------------------------------------------------'
puts 'Creating Service Categories'
puts 'Please WAIT as the photos are been uploaded. It is working! ;)'
puts '(your internet sucks though...)'
puts '-----------------------------------------------------------------'

# Definir depois as categorias de serviços que queremos
categories = ["Assistência Técnica", "Aulas", "Autos", "Consultoria",
    "Design e Tecnologia", "Eventos", "Moda e Beleza", "Reformas", "Saúde", "Serviços Domésticos"]
cat_photos = ["1_assistencia_tecnica.png", "2_aulas.png", "3_autos.png", "4_consultoria.png",
    "5_design_e_tecnologia.png", "6_eventos.png", "7_moda_e_beleza.png", "8_reformas.png",
    "9_saude.png", "10_servicos_domesticos.png"]
cat_description = "Milhares de profissionais avaliados por clientes, permitindo você negociar apenas com os melhores."

categories.each_with_index do |category, index|
    new_category = ServiceCategory.new(name: category)
    path = File.join(Rails.root, 'app/assets/images/service_categories', "#{cat_photos[index]}")
    file = URI.open(path)
    new_category.photo.attach(io: file, filename: 'category.png', content_type: 'image/png')
    new_category.description = cat_description
    new_category.save!
    puts "Category ##{index + 1 } saved!"
end

puts '-----------------------------------------------------------------'
puts 'CREATED: Service categories with photos'
puts '-----------------------------------------------------------------'
puts 'Creating services for each user'

@users = User.all
@categories = ServiceCategory.all

@users.each do |user|
    rand(2..10).times do
        # Slow but working
        # puts 'Opening photo for service'
        # file = URI.open('https://giantbomb1.cbsistatic.com/uploads/original/9/99864/2419866-nes_console_set.png')
        service = Service.new
        service.service_category = @categories.sample
        service.name = "#{service.service_category.name} #{Faker::Verb.ing_form}"
        service.description = Faker::Restaurant.description
        service.price = rand(1..400)
        service.time_to_answer = rand(1..7)
        service.disponibility = Faker::Date.between(from: Date.today, to: 8.days.from_now)
        service.user = user
        # puts 'Adding photo to service'
        # service.photo.attach(io: file, filename: 'service.png', content_type: 'image/png')
        service.save ? (puts 'service saved') : (puts "invalid service: #{service.errors.full_messages}")
    end
end

puts '-----------------------------------------------------------------'
puts 'CREATED: Services'
puts '-----------------------------------------------------------------'
puts "Creating bookings"

@services = Service.all

@users.each do |user|
    rand(1..5).times do
        booking = Booking.new
        booking.service = @services.sample
        booking.user = user
        booking.date = Faker::Date.between(from: 10.days.from_now, to: 20.days.from_now)

        # Não sei quais vão ser o status ainda, depois a gente arruma os possiveis
        booking.status = ["Confirmado", "Aguardando confirmação", "Declinado"].sample
        booking.save ? (puts 'booking saved') : (puts "invalid booking: #{booking.errors.full_messages}")
    end
end

puts '-----------------------------------------------------------------'
puts "CREATED: Bookings"
puts '-----------------------------------------------------------------'
puts "Creating reviews"

Booking.all.each do |booking|
    content = Faker::Restaurant.review
    rating = rand(0..5)
    review = Review.new(content: content, rating: rating, booking: booking)
    
    puts "invalid review: #{booking.errors.full_messages}" unless review.valid?

    review.save ? (puts 'review saved') : (puts "invalid review: #{booking.errors.full_messages}")
end

puts '-----------------------------------------------------------------'
puts "CREATED: Reviews"
puts '-----------------------------------------------------------------'

puts "#{User.count } Users have been created"
puts "#{Service.count } Services have been created"
puts "#{Booking.count } Bookings have been created"
puts "#{Review.count} reviews created"
puts "#{ServiceCategory.count} Service Categories have been created"
puts "#{Condominio.count} Condominios have been created"

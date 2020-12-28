class Mutations::AddRider < Mutations::BaseMutation
  null true

  argument :name, String, required: true
  argument :address, String, required: true
  argument :preferences, [ID], required: true # array of ids?

  field :rider, Types::RiderType, null: true
  field :errors, [String], null: false

  def resolve(name:, address:, preferences:)
    matched = Driver.where(id: preferences)

    if matched.length == preferences.length
      {
        rider: nil,
        errors: ['There is an invalid id provided in the preferences.']
      }
    end
    
    rider = Rider.build(name: name, address: address)

    # yikes! TODO: fix.
    matched.each do |driver|
      Preference.create!(
        preferrer: rider,
        preferable: driver
      )
    end

    if rider.save 
      {
        rider: rider,
        errors: []
      }
    else
      {
        rider: nil,
        errors: rider.errors.full_messages
      }
    end
  end
end
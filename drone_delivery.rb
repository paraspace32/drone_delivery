class Drone
  attr_accessor :name
  attr_accessor :current_location
  attr_accessor :destination
  attr_accessor :parcel
  attr_accessor :status
  attr_accessor :parking_location

  def initialize(name, parking_slot, status)
    @name = name
    @current_location = parking_slot
    @parking_location = parking_slot
    @status = status
    puts "Drone #{name} is ready"
  end

  def pick_up(parcel)
    @parcel = parcel
    @current_location = parcel.location
    @destination = parcel.destination
    puts "Drone has picked parcel id:#{parcel.parcel_id}"
    leave_for_delivery(@destination)
  end

  def leave_for_delivery(order_address)
    @current_location = order_address
    puts "Drone is on the way"
    signal_after_reach
    unload_item
  end

  def signal_after_reach
    puts "reached destination" if @current_location == @destination
  end

  def unload_item
    return if @current_location != @destination

    Warehouse.remove_parcel
 	puts "Item has been delivered"
    CommandCenter.unloaded_pacakge("Delivered")
    park_in_command_center
  end

  def park_in_command_center
    @current_location = @parking_location
    CommandCenter.drone_current_status("Parked")
    puts "Drone is ready for another delivery"
  end
end

class CommandCenter
  attr_accessor :drone_status
  attr_accessor :parcel_status

  def self.instruct_to_pick_parcel(parcel, drone_name, parking_slot, status)
    if status == "Parked"
      drone = Drone.new(drone_name, parking_slot, status)
      drone.pick_up(parcel)
      @drone_status = "Delivering"
      @parcel_status = "Out_for_Delivery"
    end
  end

  def self.drone_current_status(status)
    @drone_status = status
  end

  def self.unloaded_pacakge(status)
    @parcel_status = status
  end
end

class Warehouse
    attr_accessor :parcels_stores
    attr_accessor :parcel

    def self.create_parcel_store
        @parcels_stores = []
    end

    def self.add_parcel(parcel)
        @parcels_stores << parcel
    end

    def self.remove_parcel
      @parcels_stores.clear
    end
end

class Parcel
  attr_accessor :parcel_id
  attr_accessor :location
  attr_accessor :destination

  def initialize(parcel_id, location, destination)
    @parcel_id = parcel_id
    @location = location
    @destination = destination
  end
end

class Test
  def start_delivery
    parcel = Parcel.new(1, { longitude: 45, latitude: 46 } , { longitude: 50.06, latitude: 78.16 })
    Warehouse.create_parcel_store
    Warehouse.add_parcel(parcel)
    CommandCenter.instruct_to_pick_parcel(parcel, "scripbox_001", { longitude: 44, latitude: 45 }, "Parked")
  end
end

begin
  test = Test.new
  test.start_delivery
rescue Exception
  puts "Drone has some technical problem."
end
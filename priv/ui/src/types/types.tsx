export interface Device {
  name: string
  type: string
  index: number
  address: string
  make: string
  model: string
}

export interface Zone {
  id: number
  name: string
  perimeter: boolean
}

export interface Sensor {
  interface: string
  source: Device
  zones: Zone
}

export interface System {
  name: string
  sensors: Array<Sensor>
}

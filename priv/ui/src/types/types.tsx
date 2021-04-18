export interface Radio {
  type: string
  name: string
  index: number
}

export interface Camera {
  type: string
  name: string
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
  source: Radio | Camera
  zones: Zone
}

export interface System {
  name: string
  sensors: Array<Sensor>
}

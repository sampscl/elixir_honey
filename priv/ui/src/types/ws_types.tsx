import { Radio, Camera } from './types'

export interface BaseWsMessage {
  type: string
  body: RadioDiscoveryMsg | CameraDiscoveryMsg
}

export interface RadioDiscoveryMsg {
  radio: Radio
}

export interface CameraDiscoveryMsg {
  camera: Camera
}

import { QueryResult, OperationVariables } from '@apollo/client';
import { System, Radio, Camera } from './types'
import WebsocketDispatcher from '../websocket_dispatcher'

export interface HeaderProps {
  installerMode: QueryResult<any, OperationVariables>
}

export interface WebsocketClientProps {
  dispatcher: WebsocketDispatcher | null
}

export interface SystemProps {
  system: System
}

export interface RadioProps extends WebsocketClientProps {
  radio: Radio
}

export interface CameraProps extends WebsocketClientProps {
  camera: Camera
}

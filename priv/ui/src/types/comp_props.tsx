import { QueryResult, OperationVariables } from '@apollo/client';
import { System, Device } from './types'

export interface HeaderProps {
  installerMode: QueryResult<any, OperationVariables>
}

export interface DeviceProps {
  device: Device
}

export interface SystemProps {
  system: System
}

import React, { useState, useRef, useEffect, useCallback } from 'react';
import './App.css';
import { ApolloProvider, ApolloClient, InMemoryCache } from '@apollo/client';
import { useQuery, gql } from '@apollo/client';
import { HeaderProps } from '../types/comp_props'
import { Radio, Camera } from '../types/types'
import { BaseWsMessage, RadioDiscoveryMsg, CameraDiscoveryMsg } from '../types/ws_types'
import CameraComp from './CameraComp'
import RadioComp from './RadioComp'
import WebsocketDispatcher from '../websocket_dispatcher'

// const WS_URL = `ws://${window.location.hostname}:${window.location.port}/ws`
const WS_URL = `ws://localhost:8080/ws`

interface AppStates {
  radios: Radio[]
  setRadios: React.Dispatch<React.SetStateAction<Radio[]>>
  cameras: Camera[]
  setCameras: React.Dispatch<React.SetStateAction<Camera[]>>
}

const client = new ApolloClient({
  uri: window.location.origin + "/api",
  cache: new InMemoryCache()
});

const IS_INSTALLER_MODE = gql`{isInstallerMode}`;

function shallow_equals(a: any, b: any) {
  for(var key in a) {
      if(a[key] !== b[key]) {
          return false;
      }
  }
  return true;
} // shallow_equals

function update_state_from_object(states: AppStates, o: object) {
  var existing: number = 0
  const msg = o as BaseWsMessage
  switch(msg.type) {
    case "radio_discovery":
      const radio_discovery = msg.body as RadioDiscoveryMsg
      console.log(radio_discovery)
      existing = states.radios.findIndex((element: Radio) => { return shallow_equals(element, radio_discovery.radio) })
      if(existing === -1) { // new radio
        console.log("new radio")
        states.radios.push(radio_discovery.radio)
        states.setRadios(states.radios)
      } else { // updated radio
        console.log("update radio")
        states.radios[existing] = radio_discovery.radio
        states.setRadios(states.radios)
      }
    break;

    case "camera_discovery":
      const camera_discovery = msg.body as CameraDiscoveryMsg
      console.log(camera_discovery)
      existing = states.cameras.findIndex((element: Camera) => { return shallow_equals(element, camera_discovery.camera) })
      if(existing === -1) { // new camera
        console.log("new camera")
        states.cameras.push(camera_discovery.camera)
        states.setCameras(states.cameras)
      } else { // updated camera
        console.log("update camera")
        states.cameras[existing] = camera_discovery.camera
        states.setCameras(states.cameras)
      }
    break;

    default:
      console.log(msg)
    break;
  }
} // update_state_from_object

function AppHeader({installerMode}: HeaderProps) {
  if(installerMode.loading) { return <header className="App-header" style={{backgroundColor: "red"}} ><p>Loading...</p></header>}
  if(installerMode.error) { return <header className="App-header" style={{backgroundColor: "red"}} ><p>Error</p></header>}
  return installerMode.data.isInstallerMode ? 
    <header className="App-header" style={{backgroundColor: "red"}} ><p>Installer Mode</p></header> :
    <header className="App-header"></header>
}

function App() {
  const installerMode = useQuery(IS_INSTALLER_MODE, {client: client})
  const ws_dispatcher = useRef<WebsocketDispatcher | null>(null)
  const [radios, setRadios] = useState<Radio[]>([])
  const [cameras, setCameras] = useState<Camera[]>([])
  // const device_ui: Array<JSX.Element> = devices.map((device: Device, index: number): JSX.Element => { return <DeviceComp key={index} device={device} /> })
  const handle_ws_msg = useCallback(
    (o: object) => {
      const states: AppStates = {
        radios: radios,
        setRadios: setRadios,
        cameras: cameras,
        setCameras: setCameras
      }
      update_state_from_object(states, o)
    },
    [radios, setRadios, cameras, setCameras],
  )

  useEffect(() => {
    ws_dispatcher.current = new WebsocketDispatcher(WS_URL)
    ws_dispatcher.current.register_handler(handle_ws_msg)
    return () => { 
      if(ws_dispatcher.current !== null) {
        ws_dispatcher.current.deregister_handler(handle_ws_msg)
        ws_dispatcher.current.close()
      }
    }
  }, [handle_ws_msg])

  const camera_comps: JSX.Element[] = []
  cameras.forEach((camera: Camera, key: number) => {
    camera_comps.push(<CameraComp key={key} camera={camera} dispatcher={ws_dispatcher.current}/>)
  })
  const radio_comps: JSX.Element[] = []
  radios.forEach((radio: Radio, key: number) => {
    radio_comps.push(<RadioComp key={key} radio={radio} dispatcher={ws_dispatcher.current}/>)
  })
  
  return (
    <div className="App">
      <ApolloProvider client={client}>
        <AppHeader installerMode={installerMode} />
        <React.Fragment>
          { camera_comps }
        </React.Fragment>
        <React.Fragment>
          { radio_comps }
        </React.Fragment>
      </ApolloProvider>
    </div>
  );
}

export default App;

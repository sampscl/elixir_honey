import React, { useState, useRef, useEffect } from 'react';
import './App.css';

import { ApolloProvider, ApolloClient, InMemoryCache } from '@apollo/client';
import { useQuery, gql } from '@apollo/client';

import DeviceComp from './DeviceComp'

import { Device } from '../types/types'
import { HeaderProps } from '../types/comp_props'

// const WS_URL = `ws://${window.location.hostname}:${window.location.port}/ws`
const WS_URL = `ws://localhost:8080/ws`

const client = new ApolloClient({
  uri: window.location.origin + "/api",
  cache: new InMemoryCache()
});

const IS_INSTALLER_MODE = gql`{isInstallerMode}`;

function AppHeader({installerMode}: HeaderProps) {
  if(installerMode.loading) { return <header className="App-header" style={{backgroundColor: "red"}} ><p>Loading...</p></header>}
  if(installerMode.error) { return <header className="App-header" style={{backgroundColor: "red"}} ><p>Error</p></header>}
  return installerMode.data.isInstallerMode ? 
    <header className="App-header" style={{backgroundColor: "red"}} ><p>Installer Mode</p></header> :
    <header className="App-header"></header>
}

function App() {

  const installerMode = useQuery(IS_INSTALLER_MODE, {client: client})
  const ws = useRef<WebSocket | null>(null)
  const [devices] = useState<Array<Device>>([{name: "name", type: "rtl-sdr", index: 0, address: "", make: "", model: ""}])
  const device_ui: Array<JSX.Element> = devices.map((device: Device): JSX.Element => { return <DeviceComp device={device} /> })

  useEffect(() => {
    ws.current = new WebSocket(WS_URL)
    ws.current.onmessage = (msg: MessageEvent<any>) => {
      console.log(msg)
      const o = JSON.parse(msg.data)
      switch(o["type"]) {
        default: 
        console.log(`ws_onmessage: unhandled => ${msg.data}`)
        break;
      } // end switch pkg["type"]
      }
    return () => { if(ws.current !== null) { ws.current.close()} }
  }, [])

  return (
    <div className="App">
      <ApolloProvider client={client}>
        <AppHeader installerMode={installerMode} />
        <React.Fragment>
          { device_ui }
        </React.Fragment>
      </ApolloProvider>
    </div>
  );
}

export default App;

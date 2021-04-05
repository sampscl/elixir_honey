import React, { useState, useRef, useEffect } from 'react';
import './App.css';

import { ApolloProvider, ApolloClient, InMemoryCache } from '@apollo/client';
import { useQuery, gql } from '@apollo/client';

// const WS_URL = `ws://${window.location.hostname}:${window.location.port}/ws`
const WS_URL = `ws://localhost:8080/ws`

const client = new ApolloClient({
  uri: window.location.origin + "/api",
  cache: new InMemoryCache()
});

const IS_INSTALLER_MODE = gql`
{
  isInstallerMode
}`;

type HeaderProps = {
  installerMode: boolean
}

function AppHeader({installerMode}: HeaderProps) {
  return installerMode? 
    <header className="App-header" style={{backgroundColor: "red"}} ><p>Installer Mode</p></header> :
    <header className="App-header"></header>
}

function App() {

  const { loading, error, data } = useQuery(IS_INSTALLER_MODE, {client: client})
  const [installerMode, setInstallerMode] = useState<boolean>(!loading && !error && data.isInstallerMode)
  useEffect(() => {
    setInstallerMode(!loading && !error && data.isInstallerMode)
  }, [loading, error, data])

  const ws = useRef<WebSocket | null>(null)
  useEffect(() => {
    ws.current = new WebSocket(WS_URL)
    ws.current.onmessage = (msg) => {
      console.log(msg)
    }
    return () => { if(ws.current !== null) { ws.current.close()} }
  }, [])

  return (
    <div className="App">
      <ApolloProvider client={client}>
          <AppHeader installerMode={installerMode} />
      </ApolloProvider>
    </div>
  );
}

export default App;

import { useRef, useEffect } from 'react';
import './App.css';

import { ApolloProvider, ApolloClient, InMemoryCache } from '@apollo/client';
import { useQuery, gql } from '@apollo/client';

const client = new ApolloClient({
  uri: window.location.origin + "/api",
  cache: new InMemoryCache()
});

const IS_INSTALLER_MODE = gql`
{
  isInstallerMode
}`;

function IsInstallerMode() {
  const { loading, error, data} = useQuery(IS_INSTALLER_MODE)
  if(loading) { return <p>Loading...</p> }
  if(error) { return <p>Error :-(</p> }
  return <p>Installer Mode: {data.isInstallerMode ? "True" : "False"}</p>
}

function App() {

  const ws = useRef<WebSocket | null>(null)
  useEffect(() => {
    ws.current = new WebSocket(`ws://${window.location.hostname}:${window.location.port}/ws`)
    ws.current.onmessage = (msg) => {
      console.log(msg)
    }
    return () => { if(ws.current !== null) { ws.current.close()} }
  }, [])

  return (
    <div className="App">
      <header className="App-header">
      </header>
      <body>
        <ApolloProvider client={client}>
          <IsInstallerMode />
        </ApolloProvider>
      </body>
    </div>
  );
}

export default App;

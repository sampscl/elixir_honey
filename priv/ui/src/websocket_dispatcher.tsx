import { sleep } from './utils'

type handler_t = ((o: object) => void);

//
// Maintain a persistent websocket and dispatch incoming
// messages to registered handlers
//
class WebsocketDispatcher {
  // members
  url: string
  ws: WebSocket
  handlers: Array<handler_t>

  register_handler(callback: handler_t) {
    console.log("registering:")
    console.log(callback)
    this.handlers.push(callback)
    console.log(this.handlers)
  } // register_handler

  deregister_handler(callback: handler_t) {
    console.log("deregistering:")
    console.log(callback)
    this.handlers = this.handlers.filter(candidate => candidate === callback )
    console.log(this.handlers)
  } // deregister_handler

  close() {
    this.ws.close()
  } // close

  constructor(url: string) {
    this.handlers = []
    this.url = url
    this.ws = this.conjure_websocket()
  } // constructor

  async websocket_closed(_event: CloseEvent) {
    console.log("Websocket closed, reopening in 1 second")
    await sleep(1000)
    this.ws = this.conjure_websocket()
  } // websocket_closed

  conjure_websocket() : WebSocket {
    console.log(`Conjuring a new websocket to ${this.url}`)
    var ws = new WebSocket(this.url)
    ws.onmessage = (msg: MessageEvent<any>) => {
      const o = JSON.parse(msg.data)
      this.handlers.forEach(registered_fn => { registered_fn(o) })
    }
    ws.onclose = (event: CloseEvent) => { this.websocket_closed(event) }
    return ws
  } // conjure_websocket
} // end class WebSocketDispatcher

export default WebsocketDispatcher

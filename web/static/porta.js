export default function(PhoenixSocket) {
  class Table {
    constructor(data = [], key = "id") {
      this.data = data
      this.key = key
    }
    upsert(row) {
      for (var d of this.data) {
        if (this.data[d][this.key] == row[this.key]) {
          for (var r in row) {
            this.data[d][r] = row[r]
          }
          return true
        }
      }
      this.data.push(row)
      return false
    }
    delete(row) {
      // yes
      let current = this.data.filter(x => x[this.key] == row[this.key])[0]
      if (current != null) {
        let index = this.data.indexOf(current)
        this.data.splice(index, 1)
      }
      return current != null
    }
  }
  
  class Socket extends PhoenixSocket {
    constructor(...args) {
      super(...args)
      this.tables = {}
    }
    channel(...args) {
      let channel = super.channel(...args)
      for (let s of ['insert', 'update', 'delete']) {
        this.addDataShorthand(channel, s)
      }
      channel.on("notif", res => {
        if (res.table && res.data) {
          if (res.event == "delete") {
            this.table(res.table).delete(res.data)
          }
          else {
            this.table(res.table).upsert(res.data)
          }
        }
      })
      return channel
    }
    addDataShorthand(channel, event) {
      channel[event] = (data, opts = {}, ...args) => {
        let payload = {}
        for (var o in opts) {
          payload[o] = opts[o]
        }
        payload.data = data
        channel.push(event, payload, ...args)
      }
    }
    table(name) {
      if (!this.tables[name]) {
        this.tables[name] = new Table()
      }
      return this.tables[name]
    }
  }
  return Socket
}
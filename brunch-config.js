exports.config = {
  sourceMaps: false,
  production: true,

  modules: {
    definition: false,
    // The wrapper for browsers in a way that:
    //
    // 1. Porta.Socket, Porta.Channel and so on are available
    // 2. the exports variable does not leak
    // 3. the Socket, Channel variables and so on do not leak
    wrapper: function(path, code){
      return "(function(exports){\n" + code + "\n})(typeof(exports) === \"undefined\" ? window.Porta = window.Porta || {} : exports);\n";
    }
  },

  files: {
    javascripts: {
      joinTo: 'porta.js'
    },
  },

  // Porta paths configuration
  paths: {
    // Which directories to watch
    watched: ["web/static", "test/static"],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/^(web\/static\/vendor)/]
    }
  }
};

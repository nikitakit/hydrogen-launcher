# coffeelint: disable = missing_fat_arrows
# term = require 'term-launcher'
path = require 'path'
{CompositeDisposable, Disposable} = require 'atom'


module.exports = HydrogenLauncher =
    config:
        app:
            title: 'Terminal application'
            description: 'This will depend on your operation system.'
            type: 'string'
            default: "test" #term.getDefaultTerminal()
        console:
            title: 'Jupyter console'
            description: 'Change this if you want to start a `qtconsole` or any
            other jupyter interface that can be started with `jupyter
            <your-console> --existing <connection-file>`.'
            type: 'string'
            default: 'console'

    subscriptions: null
    connectionFile: null

    activate: (state) ->
        @subscriptions = new CompositeDisposable

        @subscriptions.add atom.commands.add 'atom-text-editor',
            'hydrogen-launcher:launch-terminal': => @launchTerminal()
            'hydrogen-launcher:launch-jupyter-console': => @launchJupyter()
            'hydrogen-launcher:copy-path-to-connection-file': =>
                @copyPathToConnectionFile()

        unless @hydrogenProvider
            @hydrogenProvider = null

    deactivate: ->
        @subscriptions.dispose()

    consumeHydrogen: (provider) ->
        @hydrogenProvider = provider
        new Disposable =>
            @hydrogenProvider = null

    launchTerminal: ->
        return
        term.launchTerminal '', @getCWD(), @getTerminal(), (err) ->
            if err
                atom.notifications.addError err.message

    launchJupyter: ->
        connectionFile = @getConnectionFile()
        unless connectionFile
            return
        jpConsole = atom.config.get 'hydrogen-launcher.console'
        console.log(connectionFile)
        return
        term.launchJupyter connectionFile, @getCWD(), jpConsole, @getTerminal(),
            (err) ->
                if err
                    atom.notifications.addError err.message

    copyPathToConnectionFile: ->
        connectionFile = @getConnectionFile()
        unless connectionFile
            return

        atom.clipboard.write connectionFile
        message = 'Path to connection file copied to clipboard.'
        description = "Use `jupyter console --existing #{connectionFile}` to
            connect to the running kernel."
        atom.notifications.addSuccess message, description: description

    setConnectionFile: (file) ->
        @connectionFile = file

    getConnectionFile: ->
        unless @hydrogenProvider
            atom.notifications.addError 'Wrong hydrogen API'
            return
        return @hydrogenProvider.getActiveKernel().getConnectionFile()

    getTerminal: ->
        return atom.config.get 'hydrogen-launcher.app'

    getCWD: ->
        dir = atom.project.rootDirectories[0]?.path or
            path.dirname atom.workspace.getActiveTextEditor().getPath()
        return dir

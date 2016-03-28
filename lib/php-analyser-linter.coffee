{CompositeDisposable} = require 'atom'

module.exports =
  activate: ->
    require('atom-package-deps').install()
    @subscriptions = new CompositeDisposable

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    helpers = require('atom-linter')
    provider =
      name: 'PHP'
      grammarScopes: ['source.php']
      scope: 'file'
      lintOnFly: true
      lint: (textEditor) =>
        phpAnaliserPath = __dirname.replace(/\\/g, '/').replace(/\\/g, '/').replace(/\s/g, '\\ ') + '/../php/php-analyser.php'
        filePath = textEditor.getPath()
        parameters = []
        parameters.push(phpAnaliserPath)
        parameters.push('--detect-all')
        parameters.push(filePath)
        return helpers.exec('php', parameters, {}).then (output) ->
          regex = /(.+) on line (\d+)/gm
          messages = []
          while((match = regex.exec(output)) isnt null)
            messages.push
              type: "Info"
              filePath: filePath
              range: helpers.rangeFromLineNumber(textEditor, match[2] - 1)
              text: match[1]
          messages

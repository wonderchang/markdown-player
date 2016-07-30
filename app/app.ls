Storyteller = require \./storyteller.ls

module.exports = !->

  if location.search
    [url, action-id] = (location.search.substring 1) / \&
    get-story url

  $ '.md-url input' .focus (input) ->
    <-! $ window .keydown
    if 13 is it.key-code
      url = input.current-target.value
      get-story url

  function get-story
    $.ajax do
      url: \/get-story, data: url: it
      before-send: !->
        $ \.err-msg .text 'Loading ...' .css \display, \block
      success: !->
        push-state location.origin+location.pathname+'?'+it.url
        $ \.homepage  .css \display, \none
        $ \.story     .css \display, \block
        opt = do
          element: \.stage, markdown: it.markdown
        storyteller = new Storyteller opt
        init-stage storyteller

  !function init-stage storyteller
    title = storyteller.get-title!
    length = storyteller.get-length!
    $ \title      .text "Storyteller - #title"
    $ '.header p' .text title
    $ \.progress  .text "0 / #length"

    $ window .resize !->
      header-height = $ \.header .outer-height!
      footer-height = $ \.footer .outer-height!
      $ \.stage .css \height, window.inner-height - header-height - footer-height
    .resize!

    $ \.prev-btn .click !-> storyteller.prev!
    $ \.next-btn .click !-> storyteller.next!
    $ \.stage .click !->
      switch storyteller.get-status!
      | \paused, \start => storyteller.play!
      | \playing        => storyteller.pause!
      | \finished       => storyteller.play!

  function push-state then history.push-state {}, null, it

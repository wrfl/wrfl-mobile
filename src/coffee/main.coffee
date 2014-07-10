stream_url = "http://wrfl-server.ad.uky.edu:9000/stream/1/;"

@player = undefined

$ ->
  $('.btn-play').click play_stream
  $('.btn-pause').click pause_stream


play_stream = =>
  @player = new buzz.sound stream_url
  @player.play().fadeIn().bind "timeupdate", =>
    timer = buzz.toTimer(@player.getTime())
    $(".time-playing").text(timer)

pause_stream = =>
  if @player
    @player.unbind "timeupdate"
    @player.fadeOut 1000, =>
      @player.pause()
      @player = undefined

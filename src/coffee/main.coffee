@echonest_api_key = "RGNDUZEMOHI7QURCL"
@now_playing_url = "http://wrfl.fm/now.json"
@stream_url = "http://wrfl-server.ad.uky.edu:9000/stream/1/"
@refresh_rate_in_seconds = 30

@now_playing = {}
@player = undefined

$ ->
  $(".art").swipe
    threshold: 25
    swipeLeft: toggle_vinyl
    swipeRight: toggle_vinyl

  $('.btn-playpause').click toggle_stream
  refresh()

refresh = =>
  get_now_playing()
  setTimeout refresh, @refresh_rate_in_seconds * 1000

clean_artist_name_for_echonest = (name) =>
  name.replace(' ', '+')

toggle_stream = =>
  if @player
    pause_stream()
  else
    play_stream()

play_stream = =>
  @player = new buzz.sound @stream_url

  @player.play().fadeIn().bind "timeupdate", =>
    timer = buzz.toTimer(@player.getTime())
    $(".time-playing").text(timer)

pause_stream = =>
  if @player
    @player.unbind "timeupdate"
    @player.fadeOut 1000, =>
      @player.pause()
      @player = undefined

get_art = =>
  # Fetch an image via the Echo Nest API
  name = clean_artist_name_for_echonest(@now_playing.artist)
  $.get "http://developer.echonest.com/api/v4/artist/images?api_key=#{@echonest_api_key}&name=#{name}", (response) =>
    images = response.response.images
    if images.length > 0
      index = 0
      if images.length > 1
        index = Math.floor(Math.random()*images.length)
      @now_playing.art_url = images[index].url
      update_ui()

get_now_playing = =>
  $.getJSON @now_playing_url, (response) =>
    @now_playing = response
    get_art()
    update_ui()

toggle_vinyl = =>
  if $('.record').hasClass 'vinyl'
    $('.record').removeClass 'vinyl'
  else
    $('.record').addClass 'vinyl'


update_ui = =>
  $('.track').text '"' + @now_playing.track + '"'
  $('.artist').text @now_playing.artist
  $('.album').text @now_playing.album
  $('.time').text "Played at " + moment(@now_playing.played_at*1000).format("h:mma")
  $('.dj').text "by " + @now_playing.dj

  art_url = @now_playing.art_url || '/assets/default.jpg'
  $('.art .record').transition {opacity: 0}, 1000, =>
    $('.record .image').css({'backgroundImage': "url(#{art_url})"})
    $('.art .record').delay(1000).transition({opacity: 1}, 1000)

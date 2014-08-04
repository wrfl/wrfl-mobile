@echonest_api_key = "RGNDUZEMOHI7QURCL"
@now_playing_url = "http://wrfl.fm/now.json"
@stream_url = "http://wrfl-server.ad.uky.edu:9000/stream/1/"
@refresh_rate_in_seconds = 30

@now_playing = {}
@player = undefined
@is_playing = false

clean_artist_name_for_echonest = (name) =>
  name.replace(' ', '+').replace('&', '+')

clean_up_now_playing_response = (response) =>
  response.artist = fix_encoded_characters(response.artist)
  response.album = fix_encoded_characters(response.album)
  response.track = fix_encoded_characters(response.track)
  response.dj = fix_encoded_characters(response.dj)
  response

fix_encoded_characters = (string) =>
  string = string.replace('&#39;', "'")
  string = string.replace('&amp;', "&")

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
    @now_playing = clean_up_now_playing_response(response)
    get_art()
    update_ui()

hide_about = =>
  $('.about').removeClass 'visible'

pause_stream = =>
  if @player
    @player.unbind "timeupdate"
    @player.fadeOut 1000, =>
      @player.pause()
      @player = undefined
  $('.vinyl').removeClass 'playing'
  $('.btn-playpause').removeClass 'playing'
  @is_playing = false

play_stream = =>
  @player = new buzz.sound @stream_url
  @player.play().fadeIn()
  $('.vinyl').addClass 'playing'
  $('.btn-playpause').addClass 'playing'
  @is_playing = true

refresh = =>
  get_now_playing()
  setTimeout refresh, @refresh_rate_in_seconds * 1000

show_about = =>
  $('.about').addClass 'visible'

toggle_stream = =>
  if @player
    pause_stream()
  else
    play_stream()

toggle_vinyl = =>
  if $('.record').hasClass 'vinyl'
    $('.record').removeClass 'vinyl'
  else
    $('.record').addClass 'vinyl'
  if @is_playing
    $('.vinyl').addClass 'playing'
  else
    $('.vinyl').removeClass 'playing'

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

$ ->
  $('.logo').click show_about
  $('.about').swipe {swipeLeft: hide_about, swipeRight: hide_about}
  $('.about .close').click hide_about

  $('.art').swipe
    threshold: 25
    swipeLeft: toggle_vinyl
    swipeRight: toggle_vinyl

  $('.btn-playpause').click toggle_stream
  refresh()

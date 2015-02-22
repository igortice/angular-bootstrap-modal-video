'use strict'
moduleMain.constant('networkState',
  'NETWORK_EMPTY'    : 0
  'NETWORK_IDLE'     : 1
  'NETWORK_LOADING'  : 2
  'NETWORK_NO_SOURCE': 3
)

moduleMain.controller 'ModalVideoCtrl', [
  '$scope', '$element', '$attrs', '$timeout', '$filter', '$interval', 'networkState'
  ($scope, $element, $attrs, $timeout, $filter, $interval, networkState) ->
    modalVideo = $element.find('.modal')
    elementVideo = modalVideo.find('video')[0]
    current_interval = null
    $scope.errorVideo = false
    $scope.videoCurrentDuration = "00:00"
    $scope.videoDuration = "00:00"
    $scope.play = false
    $scope.finish = false
    $scope.pause = false
    $scope.full = false
    #                                                                                   After Close Modal
    # ---------------------------------------------------------------------------------------------------
    modalVideo.on 'hide.bs.modal', () ->
      pauseVideo()

      return

    #                                                                                         Pause Viedo
    # ---------------------------------------------------------------------------------------------------
    pauseVideo = ->
      $interval.cancel(current_interval)
      elementVideo.pause()

      return

    #                                                                                 Update Current Time
    # ---------------------------------------------------------------------------------------------------
    updateCurrentTime = ->
      time = secondsToTime(elementVideo.currentTime)
      $scope.progressBar()
      $scope.videoCurrentDuration = "#{time.m}:#{time.s}"

      return


    #                                                                                     Seconds To Time
    # ---------------------------------------------------------------------------------------------------
    secondsToTime = (secs) ->
      hours = Math.floor(secs / (60 * 60))
      divisor_for_minutes = secs % (60 * 60)
      minutes = Math.floor(divisor_for_minutes / 60)
      minutes = minutes >= 10 && minutes || "0#{minutes}"
      divisor_for_seconds = divisor_for_minutes % 60
      seconds = Math.ceil(divisor_for_seconds)
      seconds = seconds >= 10 && seconds || "0#{seconds}"
      obj =
        'h': hours
        'm': minutes
        's': seconds

      obj

    #                                                                             Config Video After Load
    # ---------------------------------------------------------------------------------------------------
    $timeout (->
#      elementVideo.addEventListener 'loadedmetadata', ->
#        elementVideo.duration
      $scope.errorVideo = elementVideo.networkState == networkState.NETWORK_EMPTY || elementVideo.networkState == networkState.NETWORK_NO_SOURCE
      time = secondsToTime(elementVideo.duration)
      $scope.videoDuration = "#{time.m}:#{time.s}"

      return
    ), 500

    #                                                                                        Progress Bar
    # ---------------------------------------------------------------------------------------------------
    $scope.progressBar = ->
      return Math.floor((elementVideo.currentTime * 100) / elementVideo.duration)

    #                                                                                 Update Progress Bar
    # ---------------------------------------------------------------------------------------------------
    $scope.updateBarProgress = (event) ->
      width_total = angular.element(event.target)[0].offsetWidth

      if (!event.offsetX)
        event.offsetX = event.pageX - angular.element(event.target).offset().left

      width_parcial = event.offsetX
      width_porcent = (width_parcial * 100) / width_total

      current_time = (width_porcent * elementVideo.duration) / 100

      elementVideo.currentTime = current_time
      updateCurrentTime()

      return

    #                                                                                          Open Modal
    # ---------------------------------------------------------------------------------------------------
    $scope.getModalVideo = ->
      modalVideo.removeClass('full-size')
      $scope.videoCurrentDuration = "00:00"
      $scope.play = true
      $scope.pause = false
      $scope.full = false
      $scope.finish = false
      elementVideo.load()
      modalVideo.modal('show')

      return

    #                                                                               Comands Buttons Video
    # ---------------------------------------------------------------------------------------------------
    $scope.video = (comando) ->
      switch comando
        when 'pause'
          $scope.play = true
          $scope.pause = !$scope.play
          pauseVideo()
        when 'play', 'repeat'
          $scope.play = false
          $scope.pause = !$scope.play
          $scope.finish = !$scope.pause
          elementVideo.play()
          current_interval = $interval (->
            updateCurrentTime()
            if elementVideo.ended
              $scope.play = false
              $scope.pause = false
              $scope.finish = true
              $interval.cancel(current_interval)
          ), 250
        when 'eject'
          modalVideo.modal('hide')
        when 'full-size'
          $scope.full = true
          modalVideo.addClass('full-size')
        when 'normal-size'
          $scope.full = false
          modalVideo.removeClass('full-size')

      return
]

templateModalVideo = (elem, attr) ->
  full_size_with = attr.fullSizeWith || '70%'
  title_play = attr.titlePlay || 'play'
  title_pause = attr.titlePause || 'pause'
  title_play_repeat = attr.titlePlayRepeat || 'repeat'
  title_exit = attr.titleExit || 'exit'
  title_time = attr.titleTime || 'time'
  title_full_size = attr.titleFullSize || 'full size'
  title_normal_size = attr.titleNormallSize || 'normal size'

  if attr.srcOgg
    source_ogg = """
        <source src="#{attr.srcOgg}" type="video/ogg">
      """
  if attr.srcMp4
    source_mp4 = """
        <source src="#{attr.srcMp4}" type="video/mp4">
      """

  btn_modal_video = """
    <button class="btn btn-primary btn-link" ng-click="getModalVideo()">
      <i class="glyphicon glyphicon-facetime-video"></i>
      Watch Video
    </button>
  """

  if elem.html()
    btn_modal_video = """
        <div ng-click="getModalVideo()">
        #{elem.html()}
        </div>
      """

  html = """
      #{btn_modal_video}
      <div class="modal fade">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-body">
              <div ng-hide="errorVideo">
                <div ng-mouseleave="showPlayPauseOverVideo=false" ng-mouseover="showPlayPauseOverVideo=true">
                  <video width="100%">
                    #{source_ogg}
                    #{source_mp4}
                  </video>
                  <div class="play-pause" ng-show="showPlayPauseOverVideo">
                    <div ng-show="play" >
                      <i class='glyphicon glyphicon-play' ng-click="video('play')" title="#{title_play}"></i>
                    </div>
                    <div ng-show="pause" >
                      <i class='glyphicon glyphicon-pause' ng-click="video('pause')" title="#{title_pause}"></i>
                    </div>
                  </div>
                </div>
                <div class='container-progress'>
                  <div ng-click="updateBarProgress($event)" class="progress-update"></div>
                  <div class="progress">
                    <div class="progress-bar active" role="progressbar" aria-valuenow="45" aria-valuemin="0" aria-valuemax="100" style="width: {{progressBar()}}%">
                      {{progressBar()}}%
                    </div>
                  </div>
                </div>
                <div class="btn-group btn-group-justified">
                  <div class="btn-group ng-hide" ng-show="pause">
                    <button class="btn btn-default" ng-click="video('pause')" title="#{title_pause}" type="radio">
                      <i class="glyphicon glyphicon-pause"></i>
                    </button>
                  </div>
                  <div class="btn-group" ng-show="play">
                    <button class="btn btn-default" ng-click="video('play')" title="#{title_play}" type="radio">
                      <i class="glyphicon glyphicon-play"></i>
                    </button>
                  </div>
                  <div class="btn-group" ng-show="finish">
                    <button class="btn btn-default" ng-click="video('repeat')" title="#{title_play_repeat}" type="radio">
                      <i class="glyphicon glyphicon-repeat"></i>
                    </button>
                  </div>
                  <div class="btn-group">
                    <button class="btn btn-default ng-binding" title="#{title_time}">
                      {{videoCurrentDuration}}/{{videoDuration}}
                    </button>
                  </div>
                  <div class="btn-group">
                    <button class="btn btn-default" ng-click="video('eject')" title="#{title_exit}" type="radio">
                      <i class="glyphicon glyphicon-eject"></i>
                    </button>
                  </div>
                  <div class="btn-group" ng-hide="full">
                    <button class="btn btn-default" ng-click="video('full-size');" ng-hide="full" title="#{title_full_size}" type="radio">
                      <i class="glyphicon glyphicon-resize-full"></i>
                    </button>
                  </div>
                  <div class="btn-group ng-hide" ng-show="full">
                    <button class="btn btn-default ng-hide" ng-click="video('normal-size')" ng-show="full" title="#{title_normal_size}" type="radio">
                      <i class="glyphicon glyphicon-resize-small"></i>
                    </button>
                  </div>
                </div>
              </div>
              <div ng-show="errorVideo">
                <h1 class='text-center text-muted' style="font-size: 20em">
                  <i class="glyphicon glyphicon-facetime-video"></i>
                </h1>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
  css = """
      <style type="text/css">
        modal-video .full-size .modal-lg {
            width : #{full_size_with};
        }
        modal-video .container-progress {
          position: relative;
        }
        modal-video .progress {
          margin-bottom: 5px;
          position: relative;
          border-radius: 0 !important;
        }
        modal-video .progress-update {
          cursor: pointer;
          height: 100%;
          z-index: 9999999;
          position: absolute;
          width: 100%;
        }
        modal-video .progress-bar {
          text-align: right;
        }
        modal-video .modal-content, modal-video .btn-group .btn  {
          -webkit-border-radius: 0px !important
          -moz-border-radius: 0px !important;
          -o-border-radius: 0px !important;
          border-radius: 0px !important;
          border: 0px !important;
        }
        modal-video .modal-body {
          padding: 1px;
        }
        modal-video .play-pause {
          position: absolute;
          width: 100%;
          text-align: center;
          cursor: pointer;
          top: 0;
          color: #ffffff;
        }
        modal-video .play-pause > div {
          margin-top: 15%;
          font-size: 10em;
        }
        modal-video .full-size .play-pause > div {
          margin-top: 18%;
          font-size: 15em;
        }
      </style>
    """

  html + css


moduleMain.directive 'modalVideo', ->
  modalVideo = {
    restrict  : 'E',
    scope     : true,
    controller: 'ModalVideoCtrl'
    template  : (elem, attr) ->
      templateModalVideo(elem, attr)
  }

  modalVideo
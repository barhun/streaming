let init = () => {
  let filter = browserFilter => type =>
    !type ||
    ['av01', 'vp08', 'vp09', 'vp8', 'vp9', 'webm'].find(c => type.includes(c)) ||
    (/framerate=(\d+)/.exec(type) || {1: '0'})[1] > 30
      ? '' : browserFilter(type)

  let videoElement = document.createElement('video')
  videoElement.__proto__.canPlayType = filter(videoElement.canPlayType.bind(videoElement))

  let mediaSource = window.MediaSource
  mediaSource && (mediaSource.isTypeSupported = filter(mediaSource.isTypeSupported.bind(mediaSource)))
}

document.documentElement.appendChild(Object.assign(document.createElement('script'), {
  textContent: `(${init.toString()})()`,
  onload: function () {document.documentElement.removeChild(this)}
}))

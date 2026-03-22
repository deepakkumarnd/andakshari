import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "icon", "timer"]
  static values = { duration: { type: Number, default: 10 } }

  connect() {
    this.recording = false
    this.mediaRecorder = null
    this.chunks = []
  }

  async toggle() {
    if (this.recording) {
      this.stop()
    } else {
      await this.start()
    }
  }

  async start() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.mediaRecorder = new MediaRecorder(stream)
      this.chunks = []

      this.mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) this.chunks.push(e.data)
      }

      this.mediaRecorder.onstop = () => {
        stream.getTracks().forEach(track => track.stop())
        this.submitAudio()
      }

      this.mediaRecorder.start()
      this.recording = true
      this.buttonTarget.classList.add("bg-red-600", "hover:bg-red-500")
      this.buttonTarget.classList.remove("bg-gray-700", "hover:bg-gray-600")
      this.startTimer()

      this.autoStopTimeout = setTimeout(() => this.stop(), this.durationValue * 1000)
    } catch (e) {
      console.error("Microphone access denied:", e)
    }
  }

  stop() {
    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      this.mediaRecorder.stop()
    }
    this.recording = false
    this.buttonTarget.classList.remove("bg-red-600", "hover:bg-red-500")
    this.buttonTarget.classList.add("bg-gray-700", "hover:bg-gray-600")
    this.stopTimer()
    if (this.autoStopTimeout) {
      clearTimeout(this.autoStopTimeout)
      this.autoStopTimeout = null
    }
  }

  submitAudio() {
    const blob = new Blob(this.chunks, { type: "audio/webm" })
    const formData = new FormData()
    formData.append("audio", blob, "recording.webm")

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(this.element.dataset.audioSearchUrl, {
      method: "POST",
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": csrfToken
      },
      body: formData
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
  }

  startTimer() {
    this.secondsLeft = this.durationValue
    this.updateTimerDisplay()
    this.timerTarget.classList.remove("hidden")
    this.timerInterval = setInterval(() => {
      this.secondsLeft--
      this.updateTimerDisplay()
      if (this.secondsLeft <= 0) this.stopTimer()
    }, 1000)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
    if (this.hasTimerTarget) {
      this.timerTarget.classList.add("hidden")
    }
  }

  updateTimerDisplay() {
    if (this.hasTimerTarget) {
      this.timerTarget.textContent = `${this.secondsLeft}s`
    }
  }

  disconnect() {
    this.stop()
  }
}

import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

const ICE_SERVERS = [{ urls: "stun:stun.l.google.com:19302" }]

export default class extends Controller {
  static values  = { gameRoomId: String, userId: Number }
  static targets = ["micBtn", "micIcon", "muteIcon", "statusText"]

  connect() {
    console.log("[voice] controller connected, userId=", this.userIdValue, "roomId=", this.gameRoomIdValue)
    this.peers  = {}
    this.audios = {}
    this.muted  = false
    this.localStream = null
    this.setupChannel()
  }

  disconnect() {
    this.localStream?.getTracks().forEach(t => t.stop())
    Object.values(this.peers).forEach(pc => pc.close())
    Object.values(this.audios).forEach(a => { a.srcObject = null; a.remove() })
    this.peers  = {}
    this.audios = {}
    this.subscription?.unsubscribe()
  }

  // ── Mic + channel setup ───────────────────────────────────────────────────

  async setupChannel() {
    // Acquire mic first so the stream is ready before any peer connection is created
    try {
      this.localStream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false })
      console.log("[voice] mic acquired, tracks:", this.localStream.getTracks().map(t => t.kind))
      this.updateMicUI()
    } catch {
      this.statusTextTarget.textContent = "Mic access denied"
      return
    }

    this.subscription = createConsumer().subscriptions.create(
      { channel: "VoiceChannel", game_room_id: this.gameRoomIdValue },
      {
        connected: () => {
          console.log("[voice] channel connected, announcing presence")
          this.subscription.perform("announce", {})
        },
        rejected: () => console.error("[voice] channel subscription rejected — check ApplicationCable::Connection"),
        received:  (data) => {
          console.log("[voice] signal received:", data)
          this.handleSignal(data)
        }
      }
    )
  }

  // ── Mute toggle ───────────────────────────────────────────────────────────

  toggleMute() {
    this.muted = !this.muted
    this.localStream?.getAudioTracks().forEach(t => { t.enabled = !this.muted })
    this.subscription.perform("mute_state", { muted: this.muted })
    this.updateMicUI()
  }

  updateMicUI() {
    this.micIconTarget.classList.toggle("hidden", this.muted)
    this.muteIconTarget.classList.toggle("hidden", !this.muted)
    this.statusTextTarget.textContent = this.muted ? "Muted" : "Live"
    this.micBtnTarget.classList.toggle("bg-red-100",   this.muted)
    this.micBtnTarget.classList.toggle("text-red-600",  this.muted)
    this.micBtnTarget.classList.toggle("border-red-300", this.muted)
    this.micBtnTarget.classList.toggle("bg-green-50",   !this.muted)
    this.micBtnTarget.classList.toggle("text-green-700", !this.muted)
    this.micBtnTarget.classList.toggle("border-green-300", !this.muted)
  }

  // ── Signaling ─────────────────────────────────────────────────────────────

  async handleSignal(data) {
    switch (data.type) {
      case "user_joined":
        if (data.user_id !== this.userIdValue) await this.createOffer(data.user_id)
        break
      case "offer":
        await this.handleOffer(data)
        break
      case "answer":
        await this.handleAnswer(data)
        break
      case "ice":
        await this.handleIce(data)
        break
      case "mute_state":
        this.updateRemoteMuteUI(data.user_id, data.muted)
        break
    }
  }

  // ── WebRTC ────────────────────────────────────────────────────────────────

  createPeerConnection(userId) {
    const pc = new RTCPeerConnection({ iceServers: ICE_SERVERS })
    this.peers[userId] = pc

    this.localStream?.getTracks().forEach(track => pc.addTrack(track, this.localStream))

    pc.ontrack = ({ streams }) => {
      if (!streams[0]) return
      let audio = this.audios[userId]
      if (!audio) {
        audio = document.createElement("audio")
        audio.autoplay = true
        audio.volume = 1
        audio.style.display = "none"
        document.body.appendChild(audio)
        this.audios[userId] = audio
      }
      if (audio.srcObject !== streams[0]) {
        audio.srcObject = streams[0]
        audio.play().catch(e => console.warn("audio play blocked:", e))
      }
    }

    pc.onconnectionstatechange = () => {
      console.log(`[voice] peer ${userId} → ${pc.connectionState}`)
    }

    pc.onicecandidate = ({ candidate }) => {
      if (candidate) {
        this.subscription.perform("signal", { to: userId, type: "ice", candidate: candidate.toJSON() })
      }
    }

    return pc
  }

  async createOffer(targetUserId) {
    const pc  = this.createPeerConnection(targetUserId)
    const offer = await pc.createOffer()
    await pc.setLocalDescription(offer)
    this.subscription.perform("signal", { to: targetUserId, type: "offer", sdp: offer.sdp })
  }

  async handleOffer(data) {
    const pc = this.createPeerConnection(data.from)
    await pc.setRemoteDescription({ type: "offer", sdp: data.sdp })
    const answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)
    this.subscription.perform("signal", { to: data.from, type: "answer", sdp: answer.sdp })
  }

  async handleAnswer(data) {
    await this.peers[data.from]?.setRemoteDescription({ type: "answer", sdp: data.sdp })
  }

  async handleIce(data) {
    try {
      await this.peers[data.from]?.addIceCandidate(data.candidate)
    } catch { /* ignore stale candidates */ }
  }

  // ── Remote mute UI ────────────────────────────────────────────────────────

  updateRemoteMuteUI(userId, muted) {
    const el = document.querySelector(`[data-participant-id="${userId}"] [data-mic-indicator]`)
    if (!el) return
    el.classList.toggle("text-red-400", muted)
    el.classList.toggle("text-green-500", !muted)
    el.setAttribute("title", muted ? "Muted" : "Live")
  }
}

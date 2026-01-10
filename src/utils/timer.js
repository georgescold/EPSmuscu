/**
 * Calculates the current state of the global timer based on configuration and status.
 * 
 * @param {Object} config - { repeats: Number, phases: Array<{ duration: Number, name: String, color: String }> }
 * @param {Object} status - { state: String, start_timestamp: Number, paused_timestamp: Number, elapsed_before_pause: Number }
 * @returns {Object} { 
 *   currentPhaseIndex: Number, 
 *   currentPhase: Object, 
 *   remainingInPhase: Number (ms), 
 *   totalRemaining: Number (ms), 
 *   isFinished: Boolean,
 *   isRunning: Boolean,
 *   elapsed: Number
 * }
 */
export function calculateTimerState(config, status) {
    const now = Date.now()
    let elapsed = 0

    // 1. Calculate Total Elapsed Time
    if (status.state === 'running') {
        elapsed = (now - status.start_timestamp)
    } else if (status.state === 'paused' || status.state === 'finished') {
        elapsed = status.elapsed_before_pause
    } else {
        // idle
        return {
            currentPhaseIndex: 0,
            currentPhase: config.phases[0] || null,
            remainingInPhase: (config.phases[0]?.duration || 0) * 1000,
            totalRemaining: 0, // todo: calc total
            isFinished: false,
            isRunning: false,
            elapsed: 0
        }
    }

    // 2. Linearize Phases (Handle Repeats)
    // config.phases is one sequence. config.repeats is how many times it loops.
    // We don't necessarily need to build a huge array, we can calc via modulo, 
    // but building the array is safer for variable phase durations.
    // Given typical usage (< 20 phases x < 10 repeats), a flat array is fine.

    let flatPhases = []
    if (config.phases && config.phases.length > 0) {
        for (let r = 0; r < (config.repeats || 1); r++) {
            config.phases.forEach(p => {
                flatPhases.push({ ...p, iteration: r + 1 })
            })
        }
    }

    // 3. Find Current Phase
    let timeCursor = 0
    let currentPhase = null
    let currentPhaseIndex = -1
    let remainingInPhase = 0
    let isFinished = false

    // Total duration calculation
    const totalDuration = flatPhases.reduce((acc, p) => acc + (p.duration * 1000), 0)

    if (elapsed >= totalDuration) {
        isFinished = true
        return {
            currentPhaseIndex: flatPhases.length - 1,
            currentPhase: flatPhases[flatPhases.length - 1],
            remainingInPhase: 0,
            totalRemaining: 0,
            isFinished: true,
            isRunning: status.state === 'running', // Technically it "ran" to completion, logic might handle auto-stop
            elapsed
        }
    }

    for (let i = 0; i < flatPhases.length; i++) {
        const p = flatPhases[i]
        const pDurationMs = (Number(p.duration) || 0) * 1000

        // Check if we are inside this phase
        if (elapsed < (timeCursor + pDurationMs)) {
            currentPhase = p
            currentPhaseIndex = i
            remainingInPhase = (timeCursor + pDurationMs) - elapsed
            break
        }

        timeCursor += pDurationMs
    }

    return {
        currentPhaseIndex,
        currentPhase,
        remainingInPhase,
        totalRemaining: Math.max(0, totalDuration - elapsed),
        isFinished,
        isRunning: status.state === 'running',
        elapsed
    }
}

export const TIMER_COLORS = [
    { label: 'Vert (Travail)', value: 'emerald', bg: 'bg-emerald-500', text: 'text-emerald-900', light: 'bg-emerald-100' },
    { label: 'Rouge (Repos)', value: 'red', bg: 'bg-red-500', text: 'text-red-900', light: 'bg-red-100' },
    { label: 'Bleu (Transition)', value: 'blue', bg: 'bg-blue-500', text: 'text-blue-900', light: 'bg-blue-100' },
    { label: 'Jaune (Info)', value: 'amber', bg: 'bg-amber-500', text: 'text-amber-900', light: 'bg-amber-100' },
    { label: 'Violet (Autre)', value: 'indigo', bg: 'bg-indigo-500', text: 'text-indigo-900', light: 'bg-indigo-100' },
]

export const TIMER_SOUNDS = [
    { label: 'Aucun', value: 'none', icon: '🔇' },
    { label: 'Cloche', value: 'bell', icon: '🔔' },
    { label: 'Buzzer', value: 'buzzer', icon: '📢' },
]

// ============ iOS-COMPATIBLE AUDIO SOLUTION ============
// Use HTML5 Audio with preloaded elements for better iOS compatibility

// Preloaded audio elements (created on first user interaction)
let bellAudio = null
let buzzerAudio = null
let audioUnlocked = false

// Bell sound - using a simple notification sound frequency pattern
// We'll use the Web Audio API to generate and cache audio as a Blob URL
let bellBlobUrl = null
let buzzerBlobUrl = null

function generateBellSound() {
    const sampleRate = 44100
    const duration = 5 // seconds
    const numSamples = sampleRate * duration
    const audioData = new Float32Array(numSamples)

    // Generate 4 bell strikes
    const strikes = [0, 1.2, 2.4, 3.6]
    const frequencies = [523.25, 659.25, 783.99, 1046.5]

    for (let strike of strikes) {
        const strikeStart = Math.floor(strike * sampleRate)
        const strikeDuration = 2 * sampleRate

        for (let i = 0; i < strikeDuration && (strikeStart + i) < numSamples; i++) {
            const t = i / sampleRate
            const decay = Math.exp(-t * 2)
            let sample = 0

            for (let f = 0; f < frequencies.length; f++) {
                const amplitude = [0.3, 0.2, 0.15, 0.1][f]
                sample += amplitude * Math.sin(2 * Math.PI * frequencies[f] * t) * decay
            }

            audioData[strikeStart + i] += sample * 0.5
        }
    }

    return audioData
}

function generateBuzzerSound() {
    const sampleRate = 44100
    const duration = 5 // seconds
    const numSamples = sampleRate * duration
    const audioData = new Float32Array(numSamples)

    // Generate alternating tones
    for (let i = 0; i < 8; i++) {
        const baseTime = i * 0.6

        // High tone
        const highStart = Math.floor(baseTime * sampleRate)
        const toneDuration = Math.floor(0.28 * sampleRate)
        for (let j = 0; j < toneDuration && (highStart + j) < numSamples; j++) {
            const t = j / sampleRate
            const envelope = Math.sin(Math.PI * j / toneDuration) // Smooth envelope
            audioData[highStart + j] += 0.3 * Math.sin(2 * Math.PI * 880 * t) * envelope
        }

        // Low tone
        const lowStart = Math.floor((baseTime + 0.3) * sampleRate)
        for (let j = 0; j < toneDuration && (lowStart + j) < numSamples; j++) {
            const t = j / sampleRate
            const envelope = Math.sin(Math.PI * j / toneDuration)
            audioData[lowStart + j] += 0.3 * Math.sin(2 * Math.PI * 698.46 * t) * envelope
        }
    }

    return audioData
}

function floatTo16BitPCM(output, offset, input) {
    for (let i = 0; i < input.length; i++, offset += 2) {
        const s = Math.max(-1, Math.min(1, input[i]))
        output.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7FFF, true)
    }
}

function createWavBlob(audioData, sampleRate = 44100) {
    const numChannels = 1
    const bitsPerSample = 16
    const bytesPerSample = bitsPerSample / 8
    const blockAlign = numChannels * bytesPerSample
    const byteRate = sampleRate * blockAlign
    const dataSize = audioData.length * bytesPerSample
    const buffer = new ArrayBuffer(44 + dataSize)
    const view = new DataView(buffer)

    // WAV header
    const writeString = (offset, string) => {
        for (let i = 0; i < string.length; i++) {
            view.setUint8(offset + i, string.charCodeAt(i))
        }
    }

    writeString(0, 'RIFF')
    view.setUint32(4, 36 + dataSize, true)
    writeString(8, 'WAVE')
    writeString(12, 'fmt ')
    view.setUint32(16, 16, true)
    view.setUint16(20, 1, true)
    view.setUint16(22, numChannels, true)
    view.setUint32(24, sampleRate, true)
    view.setUint32(28, byteRate, true)
    view.setUint16(32, blockAlign, true)
    view.setUint16(34, bitsPerSample, true)
    writeString(36, 'data')
    view.setUint32(40, dataSize, true)

    floatTo16BitPCM(view, 44, audioData)

    return new Blob([buffer], { type: 'audio/wav' })
}

function initAudioElements() {
    if (bellAudio && buzzerAudio) return

    try {
        // Generate sounds and create blob URLs
        const bellData = generateBellSound()
        const buzzerData = generateBuzzerSound()

        bellBlobUrl = URL.createObjectURL(createWavBlob(bellData))
        buzzerBlobUrl = URL.createObjectURL(createWavBlob(buzzerData))

        bellAudio = new Audio(bellBlobUrl)
        buzzerAudio = new Audio(buzzerBlobUrl)

        // Preload
        bellAudio.preload = 'auto'
        buzzerAudio.preload = 'auto'

        // Load them
        bellAudio.load()
        buzzerAudio.load()

        console.log('Timer sounds initialized (HTML5 Audio)')
    } catch (e) {
        console.error('Failed to initialize audio:', e)
    }
}

// Call this on any user interaction to unlock audio on iOS
export function unlockAudio() {
    if (audioUnlocked) return

    initAudioElements()

    // On iOS, we need to play the audio (even silently) during a user gesture
    if (bellAudio && buzzerAudio) {
        // Play and immediately pause to unlock
        bellAudio.volume = 0
        buzzerAudio.volume = 0

        const playPromise1 = bellAudio.play()
        const playPromise2 = buzzerAudio.play()

        if (playPromise1) {
            playPromise1.then(() => {
                bellAudio.pause()
                bellAudio.currentTime = 0
                bellAudio.volume = 1
            }).catch(() => { })
        }

        if (playPromise2) {
            playPromise2.then(() => {
                buzzerAudio.pause()
                buzzerAudio.currentTime = 0
                buzzerAudio.volume = 1
            }).catch(() => { })
        }

        audioUnlocked = true
        console.log('Audio unlocked for iOS')
    }
}

// Play a sound for phase end notification
export function playTimerSound(soundType) {
    if (!soundType || soundType === 'none') return

    // Ensure audio is initialized
    initAudioElements()

    console.log('Playing timer sound:', soundType)

    try {
        if (soundType === 'bell' && bellAudio) {
            bellAudio.currentTime = 0
            bellAudio.volume = 1
            const playPromise = bellAudio.play()
            if (playPromise) {
                playPromise.catch(e => console.error('Bell play failed:', e))
            }
        } else if (soundType === 'buzzer' && buzzerAudio) {
            buzzerAudio.currentTime = 0
            buzzerAudio.volume = 1
            const playPromise = buzzerAudio.play()
            if (playPromise) {
                playPromise.catch(e => console.error('Buzzer play failed:', e))
            }
        }
    } catch (e) {
        console.error('Error playing timer sound:', e)
    }
}

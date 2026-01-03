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

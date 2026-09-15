// 1. SYNTHDEF: Acid Bassline (TB-303 style)
(
SynthDef(\acid, {
	arg out=0, freq=440, gate=1, amp=0.2, pan=0,
	    cutoff=800, res=0.8, envMod=1500, decay=0.2, accent=0;

	var saw, filter, env, ampEnv, finalSig;

	// Amplitude Envelope with gate release
	ampEnv = EnvGen.kr(Env.adsr(0.001, decay, 0.0, 0.05), gate, doneAction: 2);

	// Filter Envelope (percussive trigger)
	env = EnvGen.kr(Env.perc(0.001, decay * (1 + accent)), gate);

	// Oscillator Core (sawtooth wave)
	saw = Saw.ar(freq);

	// Resonant Low-Pass Filter (RLPF)
	filter = RLPF.ar(
		saw,
		(cutoff + (env * envMod * (1 + (accent * 2)))).clip(20, 18000),
		1.0 - res.clip(0, 0.95)
	);

	// Distorted/Accented gain path
	finalSig = filter * ampEnv * amp * (1 + (accent * 0.5));

	Out.ar(out, Pan2.ar(finalSig.tanh, pan));
}).add;
)

// 2. LIVE PATTERN: Pdef & Pbind Sequence
(
// set global tempo to 128 bpm
TempoClock.default.tempo = 128 / 60;

Pdef(\acidPattern,
	Pbind(
		\instrument, \acid,
		\dur, 0.25,   // 16th notes

		// pitch & note sequence
		\note, Pseq([0, 0, 12, 0, 3, 0, 7, 0, 0, 12, 5, 0, 3, 0, 2, 0], inf),
		\octave, 3,

		// dynamic parameters (kwarg)
		\cutoff, Pexprand(300, 2500, inf),
		\res, 0.85,
		\decay, Pwhite(0.1, 0.35, inf),
		\envMod, 2200,

		// accents (1 = accented hit, 0 = normal)
		\accent, Pseq([1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0], inf),
		\amp, Pkey(\accent).linlin(0, 1, 0.15, 0.3)
    )
).play;
)

// 3. LIVE CODING MUTATIONS (evaluate while running)
// Change the cutoff sweep range on the fly
Pdef(\accidPattern).set(\cutoff, 4000);

// stop playback
Pdef(\acidPattern).stop;
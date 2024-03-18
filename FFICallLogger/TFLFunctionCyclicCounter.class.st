"
I listen a `TFLFunctionCounter` and trace its output regularly, every second.

Example of use:

```
t := TFLCallsPerSecondTracer new.

t start.
t stop.
```

Now, `Transcript` should be showing something like:

```
""
| #                 | calls/s |
|-------------------|---------|
| SDL_GetWindowSize |  545.36 |
| SDL_PollEvent     |  261.22 |
| SDL_GetModState   |   56.83 |
| SDL_RenderPresent |    9.97 |
| SDL_RenderCopy    |    9.97 |
| SDL_LockTexture   |    4.99 |
| SDL_UnlockTexture |    4.99 |
| SDL_GetMouseState |    1.99 |
| SDL_FreeCursor    |    1.00 |
| SDL_SetCursor     |    1.00 |
| SDL_CreateCursor  |    1.00 |
""
```

"
Class {
	#name : #TFLFunctionCyclicCounter,
	#superclass : #Object,
	#instVars : [
		'announcer',
		'delay',
		'loopProcess'
	],
	#category : #'FFICallLogger-Counter'
}

{ #category : #'instance creation' }
TFLFunctionCyclicCounter class >> newEvery: aDuration [

	^ self newEveryMilliseconds: aDuration asMilliSeconds
]

{ #category : #'instance creation' }
TFLFunctionCyclicCounter class >> newEveryMilliseconds: msToWait [

	^ self basicNew
		  initializeWithMilliseconds: msToWait;
		  yourself
]

{ #category : #accessing }
TFLFunctionCyclicCounter >> announcer [

	^ announcer
]

{ #category : #accessing }
TFLFunctionCyclicCounter >> forkLoopProcess [

	loopProcess := [

		[	| aCounter startMS stopMS |
			aCounter := TFLFunctionCounter new.

			"Count FFI calls during a lapse of time, and measure
			the exact number of milliseconds to adjust the output."
			startMS := Time millisecondClockValue.
			aCounter start.
			delay wait.
			aCounter stop.
			stopMS := Time millisecondClockValue.

			"Schedule output after this process yields the Processor,
			to minimize the number of lost (uncounted) FFI calls."
			[ announcer announce:
				(TFLFunctionCyclicCounterAnnouncement new
					functionNamesAndCounts: aCounter functionNamesAndCounts;
					waitedMS: delay millisecondDelayDuration;
					startMS: startMS;
					stopMS: stopMS;
					yourself) ]
						forkNamed: 'Calls Per Second Tracer - Update'

		] doWhileTrue: [ Processor activeProcess == loopProcess ].
	
	] forkNamed: 'Calls Per Second Tracer - Loop'

]

{ #category : #initialization }
TFLFunctionCyclicCounter >> initializeWithMilliseconds: millisecondsToWait [

	self initialize.

	announcer := Announcer new.
	delay := Delay forMilliseconds: millisecondsToWait.
]

{ #category : #accessing }
TFLFunctionCyclicCounter >> start [

	"Ensure installed on the system"
	TFLSignal install.

	self forkLoopProcess.

]

{ #category : #accessing }
TFLFunctionCyclicCounter >> stop [

	loopProcess ifNil: [ ^self ].
	
	loopProcess terminate.
	loopProcess := nil.

	TFLSignal uninstall.
]

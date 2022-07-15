"
I'm a complement to `TFLCallLogger` that counts the number of calls to each functionName.

Usage:

```
TFLCallLogger install.
TFLFunctionCounter resetInstance.
TFLFunctionCounter start.
""Now, time passes""
TFLFunctionCounter stop.
TFLFunctionCounter instance functionNamesAndCounts.
"">>>
a Dictionary [8 items] (#SDL_GetModState->62 #SDL_GetMouseState->34 #SDL_GetWindowSize->368 #SDL_LockTexture->16 #SDL_PollEvent->553 #SDL_RenderCopy->32 #SDL_RenderPresent->32 #SDL_UnlockTexture->16 )""
```
"
Class {
	#name : #TFLFunctionCounter,
	#superclass : #SignalLogger,
	#instVars : [
		'queue',
		'bagOfFunctionNames'
	],
	#category : #'FFICallLogger-Counter'
}

{ #category : #accessing }
TFLFunctionCounter >> functionNamesAndCounts [

	self process.
	^ bagOfFunctionNames valuesAndCounts
]

{ #category : #registering }
TFLFunctionCounter >> initialize [

	super initialize.

	queue := WaitfreeQueue new.
	bagOfFunctionNames := Bag new.
]

{ #category : #registering }
TFLFunctionCounter >> nextPut: aTFLSignal [
	"Store fast in a waitfree collection. To be processed on demand."
	
	queue nextPut: aTFLSignal functionName
]

{ #category : #API }
TFLFunctionCounter >> process [

	| queueToProcess |
	queueToProcess := queue.
	queue := WaitfreeQueue new.

	self flag: #todo. "we can loose information if queue is locked by another process (Read comment)"
	[ 	| next |
		next := queueToProcess nextIfNone: [ ^ self ].
		bagOfFunctionNames add: next.
	] repeat 

]

{ #category : #accessing }
TFLFunctionCounter >> start [

	self startFor: TFLSignal
]

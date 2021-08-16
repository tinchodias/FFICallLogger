"
I delay code execution in a new Process.

My responsability is to schedule sending #value to an object within certain window of time.

This is an example of instance creation:

~~~
	MinMaxDeferrer
		value: [ 'Hola' traceCr ]
		notBefore: 100 milliSeconds
		notAfter:  500 milliSeconds.
~~~

Each time this deferrer receives #schedule, a Process is forked to wait **at least** 100ms to value the closure (this is the #minDeferral duration).
During the wait, any other #schedule will postpone the evaluation 100ms more.
But there is a limit for postponing: this is the #maxDeferral of 500ms in this example.

The #processName: and #proecssPriority: methods provide a way to customize the creation of the mentioned Process.
"
Class {
	#name : #MinMaxDeferrer,
	#superclass : #Object,
	#instVars : [
		'process',
		'lastSchedule',
		'object',
		'firstSchedule',
		'minDeferral',
		'maxDeferral',
		'processPriority',
		'processName',
		'valuable'
	],
	#category : #'FFICallLogger-UI-Utils'
}

{ #category : #initialization }
MinMaxDeferrer class >> initialize [
	"
	self initialize
	"
	SessionManager default registerUserClassNamed: self name

]

{ #category : #'instance creation' }
MinMaxDeferrer class >> new [

	^ self shouldNotImplement
]

{ #category : #'system startup' }
MinMaxDeferrer class >> shutDown: quitting [
	"Force my instances to flush before image quits"

	quitting ifFalse: [ ^ self ].
	self allInstancesDo: [:each | each flush ].
]

{ #category : #'instance creation' }
MinMaxDeferrer class >> value: aMessageSend notBefore: aDuration notAfter: anotherDuration [

	^ self basicNew
		  initializeWith: aMessageSend
		  minDeferral: aDuration
		  maxDeferral: anotherDuration;
		  yourself
]

{ #category : #accessing }
MinMaxDeferrer >> defaultProcessName [

	^ self className, '-', self identityHash asString
]

{ #category : #accessing }
MinMaxDeferrer >> defaultProcessPriority [
	
	^ Processor userSchedulingPriority
]

{ #category : #scheduling }
MinMaxDeferrer >> flush [

	process ifNotNil: [
		"Execute deferred action and clean up"
		[ valuable value ] ensure: [ process := nil ] 
	].
]

{ #category : #scheduling }
MinMaxDeferrer >> forkDelayProcess [

	process := [
		"Loop until enough time passed since last #schedule"
		[ DateAndTime now < (lastSchedule + minDeferral min: firstSchedule + maxDeferral) ]
			whileTrue: [ minDeferral wait ].
		
		"Execute the deferred action (if not done before) and clean up"
		self flush.
	] forkAt: processPriority named: processName
]

{ #category : #initialization }
MinMaxDeferrer >> initializeWith: aValuable minDeferral: aDuration maxDeferral: anotherDuration [

	self initialize.
	valuable := aValuable.
	minDeferral := aDuration.
	maxDeferral := anotherDuration.
	
	processPriority := self defaultProcessPriority.
	processName := self defaultProcessName.
]

{ #category : #accessing }
MinMaxDeferrer >> maxDeferral [

	^ maxDeferral
]

{ #category : #accessing }
MinMaxDeferrer >> maxDeferral: aDuration [

	maxDeferral := aDuration
]

{ #category : #accessing }
MinMaxDeferrer >> minDeferral [

	^ minDeferral
]

{ #category : #accessing }
MinMaxDeferrer >> minDeferral: aDuration [

	minDeferral := aDuration
]

{ #category : #accessing }
MinMaxDeferrer >> processName [

	^ processName 
]

{ #category : #accessing }
MinMaxDeferrer >> processName: aString [

	processName := aString
]

{ #category : #accessing }
MinMaxDeferrer >> processPriority [

	^ processPriority
]

{ #category : #accessing }
MinMaxDeferrer >> processPriority: anObject [

	processPriority := anObject
]

{ #category : #scheduling }
MinMaxDeferrer >> schedule [

	lastSchedule := DateAndTime now.
	process ifNil: [ 
		firstSchedule := lastSchedule.
		DefaultExecutionEnvironment beActiveDuring: [ self forkDelayProcess ]]
]

{ #category : #accessing }
MinMaxDeferrer >> valuable [

	^ valuable
]

{ #category : #accessing }
MinMaxDeferrer >> valuable: aValuable [

	valuable := aValuable
]
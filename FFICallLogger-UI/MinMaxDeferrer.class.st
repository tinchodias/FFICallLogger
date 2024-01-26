"
I delay code execution in a new `Process`.

My responsability is to schedule sending #value to an object within certain window of time.

This is an example of instance creation:

```
	MinMaxDeferrer
		value: [ 'Hola' traceCr ]
		notBefore: 100 milliSeconds
		notAfter:  500 milliSeconds.
```

Each time this deferrer receives `MinMaxDeferrer>>#schedule`, a `Process` is forked to wait **at least** 100ms to value the closure (this is the `MinMaxDeferrer>>#minDeferral` duration).
During the wait, any other #schedule will postpone the evaluation 100ms more.
But there is a limit for postponing: this is the `MinMaxDeferrer>>#maxDeferral` of 500ms in this example.

The `MinMaxDeferrer>>#processName:` and `MinMaxDeferrer>>#processPriority:` methods provide a way to customize the creation of the mentioned `Process`.
"
Class {
	#name : #MinMaxDeferrer,
	#superclass : #Object,
	#instVars : [
		'process',
		'object',
		'processPriority',
		'processName',
		'valuable',
		'minDeferralMS',
		'maxDeferralMS',
		'lastScheduleMS',
		'firstScheduleMS',
		'scheduleSemaphore'
	],
	#category : #'FFICallLogger-UI'
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
MinMaxDeferrer class >> value: aValuable minMSDeferral: minMS maxMSDeferral: maxMS [

	^ self basicNew
		  initializeWith: aValuable
		  minMSDeferral: minMS
		  maxMSDeferral: maxMS;
		  yourself
]

{ #category : #'instance creation' }
MinMaxDeferrer class >> value: aValuable notBefore: aDuration notAfter: anotherDuration [

	^ self
		  value: aValuable
		  minMSDeferral: aDuration asMilliSeconds
		  maxMSDeferral: anotherDuration asMilliSeconds
]

{ #category : #accessing }
MinMaxDeferrer >> currentMS [

	^ Time millisecondClockValue
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
	"Execute deferred action and clean up"

	process ifNotNil: [
		[ valuable value ] ensure: [ process := nil ] ]
]

{ #category : #private }
MinMaxDeferrer >> forkDelayProcess [

	process := [
		"Loop until enough time passed since last #schedule"
		[ self currentMS < (lastScheduleMS + minDeferralMS min: firstScheduleMS + maxDeferralMS) ]
				whileTrue: [ self waitMS: minDeferralMS ].
		
		"Execute the deferred action (if not done before) and clean up"
		self flush.
	] forkAt: processPriority named: processName
]

{ #category : #initialization }
MinMaxDeferrer >> initializeWith: aValuable minMSDeferral: minMS maxMSDeferral: maxMS [

	self initialize.
	valuable := aValuable.
	minDeferralMS := minMS.
	maxDeferralMS := maxMS.
	scheduleSemaphore := Semaphore new.
		
	processPriority := self defaultProcessPriority.
	processName := self defaultProcessName
]

{ #category : #testing }
MinMaxDeferrer >> isScheduled [

	^ process isNotNil
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
MinMaxDeferrer >> processPriority: aNumber [

	processPriority := aNumber
]

{ #category : #scheduling }
MinMaxDeferrer >> schedule [

	lastScheduleMS := self currentMS.
	process ifNil: [ 
		firstScheduleMS := lastScheduleMS.
		DefaultExecutionEnvironment beActiveDuring: [ self forkDelayProcess ] ]
]

{ #category : #accessing }
MinMaxDeferrer >> valuable [

	^ valuable
]

{ #category : #accessing }
MinMaxDeferrer >> valuable: aValuable [

	valuable := aValuable
]

{ #category : #private }
MinMaxDeferrer >> waitMS: aNumberOfMS [

	scheduleSemaphore waitTimeoutMilliseconds: aNumberOfMS
]

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
		'messageSend',
		'processPriority',
		'processName'
	],
	#category : #'FFICallLogger-Utils'
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
		[ messageSend value ] ensure: [ process := nil ] 
	].
]

{ #category : #initialization }
MinMaxDeferrer >> initializeWith: aMessageSend minDeferral: aDuration maxDeferral: anotherDuration [

	self initialize.
	messageSend := aMessageSend.
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
MinMaxDeferrer >> messageSend [

	^ messageSend
]

{ #category : #accessing }
MinMaxDeferrer >> messageSend: aMessageSend [

	messageSend := aMessageSend
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
MinMaxDeferrer >> runMessageProcess [

	process := [
		"Loop until enough time passed since last #schedule"
		[ DateAndTime now < (lastSchedule + minDeferral min: firstSchedule + maxDeferral) ]
			whileTrue: [ minDeferral wait ].
		
		"Execute the deferred action (if not done before) and clean up"
		self flush.
	] forkAt: processPriority named: processName
]

{ #category : #scheduling }
MinMaxDeferrer >> schedule [

	lastSchedule := DateAndTime now.
	process ifNil: [ 
		firstSchedule := lastSchedule.
		DefaultExecutionEnvironment beActiveDuring: [ self runMessageProcess ]]
]

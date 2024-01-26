Class {
	#name : #MinMaxDeferrerTest,
	#superclass : #TestCase,
	#instVars : [
		'deferrer',
		'triggerCount'
	],
	#category : #'FFICallLogger-UI-Tests'
}

{ #category : #running }
MinMaxDeferrerTest >> setUp [
	super setUp.

	triggerCount := 0
]

{ #category : #tests }
MinMaxDeferrerTest >> testMultipleSchedulesWithWait [

	deferrer := MinMaxDeferrer
		value: (MessageSend receiver: self selector: #trigger)
		minMSDeferral: 50
		maxMSDeferral: 100.

	"Postpone multiple times until defer limit is reached"
	6 timesRepeat: [
		deferrer schedule.
		(Delay forMilliseconds: 20) wait ].
	self assert: triggerCount equals: 1.

	self
		assert: deferrer isScheduled
		description: 'There is still a pending trigger'.
	(Delay forMilliseconds: 101) wait.
	self assert: triggerCount equals: 2
]

{ #category : #tests }
MinMaxDeferrerTest >> testMultipleSchedulesWithoutWait [

	deferrer := MinMaxDeferrer
		value: (MessageSend receiver: self selector: #trigger)
		minMSDeferral: 5
		maxMSDeferral: 30.

	"Postpone multiple times BUT defer limit is NOT reached"
	6 timesRepeat: [ deferrer schedule ].
	self assert: triggerCount equals: 0.
	self assert: deferrer isScheduled.

	(Delay forMilliseconds: 31) wait.
	self assert: triggerCount equals: 1.
	self deny: deferrer isScheduled
]

{ #category : #tests }
MinMaxDeferrerTest >> testSingleSchedule [

	deferrer := MinMaxDeferrer
		value: (MessageSend receiver: self selector: #trigger)
		notBefore: 5 milliSeconds
		notAfter: 30 milliSeconds.

	"Postpone a send of #trigger to myself"
	self deny: deferrer isScheduled.
	deferrer schedule.
	self assert: triggerCount equals: 0.
	self assert: deferrer isScheduled.

	(Delay forMilliseconds: 31) wait.
	self assert: triggerCount equals: 1.
	self deny: deferrer isScheduled
]

{ #category : #accessing }
MinMaxDeferrerTest >> trigger [

	triggerCount := triggerCount + 1
]
